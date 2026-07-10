# Historias de usuario — Algebra

Backlog de la app. **Todo trabajo arranca de una historia.** Formato estándar + criterios de
aceptación (Given/When/Then, que conectan directamente con `algebra-tester`). Mantener el estado
al día: `📋 Backlog` → `🔨 En curso` → `✅ Hecha`.

> Convención de ID: `US-001`, `US-002`… Al implementar, enlazar los componentes creados (ver `COMPONENTS.md`) y las decisiones (ver `DECISIONS.md`).

---

## Plantilla (copiar para cada historia)

```
### US-XXX · <título corto>
**Estado**: 📋 Backlog
**Como** <rol> **quiero** <acción/objetivo> **para** <beneficio>.

**Criterios de aceptación**
- Dado <contexto>, cuando <acción>, entonces <resultado observable>.
- ...

**Notas**: <restricciones, dudas, dependencias>
**Implementación**: <feature/carpeta · componentes en COMPONENTS.md · decisiones en DECISIONS.md>
```

---

## Backlog

### US-001 · Ver una fórmula renderizada
**Estado**: ✅ Hecha
**Como** estudiante **quiero** ver una expresión algebraica renderizada como en un libro (LaTeX)
**para** entenderla con la notación matemática correcta.

**Criterios de aceptación**
- ✅ Dada una expresión en LaTeX válida, cuando se muestra, entonces aparece tipografiada correctamente (fracciones, raíces, exponentes) → `MathView` con SwiftMath.
- ✅ Dada una expresión inválida, cuando se intenta mostrar, entonces se muestra un estado de error legible, no un crash → `displayErrorInline` de SwiftMath.
- ✅ Dado VoiceOver activo, cuando enfoco la fórmula, entonces se anuncia una descripción comprensible → `accessibilityLabel` (título) en la fila y en `MathView`.

**Notas**: librería de render fijada en DECISIONS.md · ADR-004 (SwiftMath).
**Implementación**: feature `Presentation/Expressions/` (ViewModel, ViewState, UIMapper, View) · seed `InMemoryExpressionRepository` · componentes `MathView`/`ErrorStateView`/`Spacing` (ver `COMPONENTS.md`) · caso de uso `GetExpressionsUseCase`. Tests en `AlgebraTests/` (UseCase, UIMapper, ViewModel).

### US-002 · Home con temas y navegación por pestañas
**Estado**: ✅ Hecha
**Como** estudiante **quiero** una pantalla de inicio con los temas de álgebra y una barra de
pestañas **para** moverme con rapidez entre las secciones de la app.

**Criterios de aceptación**
- ✅ Dada la app abierta, cuando arranca, entonces veo una barra de pestañas con Inicio, Fórmulas y Ajustes.
- ✅ Dada la pestaña Inicio, cuando carga, entonces veo una rejilla de temas (Ecuaciones, Identidades, Sistemas, Funciones).
- ✅ Dado un tema con fórmulas, cuando lo pulso, entonces navego a la lista de fórmulas de ese tema.
- ✅ Dado un tema sin fórmulas (Funciones), cuando lo pulso, entonces veo el estado vacío, no un error.

**Implementación**: `Presentation/Root/RootView` (TabView) · `Presentation/Home/*` (ViewModel, ViewState, UIMapper, View) · `Topic` + `GetTopicsUseCase` + `InMemoryTopicRepository` · filtrado por tema en `GetExpressionsUseCase.execute(topicId:)` · `ExpressionsListView` reutilizada · `Presentation/Settings/*`. Decisión de navegación en DECISIONS.md · ADR-005.

### US-003 · Resolver ecuaciones de primer y segundo grado
**Estado**: ✅ Hecha
**Como** estudiante **quiero** introducir los coeficientes de una ecuación y obtener sus soluciones
**para** comprobar mis cálculos con la notación matemática correcta.

**Criterios de aceptación**
- ✅ Dado el grado y los coeficientes, cuando pulso Resolver, entonces veo la ecuación y sus soluciones renderizadas en LaTeX.
- ✅ Dada una cuadrática con Δ>0, cuando resuelvo, entonces obtengo dos raíces y el discriminante; con Δ=0 una raíz doble; con Δ<0 "sin soluciones reales".
- ✅ Dada una lineal degenerada (0=k / 0=0), cuando resuelvo, entonces obtengo "sin solución" / "infinitas soluciones".
- ✅ Dado un coeficiente no numérico, cuando resuelvo, entonces veo un error y no se calcula nada.

**Implementación**: `Domain/{EquationInput, EquationResult, SolveEquationUseCase}` (cálculo puro) · `Presentation/Equations/*` (ViewModel, ViewState, UIMapper que construye el LaTeX, View con Form + MathView) · `EquationsFactory` · enganchada desde la home (tema "Ecuaciones" → resolver, ver ADR-005). 12 tests (use case, mapper, ViewModel).

### US-004 · Identidades notables (expansor)
**Estado**: ✅ Hecha
**Como** estudiante **quiero** elegir una identidad notable e introducir `a` y `b`
**para** ver su desarrollo y resultado con la notación correcta.

**Criterios de aceptación**
- ✅ Dada una identidad (cuadrado de la suma / de la diferencia / suma por diferencia) y valores `a`,`b`, cuando pulso Desarrollar, entonces veo la fórmula general y el desarrollo con números y resultado en LaTeX.
- ✅ Dado un valor no numérico, cuando desarrollo, entonces veo un error y no se calcula nada.
- ✅ Acepta coma o punto decimal; campo vacío cuenta como 0.

**Implementación** (construida **delegando en los agentes**: `algebra-logic` → `algebra-ui` → `algebra-tester`): `Domain/{IdentityInput, IdentityResult, ExpandIdentityUseCase}` (cálculo puro) · `Presentation/Identities/*` (ViewModel, ViewState, UIMapper que construye el LaTeX, `IdentitiesView`) · `IdentitiesFactory` · enganchada desde la home (tema "Identidades"). 13 tests (use case, mapper, ViewModel).

### US-005 · Ecuaciones avanzadas (3.º y 4.º por Ruffini, bicuadradas) + rediseño oscuro
**Estado**: ✅ Hecha
**Como** estudiante **quiero** resolver ecuaciones de grado 1 a 4 y bicuadradas, con una interfaz cuidada
**para** estudiar más casos con una herramienta agradable de usar.

**Criterios de aceptación**
- ✅ Selector de tipo (1.º–4.º grado y bicuadrada) y coeficientes en rejilla de 2 por fila.
- ✅ Grado 3 y 4 se resuelven por Ruffini; bicuadradas por cambio de variable t=x².
- ✅ Interfaz oscura con tarjetas (no Form/List); solución destacada en color menta.
- ✅ Si no hay raíces racionales (Ruffini) → resultado parcial honesto.

**Implementación**: `Domain/{EquationType, EquationResult(Ruffini/Cramer model), SolveEquationUseCase}` · `Presentation/Equations/*` reescrito · design system oscuro (`AppColor`, `Card`, `CoefficientField`, `PrimaryButton`, `TypeChip`) + `preferredColorScheme(.dark)` · `MathView` con `color`. Ver DECISIONS · ADR-006. Verificado con capturas del simulador.

### US-005b · Explicación humana paso a paso
**Estado**: ✅ Hecha
**Como** estudiante **quiero** que el procedimiento mezcle frases en lenguaje natural con los cálculos
**para** entender *por qué* se hace cada paso, no solo el resultado.

**Criterios de aceptación**
- ✅ Cada paso es `{ texto, fórmula opcional }`: una frase explicativa y, debajo, la fórmula (si aplica).
- ✅ Aplica a Ecuaciones y a Sistemas (componente compartido `StepListView`).

**Implementación**: `Presentation/Shared/{ExplanationStep, StepListView}` · mappers de Ecuaciones y Sistemas producen `[ExplanationStep]`. Nota técnica: SwiftMath usa `\frac`, no `\dfrac` (ver memoria del proyecto).

### US-006 · Sistemas lineales 2×2 y 3×3 (Cramer)
**Estado**: ✅ Hecha
**Como** estudiante **quiero** resolver sistemas lineales de 2 y 3 ecuaciones
**para** comprobar mis soluciones con el procedimiento explicado.

**Criterios de aceptación**
- ✅ Entrada matricial de coeficientes y términos independientes (2 o 3 ecuaciones).
- ✅ Resuelve por Cramer; distingue compatible determinado / incompatible / indeterminado.
- ✅ Explicación humana del cálculo (Δ, Δx, Δy, Δz) y solución destacada.
- ✅ En la home, Sistemas sustituye al antiguo tema Geometría.

**Implementación**: `Domain/{SystemInput, SystemResult, SolveSystemUseCase}` (Cramer) · `Presentation/Systems/*` · `SystemsFactory` · enganche en la home · seed de temas actualizado. 10 tests nuevos.

---

## Hechas

- **US-001** · Ver una fórmula renderizada (arriba, ✅)
- **US-002** · Home con temas y navegación por pestañas (arriba, ✅)
- **US-003** · Resolver ecuaciones de primer y segundo grado (arriba, ✅)
- **US-004** · Identidades notables (expansor) (arriba, ✅)
- **US-005** · Ecuaciones avanzadas + rediseño oscuro (arriba, ✅)
- **US-005b** · Explicación humana paso a paso (arriba, ✅)
- **US-006** · Sistemas lineales 2×2 y 3×3 (arriba, ✅)
- **US-007** · Caja visual de Ruffini (división sintética) en cúbicas/cuárticas (✅)
- **US-008** · Selector de método en Sistemas: sustitución / igualación / reducción (✅)
- **US-009** · Funciones: gráfica con Swift Charts (✅)
- **US-011** · Sistemas: métodos por tamaño (2 eq → sustitución/igualación/reducción; 3 eq → Cramer/Gauss) + pasos detallados (✅)
- **US-012** · Identidades simbólicas (monomios: `5x`, `4r`…) (✅)
- **US-013** · Funciones: más tipos (exponencial, logarítmica, seno, coseno) (✅)
- **Identidades** rediseñada a chips (estilo Ecuaciones) (✅)
- **US-014** · Funciones con entrada de texto libre (parser de expresiones: `2cos(3x)`, `x^2+3x`…) (✅)
- **US-015** · Teoría (sustituye a Fórmulas): 8 artículos (ecuaciones, Ruffini, sistemas, Cramer, Gauss) (✅)
- **US-016** · Ajustes con preferencias (tamaño de fórmulas + mostrar pasos) y pestaña «Aprende» (✅)
- **US-017** · Práctica: ejercicios generados con solución garantizada + autocorrección (✅)
- **US-018** · Generar hoja de ejercicios en PDF imprimible (10 ejercicios + soluciones + vista previa) (✅)
- **US-019** · Generación variada: coeficiente líder variable, soluciones fraccionarias y raíces dobles (✅)
- **US-020** · Caja de Ruffini en Teoría (bloque visual en el artículo del método) (✅)

### US-008 · Selector de método en Sistemas
**Estado**: ✅ Hecha
**Como** estudiante **quiero** elegir el método (sustitución, igualación, reducción) **para** ver el sistema resuelto con el procedimiento del método que estudio.
**Implementación**: `SystemMethod` (enum) · `SystemUIMapper.map(input:result:method:)` genera la explicación por método (2×2: los tres; 3×3: reducción=Gauss, sustitución/igualación reducen a 2×2) · `SystemsViewModel` con `methodIndex`/`methodTitles` · selector de chips en `SystemsView`. La solución la sigue dando Cramer (no cambia). Tests de los tres métodos. Build + tests (sin lanzar la app).

### US-007 · Caja visual de Ruffini
**Estado**: ✅ Hecha
**Como** estudiante **quiero** ver la división de Ruffini con su caja (raya vertical de la raíz, raya horizontal, filas de productos y resultado) **para** entender cómo se obtiene el cociente.
**Implementación**: `RuffiniTableauState` (header/divisions con products+results) construido en `EquationUIMapper` · componente `RuffiniTableView` (Grid monoespaciado con líneas) integrado en `EquationsView`. 4 tests del builder. Verificado con build + tests (sin lanzar la app).

### US-009 · Funciones (gráfica)
**Estado**: ✅ Hecha
**Como** estudiante **quiero** representar la gráfica de una función **para** visualizar su forma.
**Implementación**: `MathFunction`/`FunctionType` · `SampleFunctionUseCase` (muestrea f(x), descarta puntos no finitos) · `FunctionUIMapper`/`FunctionPlotState` (puntos + ventana Y clamp + LaTeX) · `FunctionsViewModel` · `FunctionsView` con **Swift Charts** (`LineMark`) · `FunctionsFactory` · enganche del tema "Funciones". Verificado con build.

### US-011 · Sistemas: métodos por tamaño + pasos detallados
**Estado**: ✅ Hecha
**Como** estudiante **quiero** que en 2 ecuaciones haya sustitución/igualación/reducción y en 3 ecuaciones Cramer/Gauss, con el procedimiento desglosado al máximo, **para** seguir cada paso sin saberme nada.
**Implementación**: `SystemMethod` (5 casos) · `SystemsViewModel` con `methodTitles` por tamaño y reseteo de método · `SystemUIMapper` reescrito: pasos "para tontos" (distribuir, agrupar, despejar, sustituir de verdad, con fracciones) para 2×2 y Cramer (Sarrus) / Gauss (matriz ampliada) para 3×3. Verificado con build.

### US-012 · Identidades simbólicas (monomios)
**Estado**: ✅ Hecha
**Como** estudiante **quiero** usar monomios (`5x`, `4r`) además de números en las identidades **para** desarrollarlas con variables.
**Implementación**: `Monomial` (coeficiente + variables, parser, producto, latex) · `IdentityInput`/`IdentityResult` simbólicos · `ExpandIdentityUseCase` (desarrollo + agrupación) · `IdentityUIMapper` (fórmula general + sustitución + resultado). Ej.: `(5x − 4r)² = (5x)² − 2(5x)(4r) + (4r)² = 25x² − 40rx + 16r²`. Verificado con build.

### US-013 · Funciones: más tipos
**Estado**: ✅ Hecha
**Como** estudiante **quiero** representar también exponenciales, logarítmicas y trigonométricas **para** estudiar más funciones.
**Implementación**: `FunctionType` += exponential/logarithmic/sine/cosine; `SampleFunctionUseCase` evalúa cada una y descarta no finitos; `FunctionUIMapper` y `FunctionsViewModel` actualizados. Verificado con build.

### Identidades → chips (UI)
**Estado**: ✅ Hecha. `IdentitiesView` rediseñada al estilo oscuro de Ecuaciones (chips `TypeChip` en vez del `Picker` segmentado, tarjetas, `PrimaryButton`).

---

### US-016 · Ajustes con preferencias + pestaña «Aprende»
**Estado**: ✅ Hecha
**Como** estudiante **quiero** ajustar el tamaño de las fórmulas y decidir si veo los pasos, y que la
primera pestaña tenga un nombre con sentido, **para** adaptar la app a cómo estudio.

**Criterios de aceptación**
- ✅ La primera pestaña se llama «Aprende» (icono `graduationcap`), antes «Inicio».
- ✅ Ajustes deja de ser una pestaña casi vacía: sección «Preferencias» con **Tamaño de fórmulas** (Pequeño/Mediano/Grande, con vista previa en vivo) y **Mostrar pasos detallados** (toggle). Se quita la línea «Hecho con SwiftUI…».
- ✅ El tamaño reescala las fórmulas en TODA la app (Ecuaciones, Sistemas, Teoría, pasos…) al instante.
- ✅ Desactivar los pasos oculta el bloque «Procedimiento» en Ecuaciones y Sistemas.
- ✅ Las preferencias **persisten** entre sesiones.

**Implementación** (orquestando `algebra-logic` → `algebra-ui`): `Domain/{Preferences, FormulaSize, PreferencesRepository}` · `Data/UserDefaultsPreferencesRepository` · `Core/Preferences/PreferencesStore` (`@MainActor @Observable`) · `Core/DesignSystem/FormulaEnvironment` (`\.formulaScale`/`\.showDetailedSteps` vía `@Entry`) · `MathView` multiplica por `formulaScale` · `RootView` crea el store e inyecta el Environment · `SettingsView`/`SettingsViewModel`. Ver DECISIONS · ADR-007. Tests: `UserDefaultsPreferencesRepositoryTests`, `SettingsViewModelTests`.

### US-017 · Práctica con autocorrección
**Estado**: ✅ Hecha
**Como** estudiante **quiero** que la app me proponga ejercicios y me corrija la respuesta **para** practicar
por mi cuenta y saber al momento si lo he hecho bien.

**Criterios de aceptación**
- ✅ Puedo elegir el tipo de ejercicio (ecuaciones de Grado 1–4, bicuadrada, sistema 2×2 y 3×3) con chips.
- ✅ Cada ejercicio se genera con **solución garantizada** (se construye desde la solución), no por azar de coeficientes.
- ✅ Escribo la respuesta (raíces separadas por comas; para sistemas, un campo por incógnita) y al pulsar **Comprobar** veo si es correcta (verde) o no (rojo).
- ✅ En ecuaciones el orden de las raíces no importa; la comprobación es exacta (compara `Fraction`, admite fracciones «3/2»).
- ✅ **Ver solución** muestra el procedimiento paso a paso y la solución destacada, reutilizando los solvers y mappers existentes.
- ✅ **Otro ejercicio** genera uno nuevo del mismo tipo y limpia el estado.

**Notas**: la generación garantizada y el `RandomSource` inyectable se detallan en DECISIONS · ADR-009.
**Implementación**: `Presentation/Practice/{PracticeView, PracticeViewModel}` · `Core/DI/PracticeFactory` · casos de uso `GenerateEquationExerciseUseCase` + `GenerateSystemExerciseUseCase` + `CheckEquationAnswerUseCase`/`CheckSystemAnswerUseCase` (`Domain/UseCases/CheckAnswerUseCase.swift`) · `Domain/Services/RandomSource` + `Core/Random/SystemRandomSource` · entidad `PracticeExercise` (`PracticeType`, `EquationExercise{input, roots:[Fraction]}`, `SystemExercise{input, solution:[Fraction]}`) · reutiliza `SolveEquationUseCase`/`SolveSystemUseCase`, `EquationUIMapper`/`SystemUIMapper` y `StepListView` · card «Práctica» en Aprende (seed de temas). Ver `COMPONENTS.md`.

### US-018 · Generar hoja de ejercicios en PDF imprimible
**Estado**: ✅ Hecha
**Como** profesor (o estudiante) **quiero** generar una hoja de ejercicios en PDF con su hoja de soluciones **para**
imprimirla o compartirla y trabajar sin pantalla.

**Criterios de aceptación**
- ✅ Elijo el tipo (ecuaciones de Grado 1–4, bicuadrada, sistema 2×2/3×3) y genero **10 ejercicios** de ese tipo.
- ✅ El PDF (A4) incluye título, línea de nombre/fecha, los enunciados numerados y una **página de soluciones** al final.
- ✅ Las fórmulas van **rasterizadas** (imagen) con SwiftMath, no como texto plano.
- ✅ **Vista previa in-app** con PDFKit antes de compartir/imprimir; puedo cerrarla o compartir con `ShareLink`.
- ✅ Reutiliza los generadores garantizados y los mappers de Ecuaciones/Sistemas para enunciado y solución.

**Notas**: exportación a PDF y previsualización en DECISIONS · ADR-010.
**Implementación**: `Presentation/Worksheet/{WorksheetView, WorksheetViewModel}` · `Core/DI/WorksheetFactory` · `Core/PDF/WorksheetPDFRenderer` (`WorksheetPDFRenderer` protocolo + `SwiftMathWorksheetPDFRenderer`, `@MainActor`, `UIGraphicsPDFRenderer`, A4, fórmulas con `MTMathImage`) + `Core/PDF/WorksheetItem` · `Presentation/Shared/{PDFKitView, ShareSheet}` · card «Generar ejercicios» (hoja PDF) en Aprende (seed de temas). Ver `COMPONENTS.md`.

### US-019 · Generación variada (coef. líder, fracciones, raíces dobles)
**Estado**: ✅ Hecha
**Como** estudiante **quiero** que los ejercicios generados no sean siempre mónicos ni de solución entera **para**
practicar casos más realistas y variados.

**Criterios de aceptación**
- ✅ El **coeficiente líder varía** (no siempre 1) en polinomios y bicuadradas.
- ✅ Aparecen **soluciones fraccionarias** (~30 % en 1.º/2.º grado y, a veces, en sistemas por Cramer con término independiente libre).
- ✅ Aparecen **raíces dobles** ocasionales en 2.º/3.º/4.º grado.
- ✅ `Fraction` gana `Hashable` e `init?(parsing:)` (acepta «3/2»); las raíces de ecuaciones se muestran como **fracción** exacta (no decimal) en el mapper.
- ✅ Los coeficientes se acotan (tope) para que los enunciados sean legibles.

**Notas**: la construcción desde la solución (que garantiza estas variantes limpias) está en DECISIONS · ADR-009.
**Implementación**: `GenerateEquationExerciseUseCase` (expande factores con líder `a`, raíces fraccionarias/dobles, `build` con tope de coeficientes) · `GenerateSystemExerciseUseCase` (matriz con det≠0 y término independiente libre → solución fraccionaria por Cramer, o solución entera exacta) · `Fraction` (`Hashable`, `init?(parsing:)`) · `EquationUIMapper.rootLatex` muestra las raíces como fracción. Etiqueta: los grados se muestran como **«Grado N»** (antes «N.º grado») en Ecuaciones, Práctica y Generar hoja.

### US-020 · Caja de Ruffini en Teoría
**Estado**: ✅ Hecha
**Como** estudiante **quiero** ver la caja visual de Ruffini dentro del artículo de teoría del método **para**
entender la división sintética con el mismo dibujo que en el resolutor.

**Criterios de aceptación**
- ✅ El artículo «Método de Ruffini» muestra la **caja visual** (misma que en Ecuaciones), no solo texto y fórmulas sueltas.
- ✅ Se reutiliza el componente `RuffiniTableView` (no se duplica).
- ✅ El contenido de la caja llega desde el dominio como un bloque de teoría más.

**Implementación**: nuevo caso `TheoryBlock.ruffini(header, root, products, results)` (Domain) → `TheoryBlockState.ruffini(id, RuffiniTableauState)` (primitivos) · `TheoryUIMapper` traduce el bloque a `RuffiniTableauState` · `TheoryArticleView` pinta el caso `.ruffini` con `RuffiniTableView` · seed del artículo de Ruffini actualizado. Ver `COMPONENTS.md`.

### Mantenimiento
- **Crash de renderizado SwiftMath**: `assert` de tipografía ante el par «puntuación, operador» (coma pegada a `\pm`/`-`). Corregido en origen (Teoría, mapper de Ecuaciones usa `\quad` sin coma) y con red de seguridad `MathView.sanitized(_:)`. Ver DECISIONS · ADR-008.
- **Paso 6 del workflow** (validación humana + adaptación) añadido a `AI-WORKFLOW.md` y a `CLAUDE.md`.
- **Comentarios**: el código se dejó SIN comentarios a propósito (base limpia para aplicar reglas de comentado propias).

## Tests — ✅ Completos y en verde
La deuda de tests queda **saldada**: el target `AlgebraTests` compila y `xcodebuild test` pasa (**0 fallos**, ~217 `@Test`). Cubierto: Funciones (parser/`FunctionExpr`/muestreo/VM/mapper), Sistemas y Ecuaciones (incl. Ruffini/`Fraction`), Identidades (`Monomial` + desarrollo simbólico), Teoría (use cases, mapper, VMs), Preferencias (`UserDefaultsPreferencesRepository`, `SettingsViewModel`). El bug que impedía compilar (`IdentityInputBuilder` pasaba `Double` en vez de `Monomial`) y dos mocks/tests con API vieja quedaron corregidos. No se detectaron bugs de producción.
