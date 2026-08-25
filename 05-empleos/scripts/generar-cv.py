#!/usr/bin/env python3
"""
Genera el CV adaptado a una oferta concreta: JSON -> HTML -> PDF.

    python3 scripts/generar-cv.py --datos <cv-oferta.json> [--salida <ruta.pdf>]

El JSON de entrada lo escribe el agente job-apply en la Fase 3.5. Solo stdlib:
en esta maquina no hay pandoc, wkhtmltopdf, weasyprint, libreoffice, reportlab
ni fpdf. La unica ruta HTML->PDF es Chrome headless, y se lanza desde aqui
(y no como Bash directo) porque settings.local.json auto-aprueba `python3 *`
pero no el binario de Chrome: asi la corrida no pide permiso en cada oferta.

Esquema del JSON de entrada (los campos opcionales caen a perfil.json):

    {
      "meta": { "empresa": "...", "puesto": "...", "fecha": "2026-08-24",
                "portal": "linkedin", "urlOferta": "https://..." },
      "tituloObjetivo": "Senior Flutter Developer",
      "summary": "...",
      "skills": [ { "grupo": "Mobile", "items": ["Flutter", "Dart"] } ],
      "familiarWith": ["GraphQL", "Node.js"],
      "experiencia": [ { "company": "Tul", "title": "...", "location": "...",
                         "start": "2021-06", "end": "2025-07",
                         "context": "...", "bullets": ["..."] } ],
      "educacion": [...],           // opcional
      "certificaciones": [...],     // opcional
      "mostrarApps": true,          // opcional
      "coverLetter": "...",         // opcional -> se escribe como _CoverLetter.txt
      "claimsSinRespaldo": ["GraphQL"]
    }

Salida (junto al PDF): el .html intermedio, para poder depurar el layout.
"""

import argparse
import html
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import unicodedata
import zlib
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PLANTILLA = RAIZ / "datos" / "cv-plantilla.html"
PERFIL = RAIZ / "datos" / "perfil.json"
SALIDAS = RAIZ / "salidas" / "cv"

CHROME_CANDIDATOS = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
]

MESES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


class ErrorCV(Exception):
    """Fallo que debe abortar la generacion de ESTE CV, no de la corrida."""


# --------------------------------------------------------------------------
# utilidades
# --------------------------------------------------------------------------

def e(texto):
    """Escapa para HTML. Todo lo que viene del JSON pasa por aqui."""
    return html.escape(str(texto if texto is not None else ""), quote=True)


def slug(texto, maxlen=40):
    """'Flutter Developer (Remote)' -> 'Flutter-Developer-Remote'."""
    texto = unicodedata.normalize("NFKD", str(texto))
    texto = texto.encode("ascii", "ignore").decode("ascii")
    texto = re.sub(r"[^A-Za-z0-9]+", "-", texto).strip("-")
    return (texto[:maxlen].rstrip("-")) or "sin-nombre"


def fecha_legible(valor):
    """'2021-06' -> 'Jun 2021'. None/'' -> 'Present'."""
    if not valor:
        return "Present"
    m = re.match(r"^(\d{4})-(\d{1,2})$", str(valor).strip())
    if not m:
        return str(valor)
    anio, mes = int(m.group(1)), int(m.group(2))
    if not 1 <= mes <= 12:
        return str(valor)
    return f"{MESES[mes - 1]} {anio}"


def buscar_chrome():
    for ruta in CHROME_CANDIDATOS:
        if os.path.isfile(ruta) and os.access(ruta, os.X_OK):
            return ruta
    for nombre in ("google-chrome", "chromium", "chromium-browser", "chrome"):
        encontrado = shutil.which(nombre)
        if encontrado:
            return encontrado
    raise ErrorCV(
        "No se encontro Chrome. Es la unica ruta HTML->PDF disponible en esta "
        "maquina (no hay pandoc/wkhtmltopdf/weasyprint). Instala Google Chrome "
        "o anade su ruta a CHROME_CANDIDATOS en scripts/generar-cv.py."
    )


# --------------------------------------------------------------------------
# render de bloques
# --------------------------------------------------------------------------

def bloque_skills(skills, familiar):
    partes = []
    for grupo in skills or []:
        items = [i for i in grupo.get("items", []) if i]
        if not items:
            continue
        partes.append(
            '<div class="skill-line"><span class="skill-label">{}:</span> {}</div>'.format(
                e(grupo.get("grupo", "Skills")), e(" · ".join(items))
            )
        )
    familiar = [f for f in (familiar or []) if f]
    if familiar:
        partes.append(
            '<div class="skill-line familiar"><span class="skill-label">'
            'Familiar with:</span> {}</div>'.format(e(" · ".join(familiar)))
        )
    if not partes:
        raise ErrorCV("El JSON no trae ningun skill: el CV saldria sin seccion SKILLS.")
    return "\n".join(partes)


def bloque_experiencia(experiencia):
    if not experiencia:
        raise ErrorCV("El JSON no trae experiencia.")
    trabajos = []
    for job in experiencia:
        fechas = "{} – {}".format(fecha_legible(job.get("start")),
                                  fecha_legible(job.get("end")))
        resto = " | ".join(x for x in (job.get("location"), job.get("context")) if x)
        bullets = "\n".join(
            "      <li>{}</li>".format(e(b)) for b in job.get("bullets", []) if b
        )
        trabajos.append(
            '<div class="job">\n'
            '  <div class="job-header">'
            '<span class="job-title">{titulo}</span> — '
            '<span class="job-company">{empresa}</span></div>\n'
            '  <div class="job-meta"><span class="job-dates">{fechas}</span>'
            '<span class="job-context">{resto}</span></div>\n'
            '  <ul>\n{bullets}\n  </ul>\n'
            '</div>'.format(
                fechas=e(fechas), titulo=e(job.get("title", "")),
                empresa=e(job.get("company", "")),
                resto=e(" | " + resto if resto else ""), bullets=bullets,
            )
        )
    return "\n".join(trabajos)


def bloque_educacion(educacion):
    lineas = []
    for edu in educacion or []:
        anios = ""
        if edu.get("startYear") or edu.get("endYear"):
            anios = " ({}–{})".format(edu.get("startYear") or "", edu.get("endYear") or "")
        cola = " | ".join(x for x in (edu.get("school"), edu.get("country")) if x)
        lineas.append(
            '<div class="edu-line"><span class="edu-degree">{}</span>{} — {}</div>'.format(
                e(edu.get("degree", "")), e(anios), e(cola)
            )
        )
    return "\n".join(lineas) or '<div class="edu-line">—</div>'


def bloque_certificaciones(certs):
    items = "\n".join("  <li>{}</li>".format(e(c)) for c in (certs or []) if c)
    return '<ul class="cert-list">\n{}\n</ul>'.format(items) if items else ""


def bloque_apps(apps, mostrar):
    if not mostrar or not apps:
        return ""
    partes = ["{} — {}".format(a.get("name", ""), a.get("url", "")) for a in apps]
    return ('<h2>Shipped Apps</h2>\n<p class="apps-line">{}</p>'
            .format(e(" · ".join(partes))))


def renderizar_html(datos, perfil):
    personal = perfil.get("personal", {})
    links = perfil.get("links", {})

    linea1 = " | ".join(x for x in (
        personal.get("cityDisplay"),
        personal.get("email"),
        personal.get("phone"),
    ) if x)

    linea2_partes = []
    if links.get("linkedin"):
        linea2_partes.append(re.sub(r"^https?://(www\.)?", "", links["linkedin"]).rstrip("/"))
    if links.get("github"):
        linea2_partes.append(re.sub(r"^https?://(www\.)?", "", links["github"]).rstrip("/"))
    if links.get("portfolio"):
        linea2_partes.append(re.sub(r"^https?://(www\.)?", "", links["portfolio"]).rstrip("/"))
    linea2 = " | ".join(linea2_partes)

    summary = (datos.get("summary") or "").strip()
    if not summary:
        raise ErrorCV("El JSON no trae summary.")

    reemplazos = {
        "{{NOMBRE}}": e(personal.get("fullName", "")),
        "{{TITULO_OBJETIVO}}": e(datos.get("tituloObjetivo")
                                 or perfil.get("profile", {}).get("title", "")),
        "{{CONTACTO_LINEA1}}": e(linea1),
        "{{CONTACTO_LINEA2}}": e(linea2),
        "{{SUMMARY}}": e(summary),
        "{{SKILLS_BLOCK}}": bloque_skills(datos.get("skills"), datos.get("familiarWith")),
        "{{EXPERIENCE_BLOCK}}": bloque_experiencia(datos.get("experiencia")),
        "{{EDUCATION_BLOCK}}": bloque_educacion(
            datos.get("educacion") or perfil.get("education")),
        "{{CERTIFICATIONS_BLOCK}}": bloque_certificaciones(
            datos.get("certificaciones") or perfil.get("certifications")),
        "{{APPS_BLOCK}}": bloque_apps(perfil.get("shippedApps"),
                                      datos.get("mostrarApps", True)),
    }

    plantilla = PLANTILLA.read_text(encoding="utf-8")
    for clave, valor in reemplazos.items():
        plantilla = plantilla.replace(clave, valor)

    sobrantes = re.findall(r"\{\{[A-Z_]+\}\}", plantilla)
    if sobrantes:
        raise ErrorCV("Placeholders sin sustituir en la plantilla: {}".format(
            ", ".join(sorted(set(sobrantes)))))
    return plantilla


# --------------------------------------------------------------------------
# PDF
# --------------------------------------------------------------------------

def html_a_pdf(ruta_html, ruta_pdf, timeout=60):
    """
    Chrome 151 escribe el PDF y NO termina: se queda vivo con GoogleUpdater
    colgando del proceso. Por eso NO se espera a que salga — se espera a que el
    archivo aparezca y deje de crecer, y despues se mata el proceso.
    Esperar el exit code cuelga la corrida indefinidamente (probado 2026-08-24).
    """
    chrome = buscar_chrome()
    destino = Path(ruta_pdf)
    if destino.exists():
        destino.unlink()

    perfil_tmp = tempfile.mkdtemp(prefix="cv-chrome-")
    args = [
        chrome,
        "--headless",
        "--disable-gpu",
        "--no-first-run",
        "--no-default-browser-check",
        "--no-pdf-header-footer",   # sin esto Chrome estampa URL y fecha en cada pagina
        "--disable-background-networking",
        "--disable-component-update",
        "--disable-crash-reporter",
        "--disable-breakpad",
        "--disable-sync",
        "--mute-audio",
        "--run-all-compositor-stages-before-draw",
        "--virtual-time-budget=4000",
        "--user-data-dir={}".format(perfil_tmp),  # no toca el perfil real del usuario
        "--print-to-pdf={}".format(destino),
        "file://{}".format(ruta_html),
    ]

    proc = subprocess.Popen(args, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    try:
        tam_previo, estable, limite = -1, 0, time.monotonic() + timeout
        while time.monotonic() < limite:
            if destino.exists():
                tam = destino.stat().st_size
                # dos lecturas seguidas del mismo tamano (>0) = escritura terminada
                estable = estable + 1 if tam == tam_previo and tam > 0 else 0
                tam_previo = tam
                if estable >= 2:
                    return
            if proc.poll() is not None and not destino.exists():
                raise ErrorCV("Chrome termino (rc={}) sin escribir el PDF.".format(
                    proc.returncode))
            time.sleep(0.25)
        raise ErrorCV("Chrome no escribio el PDF en {}s.".format(timeout))
    finally:
        for metodo in (proc.terminate, proc.kill):
            if proc.poll() is None:
                try:
                    metodo()
                    proc.wait(timeout=5)
                except Exception:
                    pass
        shutil.rmtree(perfil_tmp, ignore_errors=True)


def _cmaps_tounicode(datos_pdf):
    """Mapa cid->unicode juntando todos los /ToUnicode del PDF."""
    mapa = {}
    for m in re.finditer(rb"stream\r?\n(.*?)endstream", datos_pdf, re.S):
        try:
            crudo = zlib.decompress(m.group(1))
        except Exception:
            crudo = m.group(1)
        if b"beginbfchar" not in crudo and b"beginbfrange" not in crudo:
            continue
        for bloque in re.findall(rb"beginbfchar(.*?)endbfchar", crudo, re.S):
            for src, dst in re.findall(rb"<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>", bloque):
                mapa[int(src, 16)] = _hex_a_texto(dst)
        for bloque in re.findall(rb"beginbfrange(.*?)endbfrange", crudo, re.S):
            for lo, hi, dst in re.findall(
                    rb"<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>\s*<([0-9A-Fa-f]+)>", bloque):
                inicio, fin, base = int(lo, 16), int(hi, 16), int(dst, 16)
                for offset in range(min(fin - inicio + 1, 512)):
                    mapa[inicio + offset] = chr(base + offset)
    return mapa


def _hex_a_texto(h):
    h = h.decode("ascii")
    try:
        return bytes.fromhex(h if len(h) % 2 == 0 else "0" + h).decode("utf-16-be", "ignore")
    except Exception:
        return ""


def texto_del_pdf(ruta_pdf):
    """Extrae el texto como lo veria un parser de ATS. Vacio = PDF ilegible."""
    datos_pdf = Path(ruta_pdf).read_bytes()
    mapa = _cmaps_tounicode(datos_pdf)
    trozos = []
    for m in re.finditer(rb"stream\r?\n(.*?)endstream", datos_pdf, re.S):
        try:
            crudo = zlib.decompress(m.group(1))
        except Exception:
            continue
        if b"Tj" not in crudo and b"TJ" not in crudo:
            continue
        for h in re.findall(rb"<([0-9A-Fa-f]+)>", crudo):
            cadena = h.decode("ascii")
            for i in range(0, len(cadena) - 3, 4):
                cid = int(cadena[i:i + 4], 16)
                trozos.append(mapa.get(cid, ""))
        for lit in re.findall(rb"\(((?:[^()\\]|\\.)*)\)\s*Tj", crudo):
            trozos.append(lit.decode("latin-1", "ignore"))
        trozos.append(" ")
    return "".join(trozos)


def verificar_pdf(ruta_pdf, palabras_clave):
    ruta = Path(ruta_pdf)
    if not ruta.exists():
        raise ErrorCV("El PDF no se creo.")
    tam = ruta.stat().st_size
    if tam < 8000:
        raise ErrorCV("El PDF pesa {} bytes: casi seguro salio en blanco.".format(tam))

    texto = texto_del_pdf(ruta)
    avisos = []
    if not texto.strip():
        raise ErrorCV(
            "No se pudo extraer texto del PDF. Si yo no puedo leerlo, el ATS "
            "tampoco: no se adjunta."
        )

    plano = re.sub(r"\s+", " ", texto).lower()
    faltantes = [p for p in palabras_clave if p and p.lower() not in plano]
    if faltantes:
        raise ErrorCV(
            "El texto del PDF no contiene: {}. El render perdio contenido."
            .format(", ".join(faltantes))
        )

    paginas = len(re.findall(rb"/Type\s*/Page[^s]", ruta.read_bytes()))
    if paginas > 2:
        avisos.append("El CV ocupa {} paginas. Recorta bullets de las empresas "
                      "comprimibles (ver reglasDeSeleccion en cv-fuente.json).".format(paginas))
    return {"bytes": tam, "paginas": paginas, "caracteres": len(texto), "avisos": avisos}


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------

def ruta_por_defecto(datos, perfil):
    meta = datos.get("meta", {})
    fecha = meta.get("fecha") or ""
    apellido = slug(perfil.get("personal", {}).get("fullName", "CV"), 40)
    nombre = "{}_{}_{}_{}_CV.pdf".format(
        fecha, slug(meta.get("empresa", "empresa")),
        slug(meta.get("puesto", "puesto")), apellido)
    return SALIDAS / nombre.lstrip("_")


def main():
    ap = argparse.ArgumentParser(description="Genera el CV adaptado a una oferta.")
    ap.add_argument("--datos", required=True, help="JSON de la oferta (Fase 3.5)")
    ap.add_argument("--salida", help="Ruta del PDF. Por defecto salidas/cv/<fecha>_<empresa>_...")
    ap.add_argument("--solo-html", action="store_true",
                    help="Renderiza el HTML y para (para iterar el layout sin Chrome)")
    args = ap.parse_args()

    try:
        datos = json.loads(Path(args.datos).read_text(encoding="utf-8"))
        perfil = json.loads(PERFIL.read_text(encoding="utf-8"))

        ruta_pdf = Path(args.salida).resolve() if args.salida else ruta_por_defecto(datos, perfil)
        ruta_pdf.parent.mkdir(parents=True, exist_ok=True)
        ruta_html = ruta_pdf.with_suffix(".html")

        # Validar la carta ANTES de gastar un render de Chrome (~10s por oferta).
        carta = (datos.get("coverLetter") or "").strip()
        if carta and re.search(r"\{[A-Z_ÁÉÍÓÚÑ]+[^}]*\}", carta):
            raise ErrorCV("La cover letter todavia tiene placeholders sin sustituir.")

        ruta_html.write_text(renderizar_html(datos, perfil), encoding="utf-8")
        if args.solo_html:
            print(json.dumps({"ok": True, "html": str(ruta_html), "pdf": None}, indent=2))
            return 0

        html_a_pdf(str(ruta_html), str(ruta_pdf))

        apellido = perfil.get("personal", {}).get("lastName", "").split()[0]
        info = verificar_pdf(ruta_pdf, ["Flutter", apellido])

        salida = {"ok": True, "pdf": str(ruta_pdf), "html": str(ruta_html), **info}

        if carta:
            ruta_carta = Path(str(ruta_pdf).replace("_CV.pdf", "_CoverLetter.txt"))
            if ruta_carta == ruta_pdf:
                ruta_carta = ruta_pdf.with_name(ruta_pdf.stem + "_CoverLetter.txt")
            ruta_carta.write_text(carta + "\n", encoding="utf-8")
            salida["coverLetter"] = str(ruta_carta)

        ruta_json = ruta_pdf.with_suffix(".json")
        ruta_json.write_text(json.dumps(datos, indent=2, ensure_ascii=False), encoding="utf-8")
        salida["datos"] = str(ruta_json)

        claims = datos.get("claimsSinRespaldo") or []
        if claims:
            salida["claimsSinRespaldo"] = claims

        print(json.dumps(salida, indent=2, ensure_ascii=False))
        return 0

    except ErrorCV as err:
        print(json.dumps({"ok": False, "error": str(err)}, indent=2, ensure_ascii=False))
        return 1
    except Exception as err:  # JSON malformado, permisos, etc.
        print(json.dumps({"ok": False, "error": "{}: {}".format(type(err).__name__, err)},
                         indent=2, ensure_ascii=False))
        return 2


if __name__ == "__main__":
    sys.exit(main())
