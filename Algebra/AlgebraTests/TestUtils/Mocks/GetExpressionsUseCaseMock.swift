@testable import Algebra

final class GetExpressionsUseCaseMock: GetExpressionsUseCase, @unchecked Sendable {
    var result: Result<[Expression], Error> = .success([])
    private(set) var executeCallCount = 0
    private(set) var lastTopicId: String?

    func execute(topicId: String?) async throws -> [Expression] {
        executeCallCount += 1
        lastTopicId = topicId
        return try result.get()
    }
}
