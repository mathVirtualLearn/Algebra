struct InMemoryTopicRepository: TopicRepository {
    func fetchAll() async throws -> [Topic] {
        [
            Topic(
                id: "equations",
                title: "Ecuaciones",
                subtitle: "Grados 1 a 4 y bicuadradas",
                systemImage: "x.squareroot"
            ),
            Topic(
                id: "identities",
                title: "Identidades",
                subtitle: "Productos notables",
                systemImage: "function"
            ),
            Topic(
                id: "systems",
                title: "Sistemas",
                subtitle: "Lineales 2×2 y 3×3",
                systemImage: "square.split.2x2"
            ),
            Topic(
                id: "functions",
                title: "Funciones",
                subtitle: "Representa gráficas",
                systemImage: "chart.xyaxis.line"
            ),
            Topic(
                id: "practice",
                title: "Práctica",
                subtitle: "Genera ejercicios y comprueba",
                systemImage: "pencil.and.list.clipboard"
            ),
            Topic(
                id: "worksheet",
                title: "Generar ejercicios",
                subtitle: "10 ejercicios en PDF con soluciones",
                systemImage: "doc.badge.plus"
            ),
        ]
    }
}
