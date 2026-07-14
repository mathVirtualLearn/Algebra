# Álgebra — Dossier del proyecto (fuente para NotebookLM)

> Documento único y autoexplicativo del TFM "Álgebra". Pensado para subirlo como fuente a
> NotebookLM y generar un Video Overview (diapositivas narradas), un Audio Overview o una guía.

## Qué es

Álgebra es una aplicación iOS nativa para estudiar álgebra de bachillerato. No es una simple
calculadora: además de resolver, **explica el procedimiento paso a paso**, mezclando frases en
lenguaje natural con los cálculos, y muestra las fórmulas con notación matemática de libro. Funciona
de forma local (local-first): no necesita conexión, backend ni cuenta de usuario.

Es el Trabajo Fin de Máster del Máster de Desarrollo con IA. Tiene un objetivo doble: por un lado,
ser una **app real y útil**; por otro, **demostrar un proceso de desarrollo asistido por IA** que sea
estructurado, trazable y reproducible. La app se construyó usando la IA (Claude Code) como copiloto,
con validación y decisiones humanas.

## El problema y la propuesta de valor

Las calculadoras y muchas apps dan el resultado, pero no el razonamiento. Un estudiante necesita
entender *por qué* se hace cada paso. La propuesta de Álgebra es acompañar cada solución de una
explicación humana (frases + cálculos), renderizar la fórmula como en un libro, y permitir **elegir el
método** de resolución (por ejemplo, Gauss frente a Cramer) para estudiar tal y como se ve en clase.

## Funcionalidades

- **Ecuaciones** de grado 1 a 4 y bicuadradas. Las de primer y segundo grado por fórmula; las de
  tercer y cuarto grado por el método de Ruffini, con su caja de división sintética dibujada; las
  bicuadradas por cambio de variable. Explicación paso a paso y solución destacada. Las raíces no
  enteras se muestran como fracción exacta.
- **Sistemas lineales** de dos y tres ecuaciones, con el método adaptado al tamaño: sustitución,
  igualación o reducción para dos ecuaciones; Cramer o Gauss para tres. Soluciones en fracciones
  exactas; los sistemas indeterminados se resuelven en forma paramétrica.
- **Identidades notables** simbólicas: admite monomios (como 5x o 4r), no solo números, y muestra el
  desarrollo agrupado.
- **Funciones**: el usuario escribe la función como texto libre (por ejemplo, 2cos(3x) o x^2+3x) y un
  parser propio la interpreta y la representa gráficamente con Swift Charts.
- **Práctica**: la app genera ejercicios con solución garantizada (construidos desde la solución) y
  **autocorrige**: el estudiante escribe la respuesta, la app la marca en verde o rojo, y puede ver la
  solución paso a paso. La generación es variada: el coeficiente líder cambia, hay soluciones enteras y
  fraccionarias, y de vez en cuando raíces dobles.
- **Generar ejercicios**: crea una hoja de 10 ejercicios del tipo elegido en un PDF imprimible, con una
  página de soluciones al final; se previsualiza dentro de la app y se puede imprimir o compartir.
- **Teoría**: artículos con explicaciones reales de cada tema, incluidas las fórmulas y la caja visual
  de Ruffini.
- **Ajustes** persistentes (tamaño de las fórmulas, mostrar u ocultar los pasos), diseño oscuro y
  atención a la accesibilidad.

## Arquitectura

La app sigue MVVM + Clean Architecture, con una regla de dependencias estricta y cuatro capas:

- **Domain**: Swift puro, sin interfaz. Contiene las entidades, los casos de uso y los repositorios
  detrás de un protocolo, de modo que la fuente de datos es intercambiable sin tocar la lógica.
- **Data**: la implementación de los repositorios (datos en memoria y preferencias en el
  almacenamiento local).
- **Presentation**: las vistas SwiftUI y los ViewModels observables. Una regla clave es que las vistas
  reciben solo tipos primitivos; la conversión desde el dominio la hace un "UIMapper" dentro del
  ViewModel.
- **Core**: inyección de dependencias, sistema de diseño y preferencias.

La ventaja de este diseño es que la lógica queda aislada y testeable, y las vistas son simples y
reutilizables.

## El proceso con IA (lo diferencial del TFM)

El desarrollo no consistió en pedir código a un chat. Se montó un pipeline con **agentes de IA
especializados** con responsabilidad única: uno para la lógica, uno para la interfaz y uno para los
tests. Todo el contexto del proyecto vive en documentos versionados en el repositorio: las historias
de usuario, la bitácora de decisiones (ADR), el catálogo de componentes (para reutilizar y no
duplicar) y el método de trabajo. Cada funcionalidad nace de una historia, pasa por los agentes y se
registra. En otras palabras, los principios SOLID se aplican también al proceso, no solo al código.

## El ciclo humano–IA

El flujo de trabajo tiene siete pasos: historia de usuario, decisiones, lógica, interfaz, tests,
**validación humana** y registro. El sexto paso es el cierre del bucle: compilar y pasar los tests no
cierra una funcionalidad. La persona ejecuta la app y valida lo que la automatización no ve (el
renderizado, la experiencia de uso, la corrección matemática). La IA propone; el humano valida, adapta
y decide.

## Un reto real: el crash "invisible"

Un buen ejemplo de por qué la validación humana es insustituible: en cierto momento la app abortaba al
mostrar determinadas fórmulas que eran válidas. Lo engañoso es que compilaba y los tests pasaban en
verde; solo fallaba al ejecutarla. Al probarla a mano apareció el problema; el depurador señaló que la
librería de fórmulas marcaba como inválida una adyacencia concreta (una coma pegada a un signo). Se
corrigió en origen y, además, se añadió una red de seguridad central que sanea el LaTeX antes de
renderizarlo.

## Calidad y tests

La lógica está cubierta con Swift Testing siguiendo el patrón Given-When-Then: más de 200 pruebas sobre
los solvers (Gauss, Cramer, Ruffini), el parser de funciones, las fracciones, los sistemas, las
identidades, la generación de ejercicios y las preferencias. La lógica del dominio se verifica de forma
aislada y los ViewModels con dobles de prueba. Al escribir la batería de pruebas no aparecieron bugs de
producción, señal de que el dominio estaba bien aislado.

## Decisiones clave

- Render de fórmulas con SwiftMath (nativo) en lugar de una solución basada en WebView/MathJax, por
  rendimiento.
- Preferencias mediante un repositorio y propagación por el entorno de SwiftUI, en vez de dispersar el
  almacenamiento por las vistas.
- Diseño oscuro con un sistema de diseño propio, y la explicación modelada como un paso reutilizable.
- Generación de ejercicios construyendo el problema desde la solución (garantiza soluciones limpias) con
  una fuente de aleatoriedad inyectable para que los tests sean deterministas.
- Exportación a PDF rasterizando las fórmulas y previsualización dentro de la app.

Cada decisión, con su contexto, alternativas y motivo, queda registrada en la bitácora del proyecto.

## Stack técnico

iOS 26, SwiftUI con el framework Observation, Swift Concurrency, Swift Charts para las gráficas,
SwiftMath para el render de fórmulas, Swift Testing para las pruebas y persistencia local. Arquitectura
MVVM + Clean.

## Aprendizajes y cierre

Orquestar la IA con roles y documentos rinde más que un único prompt genérico. La validación humana es
insustituible. Y una buena arquitectura (Clean) facilita probar y aislar la lógica. El objetivo doble
del TFM queda cumplido: una app real y un proceso de desarrollo con IA demostrable y trazable.

Autor: Alfonso Mariscal Ávila. Repositorio público en GitHub; app distribuida por TestFlight.
