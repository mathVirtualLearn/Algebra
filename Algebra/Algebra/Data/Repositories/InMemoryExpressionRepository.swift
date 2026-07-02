struct InMemoryExpressionRepository: ExpressionRepository {
    func fetch(topicId: String?) async throws -> [Expression] {
        let all = Self.seed
        guard let topicId else { return all }
        return all.filter { $0.topicId == topicId }
    }

    private static let seed: [Expression] = [
        Expression(
            id: "quadratic",
            latex: "x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}",
            title: "Fórmula cuadrática",
            topicId: "equations"
        ),
        Expression(
            id: "linear",
            latex: "ax + b = 0 \\Rightarrow x = -\\frac{b}{a}",
            title: "Ecuación de primer grado",
            topicId: "equations"
        ),
        Expression(
            id: "binomial",
            latex: "(a + b)^2 = a^2 + 2ab + b^2",
            title: "Binomio al cuadrado",
            topicId: "identities"
        ),
        Expression(
            id: "difference",
            latex: "a^2 - b^2 = (a + b)(a - b)",
            title: "Diferencia de cuadrados",
            topicId: "identities"
        ),
        Expression(
            id: "pythagoras",
            latex: "a^2 + b^2 = c^2",
            title: "Teorema de Pitágoras",
            topicId: "geometry"
        ),
    ]
}
