@testable import Algebra

final class GetTheoryArticleUseCaseMock: GetTheoryArticleUseCase, @unchecked Sendable {
    var result: Result<TheoryArticle?, Error> = .success(nil)
    private(set) var executeCallCount = 0
    private(set) var lastId: String?

    func execute(id: String) async throws -> TheoryArticle? {
        executeCallCount += 1
        lastId = id
        return try result.get()
    }
}
