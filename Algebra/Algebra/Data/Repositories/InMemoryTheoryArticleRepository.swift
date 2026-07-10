struct InMemoryTheoryArticleRepository: TheoryRepository {
    func fetchAll() async throws -> [TheoryArticle] {
        InMemoryTheoryArticleRepository.articles
    }

    func fetch(id: String) async throws -> TheoryArticle? {
        InMemoryTheoryArticleRepository.articles.first { $0.id == id }
    }

    private static let articles: [TheoryArticle] = [
        firstDegree,
        secondDegree,
        higherDegree,
        biquadratic,
        ruffini,
        systemsTwo,
        cramer,
        gauss,
    ]

    private static let firstDegree = TheoryArticle(
        id: "eq1",
        title: "Ecuaciones de primer grado",
        summary: "Forma ax + b = 0 y cómo despejar la incógnita",
        blocks: [
            .paragraph("Una ecuación de primer grado (o lineal) es aquella en la que la incógnita aparece elevada solo a la primera potencia, sin productos entre incógnitas ni denominadores con la incógnita. Siempre se puede escribir en su forma general:"),
            .formula("ax + b = 0"),
            .paragraph("donde a y b son números conocidos (los coeficientes) y a ≠ 0. Resolverla consiste en hallar el valor de x que hace cierta la igualdad."),
            .heading("Cómo se despeja"),
            .paragraph("Se pasa el término independiente al otro miembro y se divide por el coeficiente de la incógnita:"),
            .formula("ax = -b \\Rightarrow x = -\\displaystyle\\frac{b}{a}"),
            .heading("Ejemplo"),
            .paragraph("Resolvemos 2x - 4 = 0. Pasamos el -4 sumando y dividimos entre 2:"),
            .formula("2x - 4 = 0 \\Rightarrow 2x = 4 \\Rightarrow x = 2"),
            .heading("Casos especiales"),
            .paragraph("Al simplificar la ecuación pueden desaparecer las x. Entonces fíjate en la igualdad numérica que queda:"),
            .bullet([
                "Si llegas a 0 = 0, la igualdad es siempre cierta: hay infinitas soluciones (ecuación indeterminada).",
                "Si llegas a 0 = k con k ≠ 0, la igualdad es imposible: no hay solución (ecuación incompatible).",
            ]),
        ]
    )

    private static let secondDegree = TheoryArticle(
        id: "eq2",
        title: "Ecuaciones de segundo grado",
        summary: "Fórmula general y discriminante",
        blocks: [
            .paragraph("Una ecuación de segundo grado (cuadrática) es la que tiene la incógnita elevada al cuadrado. Su forma general es:"),
            .formula("ax^2 + bx + c = 0"),
            .paragraph("con a ≠ 0. Para resolverla se aplica la fórmula general, que da hasta dos soluciones:"),
            .formula("x = \\displaystyle\\frac{-b \\pm \\sqrt{\\Delta}}{2a}"),
            .heading("El discriminante"),
            .paragraph("La cantidad que va dentro de la raíz se llama discriminante y se representa con la letra griega delta:"),
            .formula("\\Delta = b^2 - 4ac"),
            .paragraph("Su signo te dice cuántas soluciones reales tiene la ecuación, sin necesidad de terminar el cálculo:"),
            .bullet([
                "Si Δ > 0: hay dos soluciones reales distintas.",
                "Si Δ = 0: hay una única solución real (raíz doble).",
                "Si Δ < 0: no hay soluciones reales (la raíz de un número negativo no es real).",
            ]),
            .heading("Ejemplo"),
            .paragraph("Resolvemos x² - 5x + 6 = 0, con a = 1, b = -5 y c = 6. Calculamos el discriminante y aplicamos la fórmula:"),
            .formula("\\Delta = (-5)^2 - 4 \\cdot 1 \\cdot 6 = 1"),
            .formula("x = \\displaystyle\\frac{5 \\pm \\sqrt{1}}{2} \\Rightarrow x = 2, \\; 3"),
        ]
    )

    private static let higherDegree = TheoryArticle(
        id: "eq34",
        title: "Ecuaciones de tercer y cuarto grado",
        summary: "Raíces racionales, Ruffini y reducción de grado",
        blocks: [
            .paragraph("Las ecuaciones de tercer y cuarto grado no tienen una fórmula sencilla como la cuadrática. La estrategia habitual en bachillerato es bajar el grado del polinomio buscando sus raíces enteras y dividiendo."),
            .heading("Buscar raíces racionales"),
            .paragraph("Si el polinomio tiene coeficientes enteros, sus posibles raíces enteras están entre los divisores del término independiente (el número que va solo, sin x). Se prueban esos divisores: el que anula el polinomio es una raíz."),
            .formula("P(x) = x^3 - 6x^2 + 11x - 6 = 0"),
            .paragraph("Aquí el término independiente es -6, así que probamos entre ±1, ±2, ±3, ±6."),
            .heading("Bajar el grado con Ruffini"),
            .paragraph("Cuando r es una raíz, se divide el polinomio entre (x - r) usando el método de Ruffini. El cociente tiene un grado menos, de modo que un polinomio de grado 3 se convierte en uno de grado 2, y uno de grado 4 en uno de grado 3."),
            .paragraph("Consulta el artículo «Método de Ruffini» para ver paso a paso cómo se monta la división."),
            .heading("Rematar con la fórmula general"),
            .paragraph("Cuando, tras una o varias divisiones, queda una cuadrática, se resuelve con la fórmula general del segundo grado. Reuniendo todas las raíces se obtienen las soluciones de la ecuación original."),
            .heading("Ejemplo"),
            .paragraph("En x³ - 6x² + 11x - 6 = 0, al dividir por (x - 1) queda x² - 5x + 6, cuyas raíces son 2 y 3. Por tanto:"),
            .formula("x^3 - 6x^2 + 11x - 6 = 0 \\Rightarrow x = 1, \\; 2, \\; 3"),
        ]
    )

    private static let biquadratic = TheoryArticle(
        id: "biquad",
        title: "Ecuaciones bicuadradas",
        summary: "Cambio de variable t = x² para resolverlas",
        blocks: [
            .paragraph("Una ecuación bicuadrada es una ecuación de cuarto grado que solo tiene términos de grado par (grado 4, grado 2 y término independiente). Su forma general es:"),
            .formula("ax^4 + bx^2 + c = 0"),
            .heading("Cambio de variable"),
            .paragraph("Como x⁴ = (x²)², hacemos el cambio t = x². La ecuación se transforma en una cuadrática en t, mucho más fácil de resolver:"),
            .formula("t = x^2 \\Rightarrow a t^2 + b t + c = 0"),
            .paragraph("Resolvemos esa cuadrática con la fórmula general y obtenemos los valores de t."),
            .heading("Deshacer el cambio"),
            .paragraph("Por cada valor de t volvemos a x recordando que t = x². Solo sirven los valores de t mayores o iguales que cero, porque un cuadrado nunca es negativo:"),
            .formula("|x| = \\sqrt{t}, \\quad t \\ge 0"),
            .bullet([
                "Si t > 0: aporta dos soluciones, x = +√t y x = -√t.",
                "Si t = 0: aporta una única solución, x = 0.",
                "Si t < 0: no aporta soluciones reales y se descarta.",
            ]),
            .heading("Ejemplo"),
            .paragraph("En x⁴ - 5x² + 4 = 0, con t = x² queda t² - 5t + 4 = 0, cuyas soluciones son t = 1 y t = 4. Deshaciendo el cambio:"),
            .formula("x^4 - 5x^2 + 4 = 0 \\Rightarrow x = \\pm 1 \\quad \\pm 2"),
        ]
    )

    private static let ruffini = TheoryArticle(
        id: "ruffini",
        title: "Método de Ruffini",
        summary: "División sintética de un polinomio por (x − r)",
        blocks: [
            .paragraph("El método de Ruffini es una forma rápida y abreviada de dividir un polinomio entre un binomio del tipo (x - r). Se llama división sintética porque solo se opera con los coeficientes, sin escribir las potencias de x."),
            .paragraph("Se usa sobre todo para reducir el grado de una ecuación: si r es raíz del polinomio, el resto de la división es 0 y el cociente es un polinomio de un grado menos."),
            .heading("Cómo se monta la caja"),
            .bullet([
                "Escribe en la fila superior los coeficientes del polinomio ordenados de mayor a menor grado. Si falta algún grado, pon un 0 en su lugar.",
                "Coloca la raíz r a la izquierda, fuera de la caja.",
                "Baja tal cual el primer coeficiente a la fila de resultados.",
                "Multiplica ese número por r y escribe el producto bajo el siguiente coeficiente.",
                "Suma esa columna y escribe el resultado debajo.",
                "Repite multiplicar por r y sumar hasta agotar los coeficientes.",
            ]),
            .heading("Cómo se lee el resultado"),
            .paragraph("El último número que obtienes es el resto de la división. Si r es raíz, ese resto vale 0. El resto de los números de la fila de resultados son los coeficientes del cociente, que tiene un grado menos que el polinomio inicial."),
            .heading("Ejemplo"),
            .paragraph("Dividimos x³ - 6x² + 11x - 6 entre (x - 1), es decir, con r = 1. Los coeficientes son 1, -6, 11 y -6. Al aplicar el método, la fila de resultados es 1, -5, 6 y un resto de 0:"),
            .paragraph("Así queda la caja para el ejemplo:"),
            .ruffini(
                header: ["1", "-6", "11", "-6"],
                root: "1",
                products: ["", "1", "-5", "6"],
                results: ["1", "-5", "6", "0"]
            ),
            .formula("x^3 - 6x^2 + 11x - 6 = (x - 1)(x^2 - 5x + 6)"),
            .paragraph("El resto es 0, lo que confirma que x = 1 es raíz, y el cociente es la cuadrática x² - 5x + 6, que ya se resuelve con la fórmula general."),
        ]
    )

    private static let systemsTwo = TheoryArticle(
        id: "sys2",
        title: "Sistemas de dos ecuaciones",
        summary: "Sustitución, igualación y reducción",
        blocks: [
            .paragraph("Un sistema de dos ecuaciones lineales con dos incógnitas busca los valores de x e y que cumplen las dos ecuaciones a la vez. Existen tres métodos clásicos para resolverlo; todos llevan a la misma solución."),
            .formula("\\begin{cases} x + y = 5 \\\\ x - y = 1 \\end{cases}"),
            .heading("Sustitución"),
            .paragraph("Se despeja una incógnita en una de las ecuaciones y se sustituye esa expresión en la otra, que pasa a tener una sola incógnita. Despejando x = 5 - y de la primera y sustituyendo en la segunda:"),
            .formula("(5 - y) - y = 1 \\Rightarrow y = 2 \\Rightarrow x = 3"),
            .heading("Igualación"),
            .paragraph("Se despeja la misma incógnita en ambas ecuaciones y se igualan las dos expresiones, ya que valen lo mismo. Despejando x en las dos:"),
            .formula("5 - y = 1 + y \\Rightarrow y = 2 \\Rightarrow x = 3"),
            .heading("Reducción"),
            .paragraph("Se multiplican las ecuaciones por números adecuados para que una incógnita tenga coeficientes opuestos y, al sumar o restar las ecuaciones, esa incógnita desaparece. Sumando directamente las dos ecuaciones se cancela la y:"),
            .formula("(x + y) + (x - y) = 5 + 1 \\Rightarrow 2x = 6 \\Rightarrow x = 3"),
        ]
    )

    private static let cramer = TheoryArticle(
        id: "cramer",
        title: "Sistemas por Cramer",
        summary: "Resolución con determinantes",
        blocks: [
            .paragraph("La regla de Cramer resuelve sistemas lineales usando determinantes. Es muy cómoda cuando hay tantas ecuaciones como incógnitas y el sistema es compatible determinado (solución única)."),
            .heading("Determinante del sistema"),
            .paragraph("Primero se calcula el determinante de la matriz de coeficientes, que llamamos Δ. La regla solo se puede aplicar si Δ ≠ 0; en ese caso el sistema tiene solución única."),
            .paragraph("Recuerda cómo se calcula un determinante 2×2:"),
            .formula("\\begin{vmatrix} a & b \\\\ c & d \\end{vmatrix} = ad - bc"),
            .paragraph("y un determinante 3×3 por la regla de Sarrus (productos de las tres diagonales hacia la derecha menos las tres hacia la izquierda)."),
            .heading("Determinantes de cada incógnita"),
            .paragraph("Para cada incógnita se forma un nuevo determinante sustituyendo su columna de coeficientes por la columna de los términos independientes. Así se obtienen Δx, Δy y, en sistemas 3×3, también Δz."),
            .heading("Solución"),
            .paragraph("Cada incógnita es el cociente entre su determinante y el determinante del sistema:"),
            .formula("x = \\displaystyle\\frac{\\Delta_x}{\\Delta}, \\quad y = \\displaystyle\\frac{\\Delta_y}{\\Delta}, \\quad z = \\displaystyle\\frac{\\Delta_z}{\\Delta}"),
            .paragraph("Si Δ = 0 la regla no se puede aplicar: el sistema no tiene solución única (puede ser incompatible o indeterminado)."),
        ]
    )

    private static let gauss = TheoryArticle(
        id: "gauss",
        title: "Sistemas por Gauss",
        summary: "Matriz ampliada y sustitución hacia atrás",
        blocks: [
            .paragraph("El método de Gauss resuelve sistemas lineales transformándolos en otro equivalente pero más sencillo, con forma escalonada (triangular). Es muy útil para sistemas de tres o más incógnitas."),
            .heading("Matriz ampliada"),
            .paragraph("El sistema se escribe como una matriz ampliada: a la izquierda los coeficientes de las incógnitas y, separada por una línea, la columna de los términos independientes."),
            .formula("\\left(\\begin{array}{ccc|c} a_{11} & a_{12} & a_{13} & b_1 \\\\ a_{21} & a_{22} & a_{23} & b_2 \\\\ a_{31} & a_{32} & a_{33} & b_3 \\end{array}\\right)"),
            .heading("Hacer ceros (triangular)"),
            .paragraph("Mediante operaciones por filas (intercambiar filas, multiplicar una fila por un número distinto de cero, o sumar a una fila un múltiplo de otra) se consiguen ceros por debajo de la diagonal. La matriz queda triangular:"),
            .formula("\\left(\\begin{array}{ccc|c} a_{11} & a_{12} & a_{13} & b_1 \\\\ 0 & a_{22}' & a_{23}' & b_2' \\\\ 0 & 0 & a_{33}' & b_3' \\end{array}\\right)"),
            .heading("Sustitución hacia atrás"),
            .paragraph("La última fila ya da el valor de la última incógnita directamente. Con ese valor se sube a la fila anterior para obtener la siguiente incógnita, y así hasta la primera. Este proceso de ir despejando de abajo arriba se llama sustitución hacia atrás:"),
            .formula("a_{33}' z = b_3' \\Rightarrow z \\Rightarrow y \\Rightarrow x"),
        ]
    )
}
