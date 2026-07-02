protocol GetTheoryArticlesUseCase: Sendable {
    func execute() async throws -> [TheoryArticle]
}

struct GetTheoryArticlesUseCaseImpl: GetTheoryArticlesUseCase {
    private let repository: TheoryRepository

    init(repository: TheoryRepository) {
        self.repository = repository
    }

    func execute() async throws -> [TheoryArticle] {
        try await repository.fetchAll()
    }
}
