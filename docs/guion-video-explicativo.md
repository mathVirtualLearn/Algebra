# Guion del vídeo — Álgebra (código + demo)

> Vídeo del TFM de ~**9 min** con captura de pantalla. Estructura: primero **explicas el código y
> cómo está montado**, y al final **enseñas la app en el simulador**.
> Formato: **[TIEMPO] · QUÉ MUESTRAS · lo que dices (con naturalidad, no palabra por palabra)**.
> Alterna **Xcode** (código, estructura, docs, tests) y el **simulador** (demo).
>
> **Opción "a la vez" (interleaved):** si lo prefieres, en cada feature muestras primero su código
> (UseCase → ViewModel/UIMapper → View) y a continuación la ejecutas en el simulador, en vez de dejar
> toda la demo para el final. El guion vale igual; solo mueves los bloques de demo (parte 5) justo
> detrás de cada bloque de código.

**Antes de grabar**
- Xcode abierto en el proyecto (navegador de archivos a la vista) y el simulador iPhone en modo oscuro.
- Ten a mano el repo en el navegador (para `docs/` y `.claude/agents/`).
- Opcional: pon el editor con tamaño de fuente grande para que se lea el código.

---

## 1 · Presentación y contexto — [0:00–0:40]
**Pantalla:** portada o la app abierta en el simulador (pestaña Aprende).
**Dices:** «Hola, soy Alfonso Mariscal. Esto es *Álgebra*, mi TFM del Máster de Desarrollo con IA: una
app iOS nativa para estudiar álgebra de bachillerato que no solo resuelve, sino que **explica** cada
paso. En este vídeo voy a enseñar sobre todo **cómo está montado el código** y el **proceso de
desarrollo con IA**, y al final veremos la app funcionando.»

## 2 · Cómo está montado · arquitectura y capas — [0:40–1:50]
**Pantalla:** Xcode, navegador de proyecto. Señala las carpetas `Domain/`, `Data/`, `Presentation/`, `Core/`.
**Dices:** «El proyecto sigue **MVVM + Clean Architecture**, en cuatro capas con una **regla de
dependencias** estricta. **Domain** es Swift puro, sin interfaz: las entidades, los casos de uso y los
repositorios detrás de un **protocolo** —así los datos son intercambiables sin tocar la lógica—.
**Data** implementa esos repositorios. **Presentation** son las vistas SwiftUI y los ViewModels.
**Core** tiene la inyección de dependencias, el sistema de diseño y las preferencias. La flecha de
dependencia siempre apunta al Domain: ni Domain ni Presentation dependen de la infraestructura.»

## 3 · Recorrido de una feature de punta a punta — [1:50–3:30]
**Pantalla:** abre en orden estos archivos de la feature Ecuaciones:
`Domain/UseCases/SolveEquationUseCase.swift` → `Domain/Entities/EquationResult.swift` →
`Presentation/Equations/EquationUIMapper.swift` → `Presentation/Equations/EquationResultState.swift` →
`Presentation/Equations/EquationsViewModel.swift` → `Presentation/Equations/EquationsView.swift`.
**Dices:** «Sigo una feature de principio a fin. En **Domain**, el caso de uso `SolveEquationUseCase`
resuelve la ecuación —cálculo puro, sin nada de interfaz— y devuelve una entidad `EquationResult` con
las raíces y el método. Esa entidad **no llega tal cual a la vista**: un **UIMapper** la traduce a un
`EquationResultState`, que son **solo tipos primitivos** —Strings con el LaTeX, el texto de los pasos—.
El **ViewModel**, que es `@Observable` y vive en el hilo principal, orquesta: recoge la entrada, llama
al caso de uso y expone ese estado. Y la **vista** solo pinta primitivos; **no tiene lógica**. Esta
regla —*las vistas reciben solo primitivos*— es la que mantiene la lógica **testeable** y las vistas
tontas y reutilizables.»

## 4 · Core, reutilización y el design system — [3:30–4:20]
**Pantalla:** `Core/DI/` (un `Factory`), `Core/DesignSystem/` (p. ej. `MathView.swift`), y
`Presentation/Equations/RuffiniTableView.swift`.
**Dices:** «La composición se hace en **Core** con *factories* que ensamblan cada pantalla: casos de
uso, mappers y ViewModel. El **sistema de diseño** vive aquí: `MathView`, que envuelve la librería de
fórmulas, los botones, las tarjetas… Y hay **reutilización real**: la caja visual de Ruffini
(`RuffiniTableView`) se usa tanto al resolver ecuaciones como en el artículo de teoría; y los mismos
*solvers* que resuelven una ecuación se reutilizan en la sección de **Práctica** y al generar las
**hojas de ejercicios en PDF**. Nada duplicado.»

## 5 · El proceso con IA · el diferencial — [4:20–5:30]
**Pantalla:** el repo en GitHub o en Xcode: `.claude/agents/` (los tres agentes) y `docs/`
(USER-STORIES, DECISIONS, COMPONENTS, AI-WORKFLOW).
**Dices:** «Ahora, lo que de verdad diferencia el TFM: **cómo** se construyó. No es pedirle código a un
chat. Monté un **pipeline con tres agentes de IA** con rol único —**lógica**, **interfaz** y **tests**—
y todo el contexto vive en **documentos versionados**: las historias de usuario, la bitácora de
**decisiones** (ADR), el **catálogo de componentes** para no duplicar, y el método de trabajo. Cada
feature nace de una historia, pasa por los agentes y se registra. SOLID aplicado también al proceso.»

## 6 · Validación humana y un reto real — [5:30–6:20]
**Pantalla:** `docs/AI-WORKFLOW.md` (paso 6) y, si la tienes, la **captura del crash en el debugger**.
**Dices:** «Pero la automatización no lo es todo: mi flujo tiene un **paso de validación humana**.
Compilar y pasar los tests **no cierra** una feature; ejecuto la app y valido lo que la máquina no ve.
El mejor ejemplo: un **crash** de renderizado. **Compilaba** y los **tests pasaban en verde**, pero
**petaba al ejecutar**. Solo probándola a mano apareció; el debugger me dio el par de átomos exacto y lo
arreglé de raíz, con una red de seguridad. La IA propone; **yo valido, adapto y decido**.»

## 7 · Tests — [6:20–6:50]
**Pantalla:** `Algebra/AlgebraTests/` — abre un test representativo (p. ej.
`GenerateEquationExerciseUseCaseImplTests`) y, si quieres, `⌘U` en verde.
**Dices:** «La lógica está cubierta con **Swift Testing**: más de **217 pruebas**. Un ejemplo potente:
el generador de ejercicios se verifica **contra el propio solver** —genero un ejercicio y compruebo que
el solver lo resuelve y que la solución coincide—. La aleatoriedad va tras un protocolo inyectable, así
que los tests son **deterministas**.»

## 8 · La app en el simulador · demo — [6:50–8:40]
**Pantalla:** el simulador. Recorre:
- **Aprende**: el panel de secciones.
- **Ecuaciones** → 4.º grado → una cuártica → Resolver: enseña la **caja de Ruffini** y los **pasos**.
- **Sistemas** → 3 ecuaciones → **Gauss** (matriz reduciéndose) y **Cramer** (Sarrus), soluciones en **fracciones**.
- **Funciones** → escribe `2cos(3x)` → gráfica.
- **Práctica** → genera un ejercicio, escribe la respuesta (prueba una fracción como `3/2`), **Comprobar** (verde/rojo) y **Ver solución**.
- **Generar ejercicios** → elige tipo → **Generar PDF** → **vista previa** con la página de soluciones → Compartir/Imprimir.
- **Teoría** → artículo de **Ruffini** (la caja) · **Ajustes** → tamaño de fórmulas.
**Dices:** «Y así es como se ve todo esto en marcha. [Ve narrando cada pantalla brevemente:] resuelvo una
cuártica por Ruffini con su procedimiento; un sistema por Gauss con la matriz reduciéndose y solución en
fracciones exactas; grafico una función escrita como texto; en **Práctica**, la app me genera un
ejercicio y me **autocorrige** —acepta incluso fracciones—; y puedo generar una **hoja de 10 ejercicios
en PDF** con sus soluciones, previsualizarla e imprimirla. Todo con la explicación paso a paso y las
fórmulas como en un libro.»

## 9 · Cierre — [8:40–9:00]
**Pantalla:** vuelta a Aprende (o al README/GitHub).
**Dices:** «En resumen: *Álgebra* es una app nativa que **enseña, no solo calcula**, con una
arquitectura limpia y testeable, construida mediante un **proceso de desarrollo con IA trazable** y
validado a mano. El código es **público** en GitHub y está en **TestFlight**. Gracias por vuestro tiempo.»

---

### Checklist de tomas
- [ ] Xcode: carpetas Domain/Data/Presentation/Core (arquitectura)
- [ ] Xcode: recorrido de una feature (UseCase → UIMapper → ViewState → ViewModel → View)
- [ ] Xcode: Core (Factory), MathView, RuffiniTableView (reutilización)
- [ ] Repo: `.claude/agents/` y `docs/` (proceso con IA)
- [ ] `AI-WORKFLOW.md` paso 6 + captura del crash en el debugger
- [ ] Un test (generador verificado contra el solver) + `⌘U` verde
- [ ] Simulador: Aprende · Ecuaciones (Ruffini) · Sistemas (Gauss/Cramer) · Funciones · Práctica · Generar ejercicios (PDF) · Teoría (Ruffini) · Ajustes
