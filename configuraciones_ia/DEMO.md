# Guión de demo — entrevista Flutter + IA

Objetivo: mostrar en ~10-15 minutos que el uso de IA está diseñado, no improvisado.
Seis estaciones, cada una con qué decir, qué abrir, y el cierre.

---

## 1. El índice, no el manual — `flutter/CLAUDE.md`

**Digo:** "Mi CLAUDE.md no es un manual de 800 líneas — es un índice de menos de 200.
Cada línea que meto ahí se paga en cada request, así que solo van las reglas que
aplican siempre; el resto se carga bajo demanda."

**Abro:** `flutter/CLAUDE.md` — señalo la tabla "Rules index" y las 10 reglas
always-on.

**Cierro:** "Esto es *context engineering*: decidir qué información vale la pena tener
cargada todo el tiempo versus qué se carga solo cuando hace falta."

## 2. Reglas cargadas bajo demanda — `.claude/rules/`

**Digo:** "Estas seis reglas no salen de un tutorial — las saqué analizando un
monorepo real de producción: orden de imports, dónde van los `final` en una clase,
el patrón exacto de un bloc con un solo `Model` compartido entre estados."

**Abro:** `.claude/rules/bloc.md` — muestro el `if (isClosed) return;` y la explicación
de por qué importa (evitar `emit` después de que el bloc se cerró).

**Cierro:** "La regla no vive en mi cabeza ni en un prompt que se me puede olvidar
pegar — vive en un archivo versionado que cualquiera del equipo puede auditar."

## 3. Enforcement real — `.claude/hooks/`

**Digo:** "Que la IA 'siga las reglas' no me sirve si depende de que se acuerde. Por
eso las reglas de estilo van en un hook que corre después de cada edición."

**Hago en vivo:** pido a Claude que escriba un archivo Dart con `print()` y comillas
dobles → el hook `format_and_analyze.sh` corre `flutter analyze`, lo detecta, se lo
devuelve al modelo, y el modelo se corrige solo sin que yo intervenga.

**Cierro:** "El prompt se olvida. El hook no."

## 4. Menos tokens, a propósito — `docs/01-context-engineering.md` + `/ctx`

**Digo:** "Cuido el consumo de tokens en tres frentes: el índice del punto 1, denegar
lectura de archivos generados y secretos, y usar subagentes para búsquedas abiertas
para que esa exploración no infle mi conversación principal."

**Abro:** `.claude/settings.json` — señalo `permissions.deny` (`*.g.dart`,
`*.mocks.dart`, `.env*`) y corro `/ctx` para mostrar el reporte de presupuesto.

**Cierro:** "No es 'usar menos IA' — es no pagar por contexto que no cambia el
resultado."

## 5. Trabajo desatendido, con guardarraíles — `docs/03-loop-engineering.md`

**Digo:** "Dejar a la IA trabajar sola no es quitar los permisos, es subir una
escalera de autonomía. Cada peldaño tiene su propio chequeo automático."

**Muestro:** los 4 peldaños (hook que autocorrige → gate de salida → subagentes en
background → `scripts/loop.sh` headless), y en `loop.sh` señalo tres cosas: nunca
hace `git commit`, corre bajo el mismo `permissions.allow` de siempre (nada de
`--dangerously-skip-permissions`), y tiene un criterio de parada explícito
(`flutter analyze && flutter test`), no solo un límite de tiempo.

**Cierro:** "La autonomía sin límite no es ingeniería, es apostar. Aquí cada nivel
tiene una verificación objetiva antes de avanzar."

## 6. El gate humano — `/spec` + `/spec-impl`

**Digo:** "Ya usaba un flujo spec-driven antes de esta preparación — lo documenté
en vez de reinventarlo." *(Aclarar que `/spec` y `/spec-impl` no son míos si preguntan
— son skills de terceros que adopté y documenté.)*

**Muestro:** el header de un spec con `**Status:** Draft`, y explico que
`/spec-impl` se niega a implementar si el estado no significa "Approved" — ese
cambio de estado **solo lo hace un humano**, nunca el modelo.

**Cierro:** "Las dos decisiones irreversibles del flujo completo — aprobar el
alcance, y escribir en el historial de git — están deliberadamente fuera del
alcance de la IA."

---

## Preguntas incómodas — respuestas cortas

**"¿Y si la IA hace algo mal?"**
→ Hooks bloquean antes de que pase (`guard_paths.sh`), el gate humano de `/spec-impl`
bloquea antes de implementar, y nada se commitea sin que yo lo revise. Git es el
último respaldo — cualquier cosa es reversible mientras no se commitee.

**"¿Cuánto te cuesta esto?"**
→ Ver estación 4: índice en vez de manual, denylist de archivos generados,
subagentes para aislar exploración cara. El costo se diseña, no se improvisa.

**"¿Esto es genérico o realmente conoces la arquitectura?"**
→ Las seis reglas vienen de leer código real (`docflutter`): orden de miembros con
`final` después del constructor, p90 de 134 líneas por archivo, el patrón de un solo
`Model` por bloc. No es una plantilla de internet.
