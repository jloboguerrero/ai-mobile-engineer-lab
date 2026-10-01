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

En background el subagente casi nunca tiene `AskUserQuestion` disponible, asi que suele terminar
la Fase 3 devolviendo la tabla de aprobacion como texto. Cuando pase:

1. Mostrale la tabla al usuario en este chat y pregunta cuales aprueba (con `AskUserQuestion`).
2. Reanuda al **mismo** agente con `SendMessage`, citando **literal** la respuesta del usuario y
   la lista de ofertas aprobadas. Es la via valida segun la regla dura 1.2 de `job-apply.md`.
3. No inventes ni amplies la aprobacion. Si el usuario no respondio, no relayes nada.

Repite lo mismo si el agente vuelve a parar en la Fase 3.5 (terminos nuevos o diff del CV). Al
final, mostrale al usuario el resultado: aplicadas, para aplicar a mano y fallidas.
