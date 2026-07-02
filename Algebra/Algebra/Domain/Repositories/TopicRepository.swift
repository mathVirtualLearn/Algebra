protocol TopicRepository: Sendable {
    func fetchAll() async throws -> [Topic]
}
