# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**This is not a software project.** Unlike the sibling directories (`02-asteroids`, `03-tetris`),
`05-empleos` is a job-search workspace. There is no build, lint, test, or run command — do not invent
one. The work here is research, matching, and writing.

| File | Role |
|---|---|
| `idea.txt` | The mandate. Two lines of intent, reproduced below. |
| `HojaVidaJonathanIngles.pdf` | The English CV — the source of truth for the candidate profile. Binary and CID-encoded; see extraction below. |
| `portales-sugeridos.md` | **Empty.** Output target for the portal-discovery work. Append-oriented — never overwrite accumulated findings. |

## The mandate (`idea.txt`)

Jonathan is currently job-hunting as a Senior Flutter Mobile Developer and wants two agents:

1. An agent that applies on his behalf, every day, to new openings where he is a good fit.
2. An agent that discovers new job portals and companies hiring Flutter developers.

**Neither agent exists yet.** There is no `.claude/agents/` directory here and no supporting data files.

## Reading the CV

`Read` fails on the PDF (`pdftoppm` not installed) and naive text extraction returns font tables. The
document is CID-encoded with a flat **+29 offset** between CID and ASCII. This command recovers the
body text:

```bash
python3 -c "
import zlib,re
d=open('HojaVidaJonathanIngles.pdf','rb').read()
for m in re.finditer(rb'stream\r?\n(.*?)endstream', d, re.S):
    try: s=zlib.decompress(m.group(1))
    except Exception: continue
    if b'Tj' not in s: continue
    print(''.join(chr(c) if 32<=c<127 else '?' for h in re.findall(rb'<([0-9A-Fa-f]+)>\s*Tj', s)
          for c in [int(h.decode()[i:i+4],16)+29 for i in range(0,len(h),4)]))
"
```

Section headings use a different font subset and come out as `?????` — that is expected and not worth
re-debugging. Body text decodes cleanly, which is all that matters.

## Candidate profile

Transcribed from the PDF as of this file's writing. **The PDF is the source of truth** — re-run the
extraction above if anything below looks stale.

- **Senior Mobile Developer, Flutter/Dart, 6+ years**, iOS & Android. Clean Architecture, state
  management, API and cloud integration; startup and freelance background.
- Contact: `jloboguerrero@gmail.com` · +57 316 707 1771 (Colombia).
- **Dual nationality: Colombian & Venezuelan** — relevant to work-authorization filters.
- **Advanced English** (Simón Bolívar II). The CV itself is written in English.
- LinkedIn `in/jonathanloboguerrero` · GitHub `jloboguerrero`.

**Stack**
- Mobile: Flutter, Dart, BLoC, Provider, Riverpod, Modular, Firebase, CleverTap, Segment
- Architecture: Clean Architecture, SOLID, MVC, RESTful APIs
- Backend & DevOps: Git, GitLab CI/CD, Linux, Elasticsearch/Kibana
- Databases: SQLite, MySQL
- Other: UX/UI, iOS/Android deployments

**Experience**
- **Knotion – Doc** — Mobile Flutter Developer, Aug 2025 → present. US healthcare startup. Clean
  Architecture + BLoC; shenai SDK for blood pressure / heart rate via facial scan; Agora live webcam;
  PR review.
- **Halen** — Mobile Flutter Developer, Jan 2026 → Jul 2026. US rideshare startup (driver + customer
  apps). Riverpod, Google Maps, Firebase.
- **Tul** — Mobile Flutter Developer, Jun 2021 → Jul 2025. Leading Latam construction/hardware startup.
  App with **500K+ downloads**; Clean Architecture, BLoC/Provider; CleverTap and Segment analytics;
  mentored juniors in the Flutter Chapter.
- **Data & Business** — Fullstack Developer, Jul 2020 → May 2021. PHP7/JS/HTML5/CSS, Elasticsearch +
  Kibana, Linux servers, Bitrix24 CRM.
- **Soluciones Auditivas** — Freelance Mobile Developer, Jan–Feb 2021. Cross-platform hearing-loss
  measurement app; SQLite, animations, Firebase; accessible UX for non-technical users.
- **IP Consultores S.A.S.** — Systems Administrator, Jul 2018 → Jun 2020. Debian/Ubuntu, Xen, Asterisk
  PBX, Packetbeat/Filebeat/Metricbeat, Cloudflare.

**Education:** Electronic Engineer, Universidad Simón Bolívar (USB).

**Shipped apps:** Tul (Play Store `co.com.tul.ironmonger` + App Store `id1508556522`), Armadura de Dios
(App Store `id6452149616`).

## Working conventions

- The working language with the user is **Spanish**. The CV and all outward-facing application
  materials are **English**.
- Submitting applications and messaging recruiters are outward-facing and hard to reverse. Confirm the
  specific list of targets with the user before anything is sent on his behalf.

## Repo context

The parent `ClaudeCode` repo is a collection of unrelated per-directory experiments; nothing here
shares code with the siblings. The root `.mcp.json` enables a **supabase** MCP server (project ref
`zsoukhvolffcuorvjudy`), activated in `.claude/settings.local.json` — available, but nothing in
`05-empleos` currently uses it.

## Agentes

### `job-apply` — aplicar a ofertas (`/aplicar`)

Definido en `.claude/agents/job-apply.md`, disparado por `.claude/commands/aplicar.md`.
El usuario lo corre **manualmente 1× al día, en la mañana**. No está automatizado con cron a
propósito: Chrome debe estar abierto con las sesiones de LinkedIn/Glassdoor iniciadas, y el envío
requiere aprobación humana en el chat.

> Se probó 2× al día y sobra: la corrida del 2026-08-18 dio ~470 ofertas crudas en 13 portales y
> **1 sola** candidata Flutter senior remota. Con ese caudal la segunda corrida ve lo mismo y el
> dedupe la vacía. La ventana adaptativa (abajo) hace innecesario correr más seguido.

```
/aplicar                    # todos los portales
/aplicar linkedin           # un solo tier
/aplicar --dry-run          # busca y puntúa, no envía
```

**Flujo:** busca ofertas dentro de la ventana → puntúa compatibilidad Flutter (umbral ≥70) →
dedupe contra el historial → **para y pide aprobación** → rellena y envía → registra.

**Ventana adaptativa** (no es fija de 24h): `clamp(ahora − últimoEscaneo[portal], 24h, 7 días)`,
con estado en `historial/ultima-corrida.json`. La marca de un portal avanza **solo si el escaneo
tuvo éxito**, así que un portal bloqueado por Cloudflare se mira con ventana más ancha al día
siguiente. Los portales de bajo volumen publican 1–2 vacantes Flutter por semana; 24h fijas las
perdían.

**Fallback "Apply on company website":** cuando el botón de aplicar abre una pestaña fuera del grupo
MCP (Wellfound), el agente intenta extraer la URL destino con `javascript_tool` y, si no puede, deja
la oferta en `historial/pendientes-manual.md` con el link directo en vez de abortar la corrida.

**Filtro de compatibilidad:** descarte inmediato cuando el stack principal **no** es Flutter —
Swift/Kotlin nativo, React Native, Ionic, Xamarin, MAUI como el puesto en sí. Un requisito de nativo
*junto a* Flutter **no** descarta (decisión del usuario, 2026-08-18): Flutter pesa más y el nativo se
aprende. La honestidad no cambia — si un screening pregunta años de Swift, la respuesta es `0`.

Bonus de +10 a puestos híbridos que mezclan Flutter con IA/LLM o backend — la ruta de crecimiento
que el usuario está preparando. El `+15` de seniority cuenta también si la descripción pide 5+ años,
aunque el título no diga "Senior".

**Archivos de apoyo**

| Ruta | Rol |
|---|---|
| `datos/perfil.json` | Datos canónicos para formularios. **Derivado del PDF** — regenerable con la extracción CID de arriba. Campos `null` (ciudad, salario, disponibilidad) los pregunta el agente y los persiste; nunca los inventa. |
| `datos/respuestas.md` | Banco de respuestas EN para screening. El agente copia de aquí, no improvisa. |
| `datos/cover-letter-base.md` | Plantilla EN con `{PLACEHOLDERS}`. Nunca se envía sin sustituir. |
| `portales.md` | Catálogo de URLs de búsqueda **verificadas**, por tier. Ninguna URL entra sin probarse contra el portal real. |
| `historial/aplicaciones.json` | Fuente de verdad del dedupe. `id` = sha1(empresa + título normalizado), no de la URL. |
| `historial/aplicaciones.md` | Bitácora legible. |
| `historial/descartadas.json` | Ofertas ya evaluadas y rechazadas, para no reprocesarlas. |
| `historial/ultima-corrida.json` | Estado de la ventana adaptativa: último escaneo exitoso por portal. |
| `historial/pendientes-manual.md` | Ofertas aprobadas que el agente no pudo enviar. Checklist con links directos. |

**Límites del agente** (escritos en su definición, no negociables): no resuelve CAPTCHAs, no crea
cuentas ni escribe contraseñas, no acepta términos ni marca casillas de consentimiento, no inventa
datos, no exagera experiencia, máximo 15 aplicaciones por corrida, y solo envía lo aprobado.

> `datos/perfil.json` contiene teléfono y email personales. Este repo no debe hacerse público.

### `job-scout` — descubrir fuentes (`/explorar`)

Definido en `.claude/agents/job-scout.md`, disparado por `.claude/commands/explorar.md`.
El segundo agente de `idea.txt`. Corre **semanalmente** — el panorama de portales cambia despacio.

```
/explorar               # los cuatro focos
/explorar empresas      # un foco solo
```

**Cuatro focos:** portales y boards nuevos · empresas que usan Flutter (rastreadas desde las ofertas
ya vistas hasta su ATS directo) · agencias de staffing LatAm · reclutadores y comunidades.

**Protocolo de verificación** — la razón de existir del agente. Ninguna fuente entra a
`portales-sugeridos.md` sin: dominio que resuelve y responde 200 · la URL **respeta el parámetro de
búsqueda** (comparar resultados con y sin él) · los resultados son Flutter el framework, no la
palabra suelta · características operativas registradas (filtro de fecha, login, anti-bot) · y
señal de vida (cuántas vacantes y de cuándo es la más reciente).

> Existe porque el 2026-08-18 cuatro URLs escritas de memoria — un `geoId` de Asia-Pacífico
> etiquetado como LatAm, un dominio inexistente, un 404 y tres portales que ignoran el parámetro de
> búsqueda — dejaron una corrida entera de `job-apply` en cero.

**Separación de poderes:** `job-scout` **no** tiene `form_input` ni `file_upload` (investiga, no
aplica), **no** contacta a nadie, y **no** escribe en `portales.md`. Propone en
`portales-sugeridos.md` (append-only) y el usuario aprueba qué se promueve al catálogo activo.

Salida adicional: `datos/empresas.json` — empresas que usan Flutter con su ATS y página de empleo.

### Permisos

`.claude/settings.local.json` auto-aprueba las herramientas `mcp__claude-in-chrome__*` (incluidas
`form_input` y `file_upload`), `WebSearch`/`WebFetch` y algunos `Bash` de verificación. Esto quita
la fricción de aprobar cada tecleo, **no** el punto de control: la parada obligatoria de la Fase 3
sigue siendo regla dura de `job-apply.md`. Si alguna vez envía algo sin preguntar, es un bug grave
y hay que revertir este archivo.
