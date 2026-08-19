---
description: Descubre y verifica nuevas fuentes de vacantes Flutter (portales, empresas, agencias)
argument-hint: [portales|empresas|agencias|comunidades]
---

Invoca el subagente `job-scout` (Agent tool, `subagent_type: "job-scout"`) con estas instrucciones:

> Ejecuta una corrida de descubrimiento siguiendo tu runbook completo.
> Foco de esta corrida: `$ARGUMENTS`
>
> - Sin argumentos → los cuatro focos (portales, empresas, agencias, comunidades).
> - Un foco especifico → solo ese.
>
> Recuerda: ninguna fuente entra a `portales-sugeridos.md` sin pasar el protocolo de verificacion,
> y no escribes en `portales.md` — eso lo decide el usuario a partir de tus recomendaciones.

Cuando el agente termine, muestra al usuario sus recomendaciones de promocion a `portales.md` y
pregunta cuales quiere que se promuevan. Solo entonces edita `portales.md`.
