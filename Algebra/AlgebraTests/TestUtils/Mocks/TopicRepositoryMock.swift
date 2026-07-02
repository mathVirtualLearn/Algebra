@testable import Algebra

final class TopicRepositoryMock: TopicRepository, @unchecked Sendable {
    var fetchAllResult: Result<[Topic], Error> = .success([])
    private(set) var fetchAllCallCount = 0

    func fetchAll() async throws -> [Topic] {
        fetchAllCallCount += 1
        return try fetchAllResult.get()
    }
}
