# Guion del vídeo de demostración — Álgebra

> Vídeo de ~**4 min** con captura de pantalla del simulador (iPhone 17 Pro, iOS 26.1) y voz en off.
> Formato: **[TIEMPO] · QUÉ MUESTRAS EN PANTALLA · lo que dices**.
> Consejo: graba la pantalla con *audio* aparte y móntalos; ensaya una vez con el guion delante.

**Preparación antes de grabar**
- Simulador limpio, modo oscuro (la app ya es oscura), sin notificaciones.
- Ten los ejemplos memorizados para no dudar al teclear.
- Aumenta el tamaño del cursor/toques si tu grabador lo permite.

---

## [0:00–0:20] · Introducción
**Pantalla:** portada o la pestaña **Aprende** (panel de temas).
**Voz:** «Esta es *Álgebra*, una app iOS nativa para estudiar álgebra de bachillerato. Es mi TFM del
Máster de Desarrollo con IA y está construida íntegramente con IA, con Claude Code. No solo resuelve
ejercicios: **explica cada paso**. Vamos a verla.»

## [0:20–1:10] · Ecuaciones (lo más potente)
**Pantalla:** abre **Ecuaciones**, elige **4.º grado**, mete una cuártica con raíces enteras
(p. ej. `x⁴ − 5x² + 4`), pulsa **Resolver**. Baja despacio por los pasos y la **caja de Ruffini**.
**Voz:** «Elijo una ecuación de cuarto grado. La app la resuelve por **Ruffini** —aquí está la caja de la
división sintética— y baja el grado hasta una cuadrática. Fíjate en que no da solo el resultado: hay una
**explicación paso a paso**, con frases y la fórmula debajo, y las soluciones destacadas. Todo con
tipografía de libro.»

## [1:10–2:00] · Sistemas (Gauss / Cramer, fracciones)
**Pantalla:** abre **Sistemas**, cambia a **3 ecuaciones**, mete un sistema, elige **Gauss**, resuelve.
Enseña la matriz reduciéndose y la solución en fracciones. Cambia a **Cramer** para mostrar los
determinantes por Sarrus.
**Voz:** «En sistemas puedo elegir el método según lo que estudie: con tres ecuaciones, **Gauss** o
**Cramer**. Con Gauss se ve la matriz reduciéndose; con Cramer, los determinantes por Sarrus. Y las
soluciones salen en **fracciones exactas**, no en decimales aproximados.»

## [2:00–2:40] · Funciones (parser + gráfica)
**Pantalla:** abre **Funciones**, escribe en el campo de texto `2cos(3x)`, pulsa y muestra la gráfica.
Cambia a `x^2 - 3x + 2` para enseñar otra.
**Voz:** «En funciones escribo la fórmula como texto —por ejemplo `2 coseno de 3x`—. Un **parser propio**
la interpreta, incluida la multiplicación implícita, y la dibuja con Swift Charts. Cambio la función y se
actualiza al instante.»

## [2:40–3:05] · Teoría y Ajustes
**Pantalla:** entra en **Teoría**, abre un artículo (p. ej. bicuadradas). Luego **Ajustes**: cambia el
**Tamaño de fórmulas** (se ve la vista previa reescalar) y activa/desactiva **Mostrar pasos**.
**Voz:** «Hay una sección de **Teoría** con explicaciones reales. Y en **Ajustes** puedo agrandar las
fórmulas —mira la vista previa— o decidir si quiero ver los pasos. Todo se guarda entre sesiones.»

## [3:05–3:45] · El proceso con IA (lo diferencial del TFM)
**Pantalla:** Xcode o el repo: enseña brevemente `docs/` (AI-WORKFLOW, USER-STORIES, DECISIONS) y
`.claude/agents/`. Opcional: la captura del **crash de SwiftMath** en el debugger.
**Voz:** «Lo importante del TFM no es solo la app, sino **cómo** se hizo: orquestando **agentes de IA**
con roles —lógica, interfaz y tests— y con documentos de proceso versionados. Un ejemplo real: este crash
de renderizado **pasaba los tests pero fallaba al ejecutar**; solo la **validación humana** en el
simulador lo destapó, y lo arreglé de raíz. La IA propone; yo valido y decido.»

## [3:45–4:00] · Cierre
**Pantalla:** vuelta a **Aprende**.
**Voz:** «*Álgebra*: una app nativa que enseña, no solo calcula, construida con un proceso de desarrollo
con IA trazable y probado. Está en TestFlight y el código es público. Gracias.»

---

### Checklist de tomas (por si grabas por trozos)
- [ ] Aprende (intro y cierre)
- [ ] Ecuaciones: cuártica por Ruffini con pasos + caja
- [ ] Sistemas: 3×3 por Gauss (matriz) y por Cramer (Sarrus), fracciones
- [ ] Funciones: `2cos(3x)` y `x^2-3x+2`
- [ ] Teoría: un artículo · Ajustes: tamaño + toggle de pasos
- [ ] docs/ + .claude/agents/ (y, si lo tienes, la captura del crash en el debugger)
