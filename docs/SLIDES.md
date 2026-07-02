# Presentación TFM — Álgebra (esquema de diapositivas)

> Guion de las diapositivas para la defensa. Cada slide: **título**, **contenido** (bullets breves para
> la diapositiva) y **[Notas]** (lo que dices tú, no va escrito en la slide). Objetivo: ~10-13 slides,
> 8-10 min. Estética oscura, coherente con la app.

---

## 1 · Portada
- **Álgebra** — app iOS para estudiar álgebra de bachillerato
- TFM · Máster de Desarrollo con IA · Alfonso Mariscal
- *Desarrollada con IA (Claude Code)*

**[Notas]** Presento en una frase: una app nativa que resuelve y **explica** ejercicios de álgebra, hecha íntegramente con IA. Hoy cuento el qué y, sobre todo, el **cómo**.

## 2 · El problema
- Las calculadoras dan el **resultado**, no el **procedimiento**
- El estudiante necesita entender *por qué* se hace cada paso
- Objetivo doble del TFM: **una app real** + **demostrar buen trabajo con IA**

**[Notas]** El valor no es "resolver ecuaciones" (eso está resuelto), sino la explicación paso a paso "para tontos" y hacerlo con un proceso de desarrollo con IA que sea serio y trazable.

## 3 · Qué es la app
- Ecuaciones · Sistemas · Identidades · Funciones · Teoría
- Explicación **paso a paso** + fórmulas tipo libro (LaTeX)
- **Local-first**: sin backend, sin cuenta, sin conexión

**[Notas]** Es una herramienta de estudio; todo funciona offline. Pantalla "Aprende" como panel de temas.

## 4 · Demo (vídeo o en vivo)
- Resolver una **cuártica por Ruffini** (con su caja)
- Un **sistema 3×3 por Gauss** en fracciones exactas
- **Funciones**: escribir `2cos(3x)` y ver la gráfica

**[Notas]** Aquí pincho el vídeo de demostración o lo enseño en directo en el simulador. Destaco los pasos explicados y el render de fórmulas.

## 5 · Stack técnico
- iOS 26.1 · **SwiftUI** + **Observation** (`@Observable`)
- **Swift Charts** (gráficas) · **SwiftMath** (LaTeX, SPM)
- **Swift Testing** · persistencia local (`UserDefaults`)

**[Notas]** Todo Apple nativo y moderno; la única dependencia externa es SwiftMath para renderizar fórmulas.

## 6 · Arquitectura
- **MVVM + Clean Architecture** · regla de dependencias estricta
- `Presentation → Domain ← Data`, con `Core` (DI + design system)
- **Las vistas reciben solo primitivos**; `UIMapper` en el ViewModel

**[Notas]** Diagrama de capas. Domain es Swift puro y testeable; los repos van tras `protocol` (datos *swappable* sin tocar Domain). Esto es lo que hace el proyecto mantenible y probado.

## 7 · El proceso con IA (lo diferencial)
- Desarrollo con **Claude Code** orquestando **agentes** con rol único: **lógica · UI · tests**
- Contexto durable en el repo: `USER-STORIES`, `DECISIONS`, `COMPONENTS`, `AI-WORKFLOW`
- SOLID aplicado también al **proceso**, no solo al código

**[Notas]** No es "pedirle código a un chat". Es un pipeline: una historia de usuario → agente de lógica → agente de UI → agente de tests, con documentos vivos que evitan duplicados y dejan trazabilidad.

## 8 · El ciclo humano-IA
- Historia → decisiones → lógica → UI → tests → **validación humana** → registrar
- **Paso 6**: la persona ejecuta la app, valida lo que la automatización no ve y **adapta**
- La IA propone; **el humano valida, adapta y decide**

**[Notas]** Insistir: compilar y pasar tests no basta. Ejemplo real en la siguiente slide.

## 9 · Un reto real: crash de renderizado
- SwiftMath **abortaba** ante ciertas fórmulas válidas (coma pegada a un signo)
- Tests y compilación en **verde**… pero **crash al ejecutar**
- Solución: corregir en origen + **red de seguridad central** (`MathView.sanitized`)

**[Notas]** Este es el mejor ejemplo del paso de validación humana: solo probando la app en el simulador apareció el fallo; el debugger dio el par de átomos exacto y lo resolví de raíz. Evidencia de criterio, no de suerte.

## 10 · Decisiones de diseño (ADR)
- SwiftMath vs. WebView/MathJax → **nativo** por rendimiento
- Preferencias por **UserDefaults + Environment** (no `@AppStorage` disperso)
- Tema oscuro + explicación humana como `ExplanationStep`

**[Notas]** Cada decisión con trade-offs quedó registrada en `DECISIONS.md`. Muestro una o dos.

## 11 · Calidad y tests
- **169 pruebas** con Swift Testing (Given-When-Then)
- Cubre solvers, parser, fracciones, sistemas, identidades, preferencias
- **0 bugs de producción** al escribir la suite

**[Notas]** La lógica crítica (Gauss, Cramer, Ruffini, parser) está verificada; los ViewModels con mocks.

## 12 · Aprendizajes
- Orquestar IA con **roles y documentos** > un único prompt
- La **validación humana** es insustituible (el crash lo probó)
- Clean Architecture facilitó testear y aislar la lógica

**[Notas]** Qué me llevo del máster aplicado a este proyecto.

## 13 · Cierre y próximos pasos
- Repo público · **TestFlight** · este vídeo y estas slides
- Futuro: más temas, migración opcional a backend (repos ya *swappable*)
- **Gracias / preguntas**

**[Notas]** Cerrar recordando el objetivo doble cumplido: app real + proceso con IA demostrable.

---

### Consejos de montaje
- Fondo oscuro (como la app), fórmulas como imagen o captura, mínimo texto por slide.
- Slides **4 y 9** son las que enganchan: la demo y el reto real. Dales tiempo.
- Ten a mano el **diagrama de capas** (slide 6) y una **captura del debugger** del crash (slide 9).
