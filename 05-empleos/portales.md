# Portales — URLs de busqueda verificadas

> **Regla del catalogo: ninguna URL entra aqui sin probarse contra el portal real.**
> El 2026-08-18 cuatro URLs escritas de memoria (una `geoId` de Asia-Pacifico etiquetada como LatAm,
> un dominio inexistente, un 404, y tres portales que ignoran el parametro de busqueda) dejaron una
> corrida entera en cero. Verificar cuesta un minuto; no verificar cuesta un dia de busqueda.
> El agente `job-scout` (`/explorar`) aplica este protocolo antes de proponer cualquier fuente.

Catalogo que consume el agente `job-apply`. Las URLs traen filtro de fecha donde el portal lo soporta;
la ventana efectiva la decide `job-apply` con su regla adaptativa. Si un portal no soporta el
filtro, la columna dice como leer la fecha del listado.

Este archivo se alimenta de `job-scout` (`/explorar`), que propone en `portales-sugeridos.md`;
el usuario decide que se promueve aqui.

---

## Tier 1 — Alto volumen (prioridad en cada corrida)

### LinkedIn
Requiere sesion iniciada. `f_TPR=r86400` = ultimas 24h · `f_WT=2` = remoto · `geoId=92000000` = mundial.

> **`geoId=92000000` (Worldwide) es obligatorio.** Sin parametro de ubicacion, LinkedIn inyecta la
> ubicacion por defecto de la cuenta (Estados Unidos) y la busqueda devuelve 0 resultados utiles o
> puro EE.UU. con work-authorization requerida. Verificado en la corrida del 2026-08-18.

- Flutter remoto, mundial, 24h:
  `https://www.linkedin.com/jobs/search/?keywords=Flutter&geoId=92000000&f_TPR=r86400&f_WT=2&sortBy=DD`
- Flutter Colombia, 24h:
  `https://www.linkedin.com/jobs/search/?keywords=Flutter&location=Colombia&f_TPR=r86400&sortBy=DD`
- Flutter LatAm (captura vacantes regionales que no salen en la mundial):
  `https://www.linkedin.com/jobs/search/?keywords=Flutter%20Developer&location=Latin%20America&f_TPR=r86400&sortBy=DD`

> **No uses `geoId=91000003` para LatAm — es Asia-Pacifico.** Devuelve 400+ vacantes presenciales en
> India. Para LatAm usa `location=Latin%20America`. Verificado en la corrida del 2026-08-18.
- Mobile Developer Flutter, mundial, 24h (ofertas sin "Flutter" en el titulo):
  `https://www.linkedin.com/jobs/search/?keywords=Mobile%20Developer%20Flutter&geoId=92000000&f_TPR=r86400&f_WT=2&sortBy=DD`

> **No uses `f_AL=true` (Easy Apply)** en las busquedas de Flutter: casi ninguna vacante Flutter
> LatAm/remota usa Easy Apply, ese filtro solo borra resultados validos. La mayoria salen a un ATS
> externo, que el agente sabe manejar.

> **Cuidado**: LinkedIn detecta automatizacion. Una pagina a la vez, sin ráfagas de clicks.
> Si aparece un challenge de seguridad, parar la corrida en LinkedIn y avisar al usuario.

### Indeed
`fromage=1` = ultimo dia. Cloudflare/CAPTCHA frecuente → si aparece, saltar el portal y avisar.

- `https://www.indeed.com/jobs?q=Flutter+developer&l=Remote&fromage=1&sort=date`
- `https://co.indeed.com/jobs?q=Flutter&fromage=1&sort=date`

### Glassdoor
`fromAge=1` = ultimo dia. Requiere sesion iniciada para ver muchas ofertas.

- `https://www.glassdoor.com/Job/remote-flutter-developer-jobs-SRCH_IL.0,6_IS11047_KO7,24.htm?fromAge=1`
- Colombia: usar el buscador de `https://www.glassdoor.com/Job/index.htm` con keyword `Flutter` y
  pais Colombia, luego aplicar el filtro de fecha en la UI.

> **`glassdoor.com.co` no existe** (NXDOMAIN, verificado 2026-08-18). No reintentar ese dominio.

---

## Tier 2 — Remotos globales (poco anti-bot, buen fit)

| Portal | URL | Filtro 24h |
|---|---|---|
| RemoteOK | `https://remoteok.com/remote-flutter-jobs` | fecha visible en cada fila ("1d", "2d") |
| WeWorkRemotely | `https://weworkremotely.com/remote-jobs/search?term=flutter` | fecha en el detalle |
| Himalayas | `https://himalayas.app/jobs?q=flutter&sortBy=recent` | ⚠️ Cloudflare challenge (2026-08-18). Si bloquea, saltar — nunca resolverlo |
| **Wellfound** | `https://wellfound.com/jobs?q=flutter` | requiere sesion. **Mejor fuente de Flutter senior LatAm hasta ahora** — ver nota abajo |
| **HiringCafe** | `https://hiring.cafe/?searchState=%7B%22searchQuery%22%3A%22flutter%22%2C%22workplaceTypes%22%3A%5B%22Remote%22%5D%2C%22defaultToUserLocation%22%3Afalse%2C%22sortBy%22%3A%22date%22%7D` | ordenado por fecha; leer la antiguedad en cada tarjeta — ver nota abajo |
| RemoteRocketship | `https://www.remoterocketship.com/?page=1&sort=DateAdded&jobTitle=Flutter` | orden por fecha. Trae seniority y pais en el listado. Requiere navegador (`curl` da 403) |

> ⚠️ **No uses `wellfound.com/role/l/flutter-developer/latin-america`**: responde 200 pero redirige
> descartando la ubicacion y devuelve mercado India en rupias. Mantener `wellfound.com/jobs?q=flutter`.
> Verificado 2026-08-18.
>
> **Wellfound publica poco pero de mucha calidad** para este perfil. La ventana adaptativa
> (ver Fase 1 de `job-apply.md`) ya lo cubre: como aqui aparece poco, la ventana se estira sola
> hasta 7 dias. No hace falta una excepcion manual.
>
> ⚠️ Wellfound usa **"Apply on company website"**: no aloja el formulario. El agente tiene un
> fallback que intenta extraer la URL destino y, si no puede, deja la oferta en
> `historial/pendientes-manual.md` con el link.

> **HiringCafe — el `searchState` completo es obligatorio.** `defaultToUserLocation:false` es la
> parte critica: sin el, el portal arranca en la ubicacion de la IP (EE.UU.) y repite la trampa del
> `geoId` de LinkedIn. `dateFetchedPastNDays` se acepta pero **no filtra** — no confiar en el; usar
> `sortBy:"date"` y leer la fecha de cada tarjeta. Fuente de mayor caudal del catalogo (346 vacantes
> Flutter remotas al promoverlo, la mas reciente de hace 21h) y cada tarjeta enlaza al ATS original.
> Promovido desde `portales-sugeridos.md` el 2026-08-18.

**Descartados del Tier 2** (ignoran el parametro de busqueda y redirigen al listado completo,
verificado 2026-08-18): Working Nomads, JustRemote.

---

## Tier 3 — LatAm / Colombia

| Portal | URL | Nota |
|---|---|---|
| Torre.ai | `https://torre.ai/search/jobs?q=Flutter` | buen match con perfil LatAm senior |
| GetOnBoard | `https://www.getonbrd.com/jobs-mobile-development?q=flutter` | Chile/LatAm, ofertas en USD |
| Computrabajo CO | `https://co.computrabajo.com/trabajo-de-flutter?pubdate=1` | `pubdate=1` = ultimo dia |
| Talently | `https://talently.tech/` → buscador interno, keyword `Flutter` | LatAm remoto, USD. La ruta `/empleos?search=` da **404** (verificado 2026-08-18) |
| DailyRemote | `https://www.dailyremote.com/remote-jobs?search=flutter` | **raspable con `curl` puro** — trae `datePosted` exacto en JSON-LD, sin gastar navegador |
| Jobgether | `https://jobgether.com/search-offers?role=flutter-developer&location=latam` | marginal (8 vacantes al promoverlo). `location=latam` **no restringe nada**; la ruta `/remote-jobs/latam/flutter-developer` da **410** |

**Descartado del Tier 3**: elempleo — ignora el parametro `Search` y redirige al listado completo.

---

## Boards de empresa (ATS directos)

Cuando la oferta viene de LinkedIn/Indeed pero el "Apply" lleva a un ATS, el agente rellena
directamente ahi. Los cuatro que cubren la mayoria:

- **Greenhouse** (`boards.greenhouse.io`) — formulario simple, upload de CV, preguntas EEO.
- **Lever** (`jobs.lever.co`) — formulario simple, campo de cover letter.
- **Ashby** (`jobs.ashbyhq.com`) — parsea el CV y autocompleta; **verificar** lo que autocompleto.
- **Workday** (`*.myworkdayjobs.com`) — pide crear cuenta → **saltar y avisar al usuario**.

> ⚠️ **`jobs.ashbyhq.com/<slug>` devuelve 200 para cualquier slug inventado** (verificado
> 2026-08-18). El codigo HTTP no prueba que el board exista: validar por el `<title>` — si dice
> "Jobs" a secas, el board no existe.

---

## Portales descartados

| Portal | Motivo |
|---|---|
| ZipRecruiter | exige crear cuenta antes de ver/aplicar |
| Dice | mercado US con requisito de work authorization |
| Monster | volumen de Flutter practicamente nulo |
| Remotive · NoDesk · Arc.dev (`?q=`) | ignoran el parametro de busqueda (2026-08-18) |
| Arc.dev `/flutter` | falso positivo: devuelve "Flutter UK & Ireland" (casa de apuestas), no el framework |
| flutterjobs.info | portal muerto — ultima vacante de julio de 2020 |
| VacantesDigitales (web) | portal muerto — ultima vacante de abril |
| Jobicy · DevJobsScanner | anti-bot |
| Turing · BeOn.tech | exigen registro antes de ver las vacantes |
