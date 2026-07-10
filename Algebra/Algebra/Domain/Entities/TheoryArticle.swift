struct TheoryArticle: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let summary: String
    let blocks: [TheoryBlock]
}

enum TheoryBlock: Equatable, Sendable {
    case heading(String)
    case paragraph(String)
    case formula(String)
    case bullet([String])
    case ruffini(header: [String], root: String, products: [String], results: [String])
}
