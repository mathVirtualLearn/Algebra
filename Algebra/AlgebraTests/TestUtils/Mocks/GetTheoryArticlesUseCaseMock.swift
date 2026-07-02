@testable import Algebra

final class GetTheoryArticlesUseCaseMock: GetTheoryArticlesUseCase, @unchecked Sendable {
    var result: Result<[TheoryArticle], Error> = .success([])
    private(set) var executeCallCount = 0

    func execute() async throws -> [TheoryArticle] {
        executeCallCount += 1
        return try result.get()
    }
}
