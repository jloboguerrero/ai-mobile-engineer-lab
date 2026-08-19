# Portales sugeridos

Salida del agente `job-scout` (`/explorar`). **Append-only**: cada corrida agrega una seccion con
fecha; nunca se sobrescriben hallazgos anteriores.

Ninguna entrada aqui llega sin pasar el protocolo de verificacion (dominio resuelve, la URL respeta
el parametro de busqueda, los resultados son Flutter el framework, y hay actividad reciente).

**Nada de este archivo esta activo.** El catalogo que gobierna las aplicaciones reales es
`portales.md`; la promocion de una fuente de aqui hacia alla la aprueba el usuario.

---

<!-- Las corridas de /explorar se agregan debajo, la mas reciente primero -->

# Corrida 2026-08-18 — `/explorar` (los cuatro focos)

Foco: portales · empresas · agencias · comunidades. Todo lo de abajo fue probado contra el sitio
real el 2026-08-18. Nada de aqui esta activo hasta que el usuario lo promueva a `portales.md`.

## Verificadas y recomendadas

### HiringCafe — Tier 2 sugerido (la mejor del dia)
- URL probada:
  `https://hiring.cafe/?searchState=%7B%22searchQuery%22%3A%22flutter%22%2C%22workplaceTypes%22%3A%5B%22Remote%22%5D%2C%22defaultToUserLocation%22%3Afalse%2C%22sortBy%22%3A%22date%22%7D`
  → **346 vacantes** remoto "Anywhere in the world", 215 empresas
- Respeta el parametro: **si** (sin `searchQuery` devuelve 11.338 jobs)
- Filtro de fecha: `sortBy:"date"` **si funciona** (primeros resultados 21h / 1d).
  `dateFetchedPastNDays` se acepta pero **no cambia el conteo** — no confiar en el, usar el sort
  y leer la antiguedad de cada tarjeta (`21h`, `1d`, `6d`, `2mo`)
- Login: **no** · Anti-bot: **no** · Apply: link "Job Posting" que sale al ATS original de la empresa
- Mas reciente: 21 horas · Verificado: 2026-08-18
- Nota 1: `hiring.cafe` redirige a `hiringcafe.com` — es el mismo sitio, no es un fallo
- Nota 2: la busqueda es **semantica**. Con `q=flutter` y sort por relevancia el ruido es bajo; con
  `q="flutter developer"` y sort por fecha mete falsos positivos (Lennar, Alibaba, ScholarshipOwl).
  Usar `flutter` a secas
- Nota 3: por defecto arranca con ubicacion "United States" — `defaultToUserLocation:false` es
  **obligatorio** para ver LatAm/mundial. Mismo tipo de trampa que el `geoId` de LinkedIn
- Nota 4: es tambien la mejor fuente para poblar `datos/empresas.json` — cada tarjeta trae empresa,
  stack completo y link directo al ATS

### RemoteRocketship — Tier 2 sugerido
- URL probada: `https://www.remoterocketship.com/?page=1&sort=DateAdded&jobTitle=Flutter`
  → **82 vacantes Flutter**, "4 nuevas esta semana"
- Respeta el parametro: **si** (sin `jobTitle` devuelve 194.456 jobs)
- Filtro de fecha: `sort=DateAdded` funciona; cada tarjeta muestra "5 days ago"
- Login: no para listar · Anti-bot: **curl devuelve 403, el navegador entra bien** → el agente debe
  usar el navegador, no `curl` · Apply: externo (botones Website / LinkedIn / All Job Openings)
- Mas reciente: 5 dias · Verificado: 2026-08-18
- Nota: las tarjetas traen tags de **seniority** (Mid-level / Senior), pais y stack — ideal para el
  scoring de `job-apply` sin abrir el detalle. Filtra remote-only por defecto, alcance mundial

### DailyRemote — Tier 3 sugerido
- URL probada: `https://www.dailyremote.com/remote-jobs?search=flutter` → **30 vacantes**, todas
  Flutter el framework (Flutter Engineer, Senior Mobile Developer Flutter, Tech Lead Flutter…)
- Respeta el parametro: **si** (253 menciones de "flutter" con el parametro vs **0** sin el)
- Filtro de fecha: no en la URL, pero el HTML trae **JSON-LD con `datePosted` exacto** por vacante y
  el listado viene ordenado por fecha descendente
- Login: no · Anti-bot: no (`curl` entra a 200) · Apply: externo al sitio de la empresa
- Mas reciente: 2026-08-17 (1 dia) · Verificado: 2026-08-18
- Nota: el unico de la corrida que se puede raspar con `curl` sin navegador. Barato de escanear

### Jobgether — Tier 3 sugerido (marginal)
- URL probada: `https://jobgether.com/search-offers?role=flutter-developer&location=latam`
  → **8 vacantes**, todas Flutter real
- Respeta el parametro `role`: **si** (sin el, 200.000+ jobs)
- ⚠️ El parametro `location=latam` **no restringe nada**: las 8 salen como "Remote from Anywhere"
- ⚠️ `https://jobgether.com/remote-jobs/latam/flutter-developer` responde **HTTP 410** y redirige a
  `/search-offers?...`. Usar directamente la URL de `/search-offers`
- Filtro de fecha: hay toggle "Sort by: Date" en la UI, no verificado como parametro de URL
- Login: no para listar · Anti-bot: no · Apply: boton propio + empuje agresivo a premium/auto-apply
- Mas reciente: 8 dias · Verificado: 2026-08-18
- Nota: volumen bajo y algo rancio. Vale como red de seguridad, no como fuente principal

## Verificadas y descartadas — no reintentar

| Fuente | URL probada | Motivo |
|---|---|---|
| **Remotive** | `remotive.com/api/remote-jobs?search=flutter` | **Ignora el parametro**: 17 resultados con y sin `search`, y ninguno es Flutter (Patient Care Specialist, Freelance Writer, Sales Jedi). `remotive.com/remote-jobs/search?search=` da 404 |
| **NoDesk** | `nodesk.co/remote-jobs/?search=flutter` | **Ignora el parametro**: 64 vacantes con y sin el, **0 menciones** de Flutter. `nodesk.co/remote-jobs/flutter/` → 404 |
| **Arc.dev** | `arc.dev/remote-jobs?q=flutter` y `arc.dev/remote-jobs/flutter` | `?q=` se ignora (cae al landing). La pagina `/flutter` existe y aplica un chip "Flutter", pero el tag esta mal puesto: devuelve *Staff Rust SDK Engineer*, *Marketing Campaign & Strategy Leader* y **"Flutter UK & Ireland — Lead Data Scientist"** (la casa de apuestas otra vez, mismo falso positivo que "Flutter Brazil"). Cero vacantes Flutter reales |
| **Jobicy** | web `jobicy.com/?s=flutter` · API `jobicy.com/api/v2/remote-jobs?tag=flutter` | Web bloqueada por **Cloudflare** (no se resuelve, por politica). La API responde pero da 10 resultados, 9 de Canonical sin relacion con Flutter, la mas reciente 2026-08-01. Sin señal |
| **flutterjobs.info** | `flutterjobs.info/jobs/all` | Dominio vivo (200) pero **el board esta muerto**: la ultima vacante publicada es del **31 de julio de 2020** |
| **VacantesDigitales** | `vacantesdigitales.com/empleo-tags/flutter-developer` | Respeta el tag (28 vacantes LatAm reales, y es el unico board 100% LatAm que encontre), **pero la mas reciente es del 2026-04-20** — 4 meses. Sin vida para este perfil. Reevaluar en 3 meses |
| **DevJobsScanner** | `devjobsscanner.com/remote-flutter-jobs/` | **403** a `curl` (anti-bot). No verificado — queda pendiente para una corrida con navegador |
| **Wellfound `/role/l/`** | `wellfound.com/role/l/flutter-developer/latin-america` | ⚠️ **Trampa**: responde 200 pero **redirige a `/role/flutter-developer`** descartando la ubicacion, y devuelve 74 resultados dominados por India (salarios en ₹, presenciales en Hyderabad/Nashik/Bangalore). **Seguir usando `wellfound.com/jobs?q=flutter`** que ya esta en `portales.md` |
| **BeOn.tech** | `beon.tech/remote-jobs/` | Agencia LatAm real, pero **exige login** para ver las vacantes y **Flutter no aparece** entre sus tecnologias listadas (si Swift, Kotlin, iOS, Android) |
| **Turing** | `turing.com/jobs/remote-flutter-developer` | 200, pero es una **landing de marketing** sin listado con fechas. El modelo es registrarse + pasar tests. No se verifico por la regla de no crear cuentas |

**URLs que directamente no existen** (404/403/sin respuesta, verificado 2026-08-18 — no reintentar):
`jobs.lever.co/jobsity` · `boards.greenhouse.io/jobsity` · `jobsity.com/careers` (500) ·
`gaper.io/careers/` · `andela.com/job-listings` · `nearsure.com/jobs` · `jobs.lever.co/nearsure` ·
`jobs.lever.co/moduscreate` · `revelo.com/jobs` · `beon.tech/jobs` · `distillery.com/careers/` (403) ·
`leantech.io/careers/` (sin respuesta) · `boards.greenhouse.io/bairesdev` · `boards.greenhouse.io/ceresti`

> ⚠️ **Ojo con `jobs.ashbyhq.com/<slug>`**: Ashby es una SPA y devuelve **200 para cualquier slug
> inventado** (probado con `zzz-not-a-real-company-xyz` → 200, 7.128 bytes). Verificar por el
> `<title>`: si dice solo "Jobs" el board no existe; si dice "<Empresa> Jobs" es real.

## Agencias de staffing LatAm

| Agencia | Estado | Nota |
|---|---|---|
| **BairesDev** | bolsa propia verificada, `applicants.bairesdev.com` (200) | Sigue siendo la fuente #1 de Flutter remoto en USD. **Queda abierto** el dato de si su ATS trata multiples postulaciones como una sola candidatura de perfil — no se pudo resolver sin iniciar sesion |
| **ScrumLaunch** | ⭐ vacante Flutter LatAm activa | `scrumlaunch.com/careers/senior-flutter-developer-latam-380` — *Senior Flutter Developer (Remote, LatAm)*, fintech. El indice `/careers` es JS puro y no expone las vacantes en el HTML; hay que entrar con navegador |
| **BeOn.tech** | descartada por ahora | Ver tabla de descartadas |
| **Turing** | requiere registro | Ver tabla de descartadas |
| Jobsity · Nearsure · Andela · Gaper · Distillery · Revelo · Lean Tech · Modus Create | **sin bolsa publica accesible** | Todas sus URLs de empleo dieron 404/403/500. Sus vacantes aparecen indirectamente via LinkedIn y RemoteRocketship (que si tiene pagina de empresa: `remoterocketship.com/company/nearsure/`) |
| Wizeline · Koombea · Applaudo · Devsu · Tecla · BlueCoding | boards vivos, **0 Flutter hoy** | `boards.greenhouse.io/wizeline`, `apply.workable.com/koombea`, `applaudostudios.com/careers`, `devsu.com/careers`, `tecla.io/jobs`, `bluecoding.com/jobs` responden 200 pero ninguna menciona Flutter en el HTML actual. Revisar en proximas corridas |

## Reclutadores y comunidades — REQUIEREN ACCION HUMANA DEL USUARIO

> `job-scout` **no** se une, **no** escribe y **no** se registra. Esto es un inventario, nada mas.
> Todo lo de esta seccion lo tiene que hacer Jonathan a mano si le interesa.

| Fuente | Que es | Como se accede |
|---|---|---|
| `esflutter.dev/community/` (200) | Directorio oficial de comunidades Flutter en español | Publico. Lista meetups y grupos por pais — punto de partida para la comunidad Flutter Colombia |
| `flutter.dev/community` (200) | Directorio oficial global (Discord, Reddit, Stack Overflow) | Publico. El **Discord oficial de Flutter** tiene canal de vacantes; unirse = accion humana |
| Telegram — VacantesDigitales | Canal LatAm de vacantes tech; su web esta rancia pero el canal puede estar mas al dia | Requiere Telegram y suscribirse manualmente |
| Telegram — "Ofertas de empleo remoto en STEM para LATAM" | Canal citado como el mas especifico de la region para perfiles tecnicos remotos | Suscripcion manual |
| Telegram — Talently | Talently (ya en Tier 3) publica sus vacantes por Telegram; ver `talently.tech/blog/ofertas-trabajo-para-programador-por-telegram/` (200) | Suscripcion manual |

**No se contacto a ningun reclutador ni se envio ningun mensaje en esta corrida.**
