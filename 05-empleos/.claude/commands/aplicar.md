---
description: Busca ofertas Flutter de las ultimas 24h, las puntua y aplica tras tu aprobacion
argument-hint: [portal] [--dry-run]
---

Invoca el subagente `job-apply` (Agent tool, `subagent_type: "job-apply"`, `run_in_background: false`)
con estas instrucciones:

> Ejecuta una corrida de busqueda y aplicacion siguiendo tu runbook completo.
> Argumentos de esta corrida: `$ARGUMENTS`
>
> - Sin argumentos → todos los portales de `portales.md`.
> - Nombre de portal (`linkedin`, `indeed`, `glassdoor`, `remotos`, `latam`) → solo ese tier.
> - `--dry-run` → ejecuta Fases 0–3 y para en la tabla de aprobacion. No envies nada.
>
> Recuerda: la Fase 3 es una parada obligatoria incluso sin `--dry-run`.

Cuando el agente devuelva la lista de la Fase 3, **muestrasela al usuario tal cual** y espera su
aprobacion. Solo entonces continua el agente con la Fase 4 (via SendMessage).
