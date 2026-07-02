# Algebra — Guía del proyecto (CLAUDE.md)

App iOS de **matemáticas** (álgebra). TFM del *Máster de Desarrollo con IA*, desarrollada con IA
(Claude Code). Objetivo doble: una app real y **demostrar un buen trabajo con la IA** (proceso
estructurado, trazable y reproducible).

## Stack
- **Plataforma**: iOS 26, iPhone.
- **Lenguaje**: Swift 6.2, *strict concurrency*.
- **UI**: SwiftUI + framework **Observation** (`@Observable`).
- **Render de fórmulas**: LaTeX (ver `docs/DECISIONS.md` — ADR-004).
- **Arquitectura**: MVVM + Clean Architecture, SOLID.

## Arquitectura y flujo de datos
Flujo **unidireccional**:
```
DTO ──DataMapper──▶ Entity (Domain) ──UseCase──▶ ViewModel ──UIMapper──▶ ViewState (primitivos) ──▶ Vista
```
- **Domain**: Swift puro (sin SwiftUI/SwiftData). Entidades `Sendable`, casos de uso y repositorios tras `protocol`.
- **Data**: DTOs `Codable`, mappers DTO↔Entity, implementación de repositorios.
- **Presentation**: ViewModels `@MainActor @Observable` + `ViewState`/UIMapper que convierten el dominio en **tipos primarios**. Las **vistas reciben solo primitivos y no contienen lógica**.
- **Core**: DI, design system, utilidades.

## Estructura de carpetas
```
Algebra/                      ← raíz del repo (este CLAUDE.md, .claude/, docs/)
├── .claude/agents/           (algebra-logic · algebra-ui · algebra-tester)
├── docs/                     (USER-STORIES · COMPONENTS · DECISIONS · AI-WORKFLOW)
└── Algebra/Algebra/          ← carpeta del target (contiene Assets.xcassets)
    ├── Domain/   (Entities · UseCases · Repositories · Errors)
    ├── Data/     (DTO · Mappers · Repositories)
    ├── Presentation/<Feature>/ (ViewModel · ViewState · UIMapper · Views)
    └── Core/     (DI · DesignSystem · Extensions)
```

## Agentes (`.claude/agents/`)
- **`algebra-logic`** — UseCases, Mappers, Entities, Repositories, ViewModels.
- **`algebra-ui`** — vistas SwiftUI (solo primitivos), componentes, a11y, estados.
- **`algebra-tester`** — tests con Swift Testing (Given-When-Then, mocks/builders aparte).

## Trabajar con la IA (OBLIGATORIO — es parte de la nota del TFM)
Estos documentos son **fuente de verdad viva**. Antes de crear y después de crear, se actualizan:

1. **`docs/USER-STORIES.md`** — backlog. Todo trabajo arranca de una historia con su criterio de aceptación. Al implementar, se marca su estado.
2. **`docs/COMPONENTS.md`** — catálogo de lo ya construido (componentes UI y piezas de lógica). **Leer antes de crear** (para reutilizar, no duplicar) y **añadir una entrada al crear** algo nuevo.
3. **`docs/DECISIONS.md`** — bitácora de decisiones (ADR-lite). Cada decisión técnica relevante deja registro: contexto, opción elegida y motivo.
4. **`docs/AI-WORKFLOW.md`** — explica el método de trabajo con IA (evidencia para el tribunal).

Regla para los agentes: **consultar `COMPONENTS.md` antes de crear** cualquier componente o caso de uso, y **registrar lo nuevo** allí al terminar. Las decisiones de arquitectura/diseño van a `DECISIONS.md`.

## Convenciones
- **Textos**: String Catalog en español. Nada hardcodeado en vistas.
- **Accesibilidad**: Dynamic Type, VoiceOver, contraste, *touch targets* ≥ 44pt (importante: fórmulas con etiqueta legible).
- **Errores**: tipados; sin `try?` que trague errores ni *force unwrap*.
- **Tests**: lógica de Domain/Presentation con Swift Testing.
- **Validación humana**: compilar + tests en verde **no cierra** una feature. La persona ejecuta la app y valida a mano lo que la automatización no ve (render de fórmulas, corrección matemática, UX, a11y real); luego adapta el código o redirige a los agentes. La IA propone; el humano valida, adapta y decide. Ver paso 6 de `docs/AI-WORKFLOW.md`.
- **Commits**: no commitear sin que el usuario lo pida.

## Entregables del TFM
README, repo público GitHub, despliegue/TestFlight, slides y vídeo. El README definitivo (con credenciales de prueba si hay login) se genera al final.
