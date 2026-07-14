Álgebra
App iOS para estudiar álgebra de bachillerato: resuelve y explica.
TFM · Máster de Desarrollo con IA · Alfonso Mariscal Ávila.
Desarrollada con IA como copiloto (validación y decisiones humanas).

---

En qué consiste
App iOS local-first (sin backend ni cuenta) que resuelve ecuaciones, sistemas, identidades y funciones, y sobre todo explica el procedimiento paso a paso con notación de libro.
Doble objetivo del TFM: (1) una app real y útil; (2) demostrar un proceso de desarrollo con IA estructurado y trazable.

---

El problema y la propuesta
- Las calculadoras dan el resultado, no el razonamiento.
- El estudiante necesita entender por qué se hace cada paso.
- Propuesta: explicación humana (frases + cálculos) + fórmula renderizada, con el método elegible (p. ej. Gauss vs. Cramer).

---

Funcionalidades
- Ecuaciones de grado 1–4 y bicuadradas (Ruffini con caja; cambio de variable).
- Sistemas 2×2 y 3×3: sustitución/igualación/reducción y Cramer/Gauss, en fracciones exactas; indeterminados en paramétrica.
- Identidades notables simbólicas (monomios: 5x, 4r…).
- Funciones: texto libre (parser propio) + gráfica con Swift Charts.
- Práctica: genera ejercicios con solución garantizada y autocorrige (verde/rojo) + ver solución.
- Generar hoja: 10 ejercicios del tipo elegido en PDF imprimible con soluciones y vista previa.
- Teoría: 8 artículos con contenido real (Ruffini con su caja de división sintética).
- Ajustes persistentes (tamaño de fórmulas, mostrar pasos). Diseño oscuro y accesible.

---

Ecuaciones · resolución explicada
[Captura: ecuaciones.png]
- Grados 1–4 y bicuadradas.
- 3.º/4.º por Ruffini: se muestra la caja de la división sintética y cómo baja el grado.
- Cada paso es una frase + su fórmula; la solución final va destacada.

---

Sistemas · método a elegir
[Captura: sistemas.png]
- 2×2 y 3×3; el método se ajusta al tamaño.
- Gauss: la matriz ampliada se reduce paso a paso hasta triangular.
- Cramer: determinantes por Sarrus. Todo en fracciones exactas.

---

Funciones
[Captura: funciones.png]
- Escribes la función como texto (2cos(3x), x^2+3x, e^x); un parser propio la interpreta y la grafica.
- Gráfica nativa con Swift Charts.

---

Práctica · genera y autocorrige
[Captura: practica.png]
- La app genera ejercicios con solución garantizada (construida desde la solución): ecuaciones grado 1–4, bicuadradas y sistemas 2×2/3×3.
- Escribes la respuesta (acepta fracciones como 3/2) y la app autocorrige (verde/rojo).
- Ver solución paso a paso, reutilizando los solvers.

---

Generación variada de ejercicios
- El coeficiente líder varía (no siempre 1).
- Hay soluciones enteras y fraccionarias (las fracciones existen pero no predominan, ~30%).
- Aparecen raíces dobles de vez en cuando (2.º, 3.º y 4.º grado).
- Todo verificado contra el solver: cada ejercicio generado se resuelve correctamente.

---

Generar ejercicios · hoja PDF
[Captura: generar.png]
- Crea 10 ejercicios del tipo elegido en un PDF imprimible, con página de soluciones al final.
- Vista previa dentro de la app (PDFKit) y opción de compartir o imprimir.
- Útil para que el profesor reparta o el alumno practique en papel.

---

Teoría
[Captura: teoria.png]
- 8 artículos con explicaciones reales de cada tema, con sus fórmulas renderizadas.

---

Stack técnico
- Plataforma: iOS 26 (iPhone).
- UI: SwiftUI + Observation (@Observable).
- Gráficas: Swift Charts. Fórmulas: SwiftMath (LaTeX, SPM).
- Tests: Swift Testing. Persistencia local (UserDefaults), sin backend.
- Arquitectura: MVVM + Clean Architecture.

---

Arquitectura · MVVM + Clean
Presentation → Domain ← Data, con Core (DI · Design System · Preferencias).
- Domain (Swift puro): entidades, casos de uso y repositorios tras protocolo → datos intercambiables sin tocar la lógica.
- Data: implementación de repositorios (memoria, UserDefaults).
- Presentation: ViewModels @Observable; las vistas reciben solo primitivos y un UIMapper traduce el dominio.
- Ventaja: lógica testeable y vistas reutilizables.

---

Desarrollo con IA · el diferencial
- IA como copiloto orquestando agentes con rol único: lógica, UI y tests.
- Contexto perdurable en el repo: historias de usuario, decisiones (ADR), catálogo de componentes y método de trabajo.
- Cada feature nace de una historia, pasa por los agentes y se registra: evita duplicados y deja trazabilidad.

---

El ciclo humano–IA
Historia → Decisiones → Lógica → UI → Tests → Validación humana → Registrar.
- Compilar y pasar los tests no cierra una feature: la persona ejecuta la app y valida lo que la automatización no ve.
- La IA propone; el humano valida, adapta y decide.

---

Un reto real · el crash "invisible"
- Síntoma: la app abortaba al mostrar ciertas fórmulas válidas.
- Lo engañoso: compilaba y los tests pasaban en verde; solo fallaba al ejecutar.
- Diagnóstico (validación humana): el depurador señaló un par de átomos que la librería de fórmulas marca inválido (coma pegada a un signo).
- Solución: corregir en origen + red de seguridad central que sanea el LaTeX.

---

Calidad · pruebas
217 pruebas con Swift Testing (Given-When-Then).
- Cubren solvers (Gauss, Cramer, Ruffini), parser, fracciones, sistemas, identidades y preferencias.
- Lógica de dominio verificada de forma aislada; ViewModels con dobles de prueba.

---

Decisiones clave (registradas como ADR)
- Render de fórmulas: SwiftMath (nativo) frente a WebView/MathJax → rendimiento.
- Preferencias: repositorio + Environment (no @AppStorage disperso).
- Diseño: tema oscuro y explicación como paso reutilizable (ExplanationStep).
- El contexto, alternativas y motivo de cada decisión están en DECISIONS.md.

---

Entregables y enlaces
- Repositorio público: github.com/mathVirtualLearn/Algebra
- TestFlight: (enlace público — pendiente)
- Vídeo: (URL — pendiente)
- Cómo ejecutar: abrir Algebra/Algebra.xcodeproj en Xcode 26 (SPM se resuelve solo) y Run en un iPhone con iOS 26. Sin login.

---

Aprendizajes y cierre
- Orquestar IA con roles y documentos rinde más que un único prompt.
- La validación humana es insustituible.
- Clean Architecture facilitó probar y aislar la lógica.
- Objetivo doble cumplido: app real + proceso con IA demostrable.
- Gracias.
