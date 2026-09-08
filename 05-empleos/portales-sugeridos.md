# Portales sugeridos

Salida del agente `job-scout` (`/explorar`). **Append-only**: cada corrida agrega una seccion con
fecha; nunca se sobrescriben hallazgos anteriores.

Ninguna entrada aqui llega sin pasar el protocolo de verificacion (dominio resuelve, la URL respeta
el parametro de busqueda, los resultados son Flutter el framework, y hay actividad reciente).

**Nada de este archivo esta activo.** El catalogo que gobierna las aplicaciones reales es
`portales.md`; la promocion de una fuente de aqui hacia alla la aprueba el usuario.

---

<!-- Las corridas de /explorar se agregan debajo, la mas reciente primero -->

# Corrida 2026-09-07 — `/explorar` (los cuatro focos)

Foco: portales · empresas · agencias · comunidades. Se leyo `portales.md` completo (incluidos
descartados) y las tres corridas anteriores de este archivo antes de buscar. Nada de lo de abajo
esta activo hasta que el usuario lo promueva a `portales.md`.

## Verificadas y recomendadas

### Built In (builtin.com) — Tier 3 sugerido (marginal, con ruido)
- URL probada: `https://builtin.com/jobs?search=flutter` → **49 menciones de "flutter" en el HTML**
  (via `curl`), 9 tarjetas visibles en la primera pagina del listado renderizado
- Respeta el parametro: **si** — `https://builtin.com/jobs` (sin `search`) da **0** menciones de
  "flutter" en el mismo `curl`; con navegador el listado cambia por completo
- Los resultados son Flutter real: **mixto**. De las 9 tarjetas solo 2 son Flutter autentico:
  "Bolder Apps — Mobile App Developer (Flutter / React Native)" (mid, remoto, 6 ubicaciones) e
  "Immiland Canada Inc. — iOS & Flutter Developer" (senior, remoto, Colombia). El resto es ruido —
  Sales Engineer, QA Engineer Mobile, Product Engineer, Technical Project Manager, Senior QA — el
  buscador hace match por texto en toda la descripcion, no por titulo. Mismo patron que
  mobile.career/WeAreDevelopers ya anotado en corridas previas
- Filtro de fecha: no en la URL; cada tarjeta trae antiguedad relativa ("11 Days Ago", "16 Days Ago")
- Login: no para listar · Anti-bot: no (`curl` entra a 200) · Apply: sale al sitio/ATS de cada empresa
- Mas reciente: 11 dias (Bolder Apps) · Verificado: 2026-09-07
- Nota: volumen bajo de resultados Flutter reales (2 de 9) y la vacante mas reciente ya tiene 11
  dias. Util como red de seguridad adicional de muy bajo caudal, mismo nivel que mobile.career —
  requiere revisar cada tarjeta a mano, no automatizable sin falsos positivos

## Verificadas y descartadas — no reintentar

| Fuente | URL probada | Motivo |
|---|---|---|
| **Lemon.io** | `lemon.io/` | Marketplace de contratistas freelance (te registras a la red de "vetted developers", no hay listado de vacantes puntuales por URL). Mismo patron que Toptal/Flexiple ya anotados el 2026-08-31: incompatible con el flujo de `job-apply` de aplicar por oferta |
| **GoFasti** | `gofasti.com` / `gofasti.com/careers` (404) | Agencia de staffing LatAm con modelo lead-gen: el sitio es para que **empresas** pidan talento, no hay buscador de vacantes publicas. La ruta `/careers` (bolsa interna para "GoFastees") da 404. Se mueve a la tabla de agencias, no como portal |
| **Truelogic Software** | `truelogic.io/careers/` (404) | Aparecio en Built In con "Mobile Engineer - Open Application" pero su propia pagina de careers no resuelve. Sin bolsa propia verificable esta corrida |
| **Software Estratégico** | `softwareestrategico.com/careers` (timeout/000) | Empresa colombiana real (aparece repetida en Built In: "Mobile Engineer", "Senior QA"), pero su sitio no respondio en esta corrida. Reintentar en la proxima |

## Empresas nuevas (o actualizadas) confirmadas usando Flutter

| Empresa | Evidencia | ATS | Nota |
|---|---|---|---|
| **HighLevel** | Vacante "Software Development Engineer III (Mobile - Flutter)" ya vista y descartada en `historial/descartadas.json` (2026-08-xx) por exigir autorizacion de trabajo en India en el formulario real | `jobs.lever.co/gohighlevel` (Lever, confirmado 200) | SaaS de marketing/CRM, distribuida globalmente. La vacante concreta pedia work-auth India, pero vale la pena revisar otras vacantes mobile de la empresa — tienen ATS directo (Lever) |
| **Tracsis** | Vacante "Flutter Developer" ya vista y descartada por exigir "right to work in the UK" en el formulario real | `tracsis.careers.hibob.com` (Hibob, confirmado 200) | Empresa de software ferroviario UK. Work-auth UK bloquea a Jonathan, pero confirma ATS directo por si cambia de politica |
| **Immiland Canada Inc.** | Vacante "iOS & Flutter Developer", Colombia, senior, remoto — vista en Built In (builtin.com) | ninguno localizado (`immiland.com/careers` redirige a `immimentary.com`, bloqueado por Cloudflare) | Agencia de inmigracion/RRHH con sede Montreal, contratando explicitamente en Colombia. Alto fit geografico, ATS no localizado esta corrida |
| **Bolder Apps — AI Native AgentCy** | Vacante "Mobile App Developer (Flutter / React Native)" republicada identica en Colombia, Mexico, Argentina, Chile, Brasil, Costa Rica (LinkedIn), RemoteRocketship y Built In | ninguno localizado | Nivel mid explicito en la descripcion ("hiring a mid-level mobile developer"), no encaja hoy pero republica seguido — vale la pena revisar si algun dia abre senior |

## Agencias de staffing LatAm

| Agencia | Estado | Nota |
|---|---|---|
| **GoFasti** | agencia real, `gofasti.com` (200), modelo lead-gen | Contrata en Brasil, Argentina, Colombia, Uruguay, Mexico, El Salvador, Panama segun su propio FAQ. Sin bolsa publica de vacantes — las empresas piden talento y GoFasti empareja. La ruta de "Find Work / Careers" es para roles internos de GoFasti (RRHH, DevOps, etc.), no para vacantes de clientes. No aplica al flujo de `job-apply` de buscar-por-URL |
| **Truelogic Software** | staffing LatAm remoto, sin bolsa propia con buscador | Aparece en Built In con "Mobile Engineer - Open Application" (candidatura abierta, no vacante puntual). Su propio `/careers/` no resuelve — seguir rastreando via Built In/RemoteRocketship |
| **Moovx** (Uruguay) | mencionada en busqueda web (Sr. Flutter Developer remoto LatAm) pero no se pudo confirmar bolsa propia con buscador en esta corrida | Pendiente de verificar en proxima corrida — el sitio respondio 200 pero no se encontro seccion de careers accesible por `curl` |

## Reclutadores y comunidades — REQUIEREN ACCION HUMANA DEL USUARIO

> `job-scout` **no** se une, **no** escribe y **no** se registra. Esto es un inventario, nada mas.

| Fuente | Que es | Como se accede |
|---|---|---|
| `fluttermedellinmeetup.github.io/main/` (200) | Comunidad Flutter Medellin — pagina propia (mas especifica que el directorio generico `esflutter.dev` ya listado), menciona canal de **Slack** con ofertas de empleo | Publico. Unirse al Slack es accion humana del usuario |
| `meetup.com/flutter-buenos-aires/` (200) | Meetup activo de Flutter Buenos Aires | Publico, requiere cuenta de Meetup para RSVP |
| `meetup.com/flutter-lima/` (200) | Meetup activo de Flutter Lima | Publico, requiere cuenta de Meetup para RSVP |
| `meetup.com/flutter-arequipa/` | Meetup de Flutter Arequipa (Peru) | No verificado con HTTP esta corrida — anotado desde busqueda, pendiente confirmar en vivo |
| LatamRecruit (`linkedin.com/company/latamrecruitcom`) | Empresa de headhunting tech especializada en LatAm | Perfil de LinkedIn — contacto es accion humana del usuario |
| Lupa (`lupahire.com/hire/flutter-developers`) | Agencia de recruiting tech que anuncia acceso a desarrolladores Flutter LatAm ($40-65/h) — orientada a **empresas que contratan**, no a candidatos que buscan | Solo informativo: confirma que hay demanda de Flutter LatAm en el mercado de recruiting, no es una fuente de vacantes para aplicar |

**No se contacto a ningun reclutador ni se envio ningun mensaje en esta corrida.**

---

# Corrida 2026-08-31 — `/explorar` (los cuatro focos)

Foco: portales · empresas · agencias · comunidades. Se leyo `portales.md` completo (incluidos
descartados) y las dos corridas anteriores de este archivo antes de buscar. Nada de lo de abajo
esta activo hasta que el usuario lo promueva a `portales.md`.

## Verificadas y recomendadas

### mobile.career — Tier 3 sugerido (marginal, con ruido)
- URL probada: `https://mobile.career/flutter-developer-jobs` → **15+ vacantes** listadas como "Flutter"
- Respeta el parametro: **si** — comparado contra `https://mobile.career/jobs` (bolsa general, sin
  filtro) el listado es distinto (Wise, BJAK, Capital One, Comcast generico vs. el filtrado que trae
  Comcast Mobile Engineer *Flutter*, Asaas, Konfío)
- Los resultados son Flutter real: **mixto**. Confirmados reales: Comcast "Mobile Engineer - Android
  and Flutter" (11 ago), Asaas "Tech Leader Mobile" Brasil remoto (8 ago), Comcast "Mobile Engineer -
  iOS and Flutter" (29 jul), Konfío "Mobile Engineer Sr." Mexico hibrido Flutter/Dart (3 jun). Pero
  el filtro tambien mete vacantes sin Flutter (Comcast "Mobile Engineer - Android" sin mencion de
  Flutter, JPMorgan "Lead Architect - iOS", BUSUP Android/iOS) — mismo patron de ruido que
  WeAreDevelopers, ya anotado en la corrida anterior
- Filtro de fecha: no en la URL, cada tarjeta trae fecha exacta de publicacion
- Login: no · Anti-bot: no (`curl` entra a 200) · Apply: sale al ATS/sitio de cada empresa
- Mas reciente: 11 de agosto (Comcast) · Verificado: 2026-08-31
- Nota: volumen bajo y mercado mayormente US/Brasil, una vacante Mexico (Konfío). Util como red de
  seguridad adicional, no como fuente principal — el ruido obliga a revisar cada tarjeta a mano

## Verificadas y descartadas — no reintentar

| Fuente | URL probada | Motivo |
|---|---|---|
| **EchoJobs** | `echojobs.io/?query=flutter` | **Ignora el parametro de URL**: la pagina siempre muestra el feed generico "latest openings" sin relacion con la busqueda (Assistant Engineering Manager, DevSecOps, etc.). El buscador real vive detras de una interaccion de UI/membresia de pago, no de la URL |
| **Landing.Jobs** | `landing.jobs/jobs?search=flutter` | Respeta el parametro (1 resultado vs. 54 sin filtro) pero **no hay Flutter real**: el unico resultado es un "Founding Full Stack Software Engineer" sin relacion con el framework. Mercado casi 100% Portugal/hibrido backend — sin señal para este perfil |
| **Jobspresso** | `jobspresso.co/?s=flutter` | Respeta el parametro (1 resultado) pero es falso positivo: "Social Media Coordinator" en FanDuel (casa de apuestas — "flutter" en el sentido de apuesta, mismo patron que "Flutter UK & Ireland" y "Flutter Brazil" de corridas previas) |
| **Startup.jobs** | `startup.jobs/?search=flutter&remote=true` | **Ignora el parametro completo**: el listado con `search=flutter` muestra las mismas vacantes genericas (Customer Success, Strategy & Operations, AI Researcher) que la portada sin filtrar |
| **jobsinflutter.com/.io** (re-verificado) | `jobsinflutter.com` (`.io` redirige al mismo sitio) | Re-confirma el hallazgo de la corrida 2026-08-24: trampa de nombre. La pagina de inicio mostro como resultado destacado "Mozilla — Senior Product Manager, Mobile", sin relacion con el framework Flutter |
| **Toptal / Flexiple** | n/a | No se probaron a fondo: son marketplaces de contratistas freelance (te registras a la red, no aplicas a una vacante puntual), incompatibles con el flujo de `job-apply` de aplicar por oferta. Anotado para que no se reintenten esperando un listado convencional |

## Empresas nuevas (o actualizadas) confirmadas usando Flutter

Rastreadas hacia atras desde `historial/aplicaciones.json` (vacantes ya vistas/aplicadas 2026-08-25
a 2026-08-27, que no estaban todavia en `datos/empresas.json`):

| Empresa | Evidencia | ATS | Nota |
|---|---|---|---|
| **Atos** (IT services, Francia, global) | Vacante "Flutter developer" Mexico City, home office, ya aplicada el 2026-08-25 | `jobs.atos.net` (portal propio de Atos, confirmado 200) | Corporativo grande de consultoria/outsourcing con presencia LatAm real (Mexico City) |
| **Modus Create** (consultoria digital remota, 55+ paises) | Vacante "Principal Mobile Engineer (Flutter / React Native, AI-Assisted Development)" Mexico, ya aplicada el 2026-08-27 — confirmada de nuevo en vivo el 2026-08-31 en `moduscreate.com/careers` junto a otras vacantes abiertas en Mexico, Colombia y Costa Rica | Greenhouse embebido en `moduscreate.com/careers` (el board publico `job-boards.greenhouse.io/moduscreate` redirige al mismo sitio) | Contrata LatAm activamente (Mexico/Colombia/Costa Rica visibles el mismo dia). Bonus hibrido de `job-apply` (+10 Flutter/IA) aplica directo a este puesto |
| **memodio** (app medica de salud cognitiva, Alemania) | Vacante "Flutter & Node.js Fullstack Engineer (f/m/d) - Fully Remote", ya aplicada el 2026-08-27 | `join.com/companies/memodio` (ATS Join, confirmado con 2 vacantes activas) | Empresa chica (11-50 empleados), 100% remoto declarado, pero freelance/contract y rango €35k-55k — verificar si acepta LatAm caso a caso |
| **Synmatch AI** (plataforma de hiring global, fundada 2025) | 2 vacantes activas: "Mobile App Developer - Cross Platform Flutter (iOS, Android, Windows)" y "Lead Architect - Cross-Platform Flutter" | `synmatchai.teamtailor.com/jobs` (Teamtailor, confirmado 200) | Base principal en Bengaluru/India con remoto; no confirmado si acepta LatAm — la mision declarada de la empresa es "hacer la contratacion global", vale la pena probar |
| **Labils** (consultoria digital/IA, Londres) | Vacante "Senior Software Engineer (Flutter)" vista en LinkedIn, ya aplicada el 2026-08-27 | `labils.com/careers` (200, sin ATS de terceros identificado en esta corrida — pendiente confirmar el flujo real de aplicacion) | Empresa chica, boutique. Confirmar en proxima corrida si `careers` lista la vacante o si ya cerro |

**Descartado esta corrida** (no se agrega a `empresas.json`): "Modus Jobs" en `jobs.ashbyhq.com/modus`
es una **empresa distinta** (firma de auditoria/impuestos en Nueva York, vacantes de Audit/Tax/M&A) —
no confundir con Modus Create pese al slug parecido. Confirma otra vez la regla de Ashby: el slug
responde 200 pero hay que leer el `<title>` y el contenido, no solo el codigo HTTP.

## Agencias de staffing LatAm

Sin hallazgos nuevos esta corrida. Se reintento `Jobsity` por busqueda general (motivada por su
aparicion recurrente en el historial de corridas previas) sin encontrar board propio nuevo — sigue
sin bolsa publica accesible, como ya consta en `portales.md`. El dato abierto de **BairesDev**
(si multiples postulaciones cuentan como una sola candidatura) sigue sin resolver — requiere sesion
iniciada, fuera del alcance de `job-scout`.

## Reclutadores y comunidades — REQUIEREN ACCION HUMANA DEL USUARIO

> `job-scout` **no** se une, **no** escribe y **no** se registra. Esto es un inventario, nada mas.

| Fuente | Que es | Como se accede |
|---|---|---|
| `flutterconflatam.dev` (200) | FlutterConf Latam 2026 — la conferencia de Flutter mas grande de LatAm, con sponsor oficial de Google/Flutter. Edicion 2026 el 22-23 de septiembre en Cancun, Mexico | Publico. Sitio de la conferencia + canales en Facebook/YouTube/Instagram (`facebook.com/flutterconflatam`, `youtube.com/@FlutterConfLatam`). Asistir/hacer networking ahi es accion humana del usuario, no algo que este agente pueda hacer |
| Discord oficial `FlutterDev` (`discord.com/invite/rflutterdev`) | Servidor Discord con 73.000+ miembros de la comunidad Flutter (no oficial de Google, pero el mas grande y activo) | Requiere unirse manualmente. No confirmado si tiene canal de vacantes dedicado — revisar al entrar |

**No se contacto a ningun reclutador ni se envio ningun mensaje en esta corrida.**

---

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
