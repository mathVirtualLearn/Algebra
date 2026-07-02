protocol TheoryRepository: Sendable {
    func fetchAll() async throws -> [TheoryArticle]
    func fetch(id: String) async throws -> TheoryArticle?
}
