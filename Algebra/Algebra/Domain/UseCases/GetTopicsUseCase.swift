protocol GetTopicsUseCase: Sendable {
    func execute() async throws -> [Topic]
}

struct GetTopicsUseCaseImpl: GetTopicsUseCase {
    private let repository: TopicRepository

    init(repository: TopicRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Topic] {
        try await repository.fetchAll()
    }
}
