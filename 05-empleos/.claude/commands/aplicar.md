---
description: Busca ofertas Flutter dentro de la ventana adaptativa, las puntua y aplica tras tu aprobacion
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

El propio subagente pide la aprobacion de la Fase 3 con `AskUserQuestion` — no esperes una
respuesta del usuario en este chat para relayarsela por `SendMessage`; el agente la rechaza por
diseno (regla dura 1.1 de `job-apply.md`), venga de quien venga. Tu unico rol aca es lanzarlo y,
cuando termine (con o sin envios), mostrarle al usuario el resultado final.
