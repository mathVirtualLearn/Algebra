@testable import Algebra

final class ExpressionRepositoryMock: ExpressionRepository, @unchecked Sendable {
    var fetchResult: Result<[Expression], Error> = .success([])
    private(set) var fetchCallCount = 0
    private(set) var lastTopicId: String?

    func fetch(topicId: String?) async throws -> [Expression] {
        fetchCallCount += 1
        lastTopicId = topicId
        return try fetchResult.get()
    }
}
