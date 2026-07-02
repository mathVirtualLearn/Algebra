protocol GetExpressionsUseCase: Sendable {
    func execute(topicId: String?) async throws -> [Expression]
}

struct GetExpressionsUseCaseImpl: GetExpressionsUseCase {
    private let repository: ExpressionRepository

    init(repository: ExpressionRepository) {
        self.repository = repository
    }

    func execute(topicId: String?) async throws -> [Expression] {
        try await repository.fetch(topicId: topicId)
    }
}
