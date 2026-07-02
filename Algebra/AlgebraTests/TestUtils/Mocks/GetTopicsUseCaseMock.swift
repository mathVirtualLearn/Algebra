@testable import Algebra

final class GetTopicsUseCaseMock: GetTopicsUseCase, @unchecked Sendable {
    var result: Result<[Topic], Error> = .success([])
    private(set) var executeCallCount = 0

    func execute() async throws -> [Topic] {
        executeCallCount += 1
        return try result.get()
    }
}
