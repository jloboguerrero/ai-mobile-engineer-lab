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
Requiere sesion iniciada. **No hay una lista fija de URLs: se generan por regla** desde
`datos/linkedin-geos.json` (27 paises + 2 regionales). Plantilla:

```
https://www.linkedin.com/jobs/search/?keywords={Q}&geoId={GEO}&f_TPR={TPR}&sortBy=DD[&f_WT=2][&start={N}]
```

**`{Q}` — dos consultas booleanas por ubicacion.** LinkedIn acepta `OR`, `AND` y comillas en
`keywords`. Dos consultas cubren los cinco titulos que el usuario buscaba a mano (Flutter, Flutter
Developer, Mobile Developer, Mobile Engineer, Dart Developer) sin disparar a 5 paginas por pais:

| | keywords (sin encodear) | keywords (URL-encoded) |
|---|---|---|
| Q1 | `("Flutter" OR "Dart")` | `%28%22Flutter%22%20OR%20%22Dart%22%29` |
| Q2 | `("Mobile Developer" OR "Mobile Engineer") AND Flutter` | `%28%22Mobile%20Developer%22%20OR%20%22Mobile%20Engineer%22%29%20AND%20Flutter` |

Q1 trae los titulos que dicen Flutter o Dart. Q2 trae los puestos moviles genericos que solo
mencionan Flutter en el cuerpo — los que la busqueda por titulo se pierde.

**`{GEO}` — geoId verificado**, tomado de `datos/linkedin-geos.json`. Nunca de memoria.
Un pais con `geoId: null` **se salta y se reporta en la Fase 5**; no se adivina.
`geoId=92000000` (Worldwide) sigue siendo consulta valida y ya esta verificada.

> **El parametro de ubicacion es obligatorio.** Sin el, LinkedIn inyecta la ubicacion por defecto
> de la cuenta (Estados Unidos) y la busqueda devuelve 0 resultados utiles o puro EE.UU. con
> work-authorization requerida. Verificado en la corrida del 2026-08-18.

> **No uses `geoId=91000003` para LatAm — es Asia-Pacifico.** Devuelve 400+ vacantes presenciales
> en India. Para LatAm como region usa `location=Latin%20America`, que si esta verificada y va
> como consulta extra fuera de la matriz por pais.

**`{TPR}` — sale de la ventana adaptativa, no es fijo.** Ver la tabla de mapeo en la Fase 1 de
`.claude/agents/job-apply.md`. `r86400` = 24h, `r172800` = 2d, `r259200` = 3d, `r604800` = 7d.

**`f_WT=2` (remoto) — se agrega si y solo si `remotoObligatorio == true`.** Regla del usuario:
en **Colombia** valen presencial, hibrido y remoto (la URL de Colombia va **sin** `f_WT`); en
**cualquier otro pais**, solo remoto. En `linkedin-geos.json` Colombia es el unico pais con
`remotoObligatorio: false`.

**`{N}` — paginacion, omitido en la primera pagina.** LinkedIn sirve los resultados en bloques de
25 y ademas virtualiza el listado (no renderiza las 25 de una, hay que hacer scroll dentro de la
pagina para que carguen — ver "Profundidad en LinkedIn" en la Fase 1 de `job-apply.md`). Verificado
en vivo el 2026-08-22: una busqueda de EE.UU. con 43 resultados solo mostraba 7 tarjetas sin
scroll, y `&start=25` devolvio las 18 restantes (confirmadas distintas a la pagina 1, no repetidas).
El agente pagina hasta agotar el listado o hasta el tope de 2 paginas (50 resultados) por
combinacion pais x consulta — ver el mismo apartado para el detalle y el manejo del tope.

Ejemplos generados (con ventana de 24h):

- Colombia, Q1, sin filtro de modalidad:
  `https://www.linkedin.com/jobs/search/?keywords=%28%22Flutter%22%20OR%20%22Dart%22%29&geoId={CO}&f_TPR=r86400&sortBy=DD`
- Mexico, Q1, solo remoto:
  `https://www.linkedin.com/jobs/search/?keywords=%28%22Flutter%22%20OR%20%22Dart%22%29&geoId={MX}&f_TPR=r86400&f_WT=2&sortBy=DD`
- Mundial, Q2, solo remoto:
  `https://www.linkedin.com/jobs/search/?keywords=%28%22Mobile%20Developer%22%20OR%20%22Mobile%20Engineer%22%29%20AND%20Flutter&geoId=92000000&f_TPR=r86400&f_WT=2&sortBy=DD`
- LatAm regional (usa `location=`, no `geoId`):
  `https://www.linkedin.com/jobs/search/?keywords=%28%22Flutter%22%20OR%20%22Dart%22%29&location=Latin%20America&f_TPR=r86400&f_WT=2&sortBy=DD`

#### Rutina de verificacion de geoId (una vez por pais, antes de usarlo)

La ejecuta `job-scout`, o el usuario a mano. Por cada pais con `geoId: null`:

1. `navigate` a `https://www.linkedin.com/jobs/search/?keywords=Flutter&location=<Pais>`.
2. Leer la URL resultante con `javascript_tool` (`location.href`): LinkedIn resuelve el texto a
   `geoId=<n>` y lo reescribe en la barra de direcciones.
3. Leer 3 ubicaciones del listado y confirmar que son de ese pais.
4. Escribir `geoId` y `verificado: "<fecha ISO>"` en `datos/linkedin-geos.json`.

**Selector de tarjeta verificado (2026-08-22):** `li[data-occludable-job-id]`. El contenedor que lo
envuelve usa clases hasheadas que LinkedIn rota seguido (confirmado en la misma verificacion) —
nunca fijes esa clase de memoria en el script de scroll; sube por los padres hasta encontrar el
elemento que scrollea (`scrollHeight > clientHeight`). Rutina completa en "Profundidad en LinkedIn"
de la Fase 1 de `job-apply.md`. Si `li[data-occludable-job-id]` deja de existir en una corrida
futura, es señal de que LinkedIn cambio el markup: re-verificar con `read_page` antes de asumir que
el listado esta vacio.

> **No uses `f_AL=true` (Easy Apply)** en las busquedas de Flutter: casi ninguna vacante Flutter
> LatAm/remota usa Easy Apply, ese filtro solo borra resultados validos. La mayoria salen a un ATS
> externo, que el agente sabe manejar.

> **Cuidado, y ahora mas que antes**: la matriz son ~56 URLs de LinkedIn por corrida (27 paises
> x 2 consultas, mas las 2 regionales). LinkedIn detecta automatizacion. Recorre **tier por tier**
> (A -> B -> C -> D), **una URL de la matriz a la vez**, sin rafagas de navegaciones entre paises o
> consultas. Esto no aplica al scroll ni a la segunda pagina (`&start=25`) **dentro** de una misma
> URL — eso es lectura normal de un listado largo, no una rafaga, y es necesario: sin scroll el
> agente solo ve ~7 de cada listado (ver "Profundidad en LinkedIn", Fase 1 de `job-apply.md`). Al
> primer challenge de seguridad: **parar LinkedIn entero**, avisar al usuario, y dejar sin avanzar
> la marca de los tiers no escaneados — la ventana adaptativa hara que manana se miren con ventana
> mas ancha.

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
| FlutterGigs | `https://fluttergigs.com/jobs` | board 100% dedicado a Flutter, ~20 vacantes, sin login ni anti-bot. **Sin filtro de fecha visible**; Apply pasa por la agencia Evacorp en nombre del empleador real. Promovido desde `portales-sugeridos.md` el 2026-08-24 |

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
