# Decisiones de arquitectura (ADR-lite) — Algebra

Bitácora de decisiones técnicas. Cada una: **contexto**, **opciones**, **decisión** y **motivo**.
Sirve de trazabilidad del proyecto y de evidencia de criterio (TFM).

> Convención de ID: `ADR-001`, `ADR-002`… Estados: `✅ Aceptada` · `🟡 Propuesta` · `⛔️ Descartada` · `♻️ Sustituida por ADR-XXX`.

---

### ADR-001 · Arquitectura MVVM + Clean
**Estado**: ✅ Aceptada
**Contexto**: app de un TFM, ~1 mes
**Decisión**: MVVM + Clean Architecture en capas `Domain / Data / Presentation / Core`, dependencias tras `protocol`, inyección por `init`.
**Motivo**: separación de responsabilidades (SOLID), testabilidad y datos *swappable* sin tocar Domain/Presentation.

### ADR-002 · Framework Observation para estado
**Estado**: ✅ Aceptada
**Contexto**: gestión de estado de UI en SwiftUI moderno (iOS 26).
**Decisión**: ViewModels `@MainActor @Observable`. Prohibido `Combine`/`ObservableObject`/`@Published`.
**Motivo**: API actual de Apple, menos *boilerplate*, mejor rendimiento de invalidación de vistas.

### ADR-003 · Las vistas reciben solo tipos primarios
**Estado**: ✅ Aceptada
**Contexto**: evitar lógica y acoplamiento al dominio dentro de las vistas.
**Decisión**: las vistas/componentes reciben solo primitivos (`String/Int/Double/Bool/URL`…) + closures. La conversión Entity→primitivos la hace un **UIMapper** en el ViewModel (`ViewState`).
**Motivo**: vistas tontas y reutilizables, lógica testeable en la capa correcta, `#Preview` triviales.

### ADR-004 · Librería de render LaTeX
**Estado**: ✅ Aceptada · **SwiftMath**
**Contexto**: la app necesita mostrar fórmulas matemáticas con notación de libro. Opciones evaluadas:

| Opción | Cómo | Pros | Contras |
|---|---|---|---|
| **SwiftMath** (`MTMathUILabel` vía `UIViewRepresentable`) | Render **nativo** (port de iosMath), sin WebView | Rápido, sin JS, mantenido (v1.7.1, dic-2024), tipografía TeX | Cobertura LaTeX más limitada; a11y la pones tú |
| **LaTeXSwiftUI** | SwiftUI nativo **sobre MathJax** (SVG, cache, render fuera del hilo principal) | Vista SwiftUI directa, entornos completos (`align`, `cases`…), **VoiceOver** vía Speech Rule Engine | Depende de MathJax; primer render más pesado |
| **KaTeX en WKWebView** | HTML + KaTeX en `WKWebView` | Fidelidad web total | WebView por fórmula, peor rendimiento e integración |

**Recomendación**: **SwiftMath** como opción por defecto (nativo, rápido, sencillo de envolver para SwiftUI; ver el componente `MathView` en `COMPONENTS.md`). Si pesa más la **accesibilidad VoiceOver** lista de fábrica y la cobertura LaTeX completa, **LaTeXSwiftUI**.
**Decisión**: **SwiftMath** — render nativo, rápido y sencillo de envolver para SwiftUI. La accesibilidad VoiceOver de las fórmulas se implementará a mano (etiqueta legible por fórmula).
**Instalación (SPM)**: `https://github.com/mgriebling/SwiftMath.git`. Se envolverá en un componente `MathView` (`UIViewRepresentable` sobre `MTMathUILabel`) registrado en `COMPONENTS.md`.

### ADR-005 · Navegación: TabBar + NavigationStack por pestaña
**Estado**: ✅ Aceptada
**Contexto**: la app tendrá varias áreas (inicio/temas, fórmulas, ajustes) y hay que decidir la navegación raíz.
**Opciones**: TabBar con una pila por pestaña · una sola pila global · split view.
**Decisión**: `TabView` (API `Tab` de iOS 18+) con un `NavigationStack` propio dentro de cada pestaña. La lista de fórmulas se parte en `ExpressionsListView` (contenido, sin pila) para poder reutilizarla como raíz de la pestaña Fórmulas y como destino empujado desde la home (evita `NavigationStack` anidados). Destino por valor con `TopicRoute`.
**Motivo**: escalable, cada sección mantiene su propio historial, y la lista de fórmulas se reutiliza sin duplicar.

### ADR-006 · Rediseño oscuro + explicación humana
**Estado**: ✅ Aceptada
**Contexto**: el diseño inicial (vistas tipo `Form`/`List` en claro) se valoró como pobre; además las explicaciones eran solo fórmulas sueltas.
**Decisión**: tema **oscuro** forzado (`preferredColorScheme(.dark)`) con un design system propio (`AppColor`, `Card`, `CoefficientField`, `PrimaryButton`, `TypeChip`) y vistas a base de tarjetas en `ScrollView` (nunca `Form`). La explicación se modela como `ExplanationStep { text, latex? }` y se pinta con `StepListView` (frase natural + fórmula), compartido por Ecuaciones y Sistemas.
**Motivo**: estética más cuidada y didáctica; separación clara contenido/estilo; componentes reutilizables.
**Nota**: SwiftMath no soporta `\dfrac` (usar `\frac`); verificar fórmulas nuevas con capturas del simulador.

### ADR-007 · Preferencias de usuario: UserDefaults + propagación por Environment
**Estado**: ✅ Aceptada
**Contexto**: hacen falta preferencias («Tamaño de fórmulas», «Mostrar pasos detallados») que afectan a MUCHAS pantallas y deben persistir. La app es local, sin cuenta ni backend.
**Opciones**: (a) `@AppStorage` directo en las vistas; (b) SwiftData; (c) repositorio `Domain` sobre `UserDefaults` + store observable + Environment.
**Decisión**: (c). `Preferences`/`FormulaSize` en Domain; `PreferencesRepository` (`Sendable`) implementado por `UserDefaultsPreferencesRepository`; `PreferencesStore` (`@MainActor @Observable`) como fuente de verdad (carga en init, persiste en cada `didSet`). Las preferencias transversales llegan a las vistas por **Environment** (`\.formulaScale`, `\.showDetailedSteps`): `MathView` multiplica su fuente por `formulaScale`; Ecuaciones/Sistemas ocultan los pasos según `showDetailedSteps`.
**Motivo**: respeta Clean (vistas reciben primitivos; persistencia tras `protocol`, *swappable*); `@AppStorage` disperso rompería esa separación y SwiftData es excesivo para dos ajustes. El Environment evita tocar cada `MathView(fontSize:)` para propagar la escala.

### ADR-008 · MathView sanea el LaTeX (evitar el assert de SwiftMath)
**Estado**: ✅ Aceptada
**Contexto**: SwiftMath aborta con un `assert` en `MTTypesetter.getInterElementSpace` ante pares de átomos que marca «inválidos» aunque el LaTeX sea válido. En Algebra se dio el par «puntuación, operador» (coma pegada a un signo, `x = 2, -3`). Los comandos de espacio (`\;`, `\quad`) se IGNORAN al decidir la adyacencia, así que separar con espacios no basta. Es un crash real en Debug (donde se desarrolla).
**Opciones**: (a) parchear SwiftMath (paquete SPM remoto → no reproducible, se resetea); (b) corregir cada fórmula a mano (whack-a-mole); (c) sanear en origen + red de seguridad centralizada.
**Decisión**: (c). En origen, las listas de valores usan `\quad` como separador (sin coma). Como red de seguridad, `MathView.sanitized(_:)` elimina por regex la coma pegada a un signo (`, \pm|\mp|-|+|\cdot|\times|\div`) antes de pasar el LaTeX a SwiftMath.
**Motivo**: no se edita una dependencia remota; el saneado central corta el problema de raíz para fórmulas actuales y futuras sin ensuciar cada mapper. Ver memoria del proyecto (gotchas de SwiftMath).

---

## Plantilla

```
### ADR-XXX · <título>
**Estado**: 🟡 Propuesta — <fecha>
**Contexto**: <por qué hace falta decidir>
**Opciones**: <A / B / C con pros y contras>
**Decisión**: <la elegida>
**Motivo**: <razón>
```
