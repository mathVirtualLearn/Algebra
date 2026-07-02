protocol ExpressionRepository: Sendable {

    func fetch(topicId: String?) async throws -> [Expression]
}
