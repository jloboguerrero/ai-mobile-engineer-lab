# Portales sugeridos

Salida del agente `job-scout` (`/explorar`). **Append-only**: cada corrida agrega una seccion con
fecha; nunca se sobrescriben hallazgos anteriores.

Ninguna entrada aqui llega sin pasar el protocolo de verificacion (dominio resuelve, la URL respeta
el parametro de busqueda, los resultados son Flutter el framework, y hay actividad reciente).

**Nada de este archivo esta activo.** El catalogo que gobierna las aplicaciones reales es
`portales.md`; la promocion de una fuente de aqui hacia alla la aprueba el usuario.

---

<!-- Las corridas de /explorar se agregan debajo, la mas reciente primero -->

# Corrida 2026-08-24 — `/explorar` (los cuatro focos)

Foco: portales · empresas · agencias · comunidades. Todo lo de abajo fue probado contra el sitio
real el 2026-08-24. Se leyo primero `portales.md` completo (incluidos descartados) y la corrida
anterior de este archivo para no repetir trabajo. Nada de aqui esta activo hasta que el usuario lo
promueva a `portales.md`.

## Verificadas y recomendadas

### FlutterGigs — Tier 3 sugerido
- URL probada: `https://fluttergigs.com/jobs` → ~20 vacantes (5 paginas x 4 tarjetas)
- Respeta el parametro: n/a — es un board 100% dedicado a Flutter (no tiene busqueda generica que
  comparar; toda la oferta del sitio es Flutter)
- Los resultados son Flutter real: **si**, confirmado abriendo el detalle de "Senior Mobile
  Developer by PetroApp" (Flutter + iOS, senior, full remote) — descripcion tecnica real, no ruido
- Filtro de fecha: **no visible** en el listado ni en el detalle (limitacion notada, no se pudo
  confirmar antiguedad de las vacantes)
- Login: no para listar · Anti-bot: no · Apply: boton "Get the opportunity" que dice "let Evacorp
  know you found this job on FlutterGigs" — las vacantes parecen intermediadas por una agencia
  (Evacorp) que las publica en nombre de las empresas reales (PetroApp, Cloudwalk, IT LINK, Coding
  Mind), no que Evacorp sea el empleador
- Verificado: 2026-08-24
- Nota: volumen bajo (~20) pero 100% relevante por diseño. Sirve como red de seguridad de bajo
  ruido, similar a Jobgether. La ausencia de fecha visible es su debilidad frente a HiringCafe/DailyRemote

## Verificadas y descartadas — no reintentar

| Fuente | URL probada | Motivo |
|---|---|---|
| **jobsinflutter.com** (tambien resuelve desde `.io`) | `jobsinflutter.com/?q=Flutter` | **Trampa de nombre, no de framework**: es un marketplace de "trabajos para humanos y agentes de IA" sin relacion real con el SDK Flutter. El contador de resultados es **identico** (2.610) con y sin el parametro `q`, y el primer resultado sin filtrar es "Senior Mobile Engineer, iOS" en Mozilla. Mismo patron que "Flutter Brazil" y "Flutter UK & Ireland" de la corrida anterior — el nombre coincide, el contenido no |
| **Jooble** | `jooble.org/SearchResult?ukw=flutter` | **Cloudflare challenge** ("Just a moment...") tanto con `curl` como con navegador real. No se pudo verificar el listado. No reintentar sin razon para creer que quito el anti-bot |
| **DevJobsScanner** (re-verificado) | `devjobsscanner.com/remote-flutter-jobs/` | Confirmado con navegador (la corrida anterior solo probo `curl`, que dio 403): tambien Cloudflare challenge en el navegador. Se mueve de "pendiente" a **descartado definitivo** |
| **WeAreDevelopers** | `wearedevelopers.com/jobs/s/flutter` | Marginal, no descartado del todo pero no recomendado como fuente principal: el filtro `s/flutter` **si cambia el listado** (compare con `/jobs?country=all`, resultados distintos), pero mete bastante ruido — de 20 tarjetas revisadas, ~8 no mencionan Flutter en el titulo ("Tech Lead .Net", "JD Edwards", "Full Stack backend", "Mobile Digital Payments Architect"). El resto si son Flutter real ("Android/Flutter Developer", "Desarrollador Flutter Senior - Cloud/Firebase (Remoto)", "Senior Mobile Engineer (Flutter)"). Mercado fuertemente Europa/Espana. Queda anotado, no recomendado para promocion sin mejor filtrado |

## Empresas nuevas (o actualizadas) confirmadas usando Flutter

Rastreadas hacia atras desde `historial/aplicaciones.json` (empresas que ya tienen una aplicacion
enviada, prueba directa de que la vacante Flutter era real) y desde busqueda de producto:

| Empresa | Evidencia | ATS | Nota |
|---|---|---|---|
| **Tide** (fintech UK) | Multiples vacantes Flutter activas en su board propio | `job-boards.greenhouse.io/tide` (Greenhouse, confirmado por `<title>` real) | Stack calcado: Flutter + Dart + flutter_bloc. Vacantes vistas mayormente Europa/India, verificar aceptacion LatAm caso a caso |
| **Social Discovery Group** (dating/social, incluye Cupid Media) | 3+ vacantes Flutter activas, 1000+ empleados distribuidos globalmente | `social-discovery-ventures.breezy.hr` (Breezy HR) | Buen fit: 3+ anos Flutter/Dart, sin exigir seniority extrema, contrata LatAm |
| **Salmon Group Ltd** (fintech Filipinas) | Ya en `historial/aplicaciones.json` — vacante Flutter real aplicada | `jobs.ashbyhq.com/salmon-group` (slug confirmado real, no el falso-positivo generico de Ashby) | No es LatAm pero ya validada por el propio historial de aplicaciones |
| **Digitech Computer** (actualizacion de entrada existente) | Vacante ya conocida desde 2026-08-18, ahora con ATS localizado via `historial/aplicaciones.json` | `jobs.dayforcehcm.com/en-US/sarnova` (Dayforce, tenant `sarnova` — Digitech es proveedor de Sarnova) | Antes figuraba `ats: ninguno`. Se actualizo la entrada existente en `datos/empresas.json`, no se duplico |

**No se pudo verificar con evidencia solida** (se descarta agregar a `empresas.json` esta corrida):
JIXAAR AI (sin presencia web identificable mas alla de la vacante de LinkedIn ya en el historial) y
"Clinica PsicoSalud" (el nombre de empleador en la vacante de LinkedIn no calza con el titulo
"Marketplace & EdTech Global" — probable error de parsing del nombre real del cliente; no se
encontro una empresa verificable con ese nombre y ese giro).

## Agencias de staffing LatAm

| Agencia | Estado | Nota |
|---|---|---|
| **Rimutee** | bolsa propia real, `rimutee.com` (200) | Plataforma de matching LatAm-remoto (Rimutee OnDemand / Rimutee Hunting), pago en USD como contractor. Ya genero una aplicacion real (`historial/aplicaciones.json`, vacante "Desarrollador Flutter" via RemoteRocketship). No se creo cuenta ni se navego el flujo de registro, solo se confirmo que la empresa y el modelo son reales |
| **DevFixr** | staffing UK-LatAm/offshore, sin board propio con buscador | Empresa real (staff augmentation UK con desarrolladores offshore), ya genero una aplicacion real en el historial ("Senior Flutter Developer" via RemoteRocketship). Sus vacantes se ven mejor indirectamente via RemoteRocketship/Jobaaj que en su propio sitio |
| **BairesDev** | sin cambios desde 2026-08-18 | El dato de si multiples postulaciones cuentan como una sola candidatura de perfil **sigue abierto** — no resoluble sin iniciar sesion, y `job-scout` no crea cuentas |

## Reclutadores y comunidades — REQUIEREN ACCION HUMANA DEL USUARIO

> `job-scout` **no** se une, **no** escribe y **no** se registra. Esto es un inventario, nada mas.

| Fuente | Que es | Como se accede |
|---|---|---|
| `github.com/workifit/latam-tech-communities` (200) | Directorio curado en GitHub de comunidades tech LatAm en Slack/Discord, incluye entradas de Flutter (menciona Flutter Medellin) | Publico, de solo lectura. Punto de partida mejor que buscar comunidades una por una |
| `github.com/FlutterComunidadeBR` (200) | Organizacion de GitHub de la comunidad Flutter de Brasil | Publico. Utilidad limitada para LatAm hispanohablante pero relevante si se amplia la busqueda a Brasil (ya aparecen vacantes PT-BR descartadas en el historial) |

**No se contacto a ningun reclutador ni se envio ningun mensaje en esta corrida.**

---

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
