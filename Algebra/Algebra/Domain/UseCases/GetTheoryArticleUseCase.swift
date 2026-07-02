protocol GetTheoryArticleUseCase: Sendable {
    func execute(id: String) async throws -> TheoryArticle?
}

struct GetTheoryArticleUseCaseImpl: GetTheoryArticleUseCase {
    private let repository: TheoryRepository

    init(repository: TheoryRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws -> TheoryArticle? {
        try await repository.fetch(id: id)
    }
}
