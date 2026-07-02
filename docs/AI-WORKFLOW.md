# Cómo trabajamos con la IA — Algebra

Este documento describe el **método** con el que se desarrolla Algebra.

## Principios

1. **Spec antes que código**: cada feature nace de una **historia de usuario** (`docs/USER-STORIES.md`) con criterios de aceptación. Sin historia no se programa.
2. **Agentes especializados con responsabilidad única**: en lugar de un único prompt genérico, hay tres agentes con fronteras claras (SOLID aplicado también al proceso):
   - `algebra-logic` — lógica (UseCases, Mappers, Entities, Repositories, ViewModels).
   - `algebra-ui` — vistas SwiftUI (solo primitivos, sin lógica).
   - `algebra-tester` — tests (Swift Testing, Given-When-Then).
3. **Memoria del proyecto en el repo**: la IA no "recuerda" entre sesiones, así que el contexto vive en archivos versionados:
   - `CLAUDE.md` — guía que la IA lee al abrir el proyecto.
   - `docs/COMPONENTS.md` — catálogo de lo construido → **evita duplicados**.
   - `docs/DECISIONS.md` — por qué se decidió cada cosa.
   - `docs/USER-STORIES.md` — qué se construye y su estado.
4. **No duplicar**: antes de crear, los agentes **consultan el catálogo**; al crear, lo **actualizan**.
5. **Verificación automática**: el código se compila y los tests se ejecutan hasta quedar en verde; nada se da por bueno "a ojo".
6. **Decisiones humanas explícitas**: las elecciones con trade-offs (p. ej. librería de LaTeX) se registran como ADR y las confirma la persona, no la IA en silencio.
7. **Validación humana y adaptación**: compilar y pasar tests **no basta**. La persona ejecuta la app en el dispositivo/simulador y valida lo que la automatización no ve —crashes de renderizado (p. ej. asserts de SwiftMath), corrección matemática de la explicación, UX, contenido, accesibilidad real—. Cuando algo falla, **ajusta el código directamente o dirige a los agentes** para corregirlo, y se vuelve a iterar. La IA propone; el humano valida, adapta y decide qué entra.

## El ciclo de cada feature

```
1. Historia de usuario        → docs/USER-STORIES.md (US-XXX, criterios de aceptación)
2. Decisiones necesarias      → docs/DECISIONS.md (ADR si hay trade-off)
3. Lógica (algebra-logic)     → Entities · UseCases · Mappers · ViewModel · ViewState (primitivos)
4. Vistas (algebra-ui)        → SwiftUI consumiendo solo primitivos · estados · a11y
5. Tests (algebra-tester)     → Given-When-Then sobre la lógica · compila y verde
6. Validación humana + adapt. → la persona ejecuta la app, valida a mano (render, mates,
                                 UX, a11y), ajusta código o redirige a los agentes → se itera
7. Registrar                  → COMPONENTS.md (lo nuevo) · marcar US como ✅
```

> El paso 6 es el **cierre del bucle humano-IA**: la automatización (compilar + tests)
> demuestra que el código es válido, pero solo la persona confirma que el resultado es
> *correcto y usable* de verdad. Los fallos que solo se ven ejecutando (p. ej. un `assert`
> de SwiftMath al renderizar cierta fórmula) se detectan aquí y realimentan el ciclo.

## Trazabilidad

- **Historias ↔ commits ↔ componentes ↔ decisiones** quedan enlazados por ID (`US-XXX`, `ADR-XXX`).
- Los archivos de `.claude/agents/` muestran las **reglas** que sigue la IA (revisables).
- El historial de git muestra el **proceso** incremental.

## Reproducibilidad

Cualquiera que clone el repo y abra Claude Code obtiene el mismo comportamiento: `CLAUDE.md`
y los agentes se cargan solos, y los `docs/` aportan el estado del proyecto. Para retomar el
trabajo: leer `USER-STORIES.md` (qué falta) y `COMPONENTS.md` (qué hay).
