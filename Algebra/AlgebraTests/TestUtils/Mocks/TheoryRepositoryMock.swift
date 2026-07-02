@testable import Algebra

final class TheoryRepositoryMock: TheoryRepository, @unchecked Sendable {
    var fetchAllResult: Result<[TheoryArticle], Error> = .success([])
    var fetchResult: Result<TheoryArticle?, Error> = .success(nil)
    private(set) var fetchAllCallCount = 0
    private(set) var fetchCallCount = 0
    private(set) var lastFetchedId: String?

    func fetchAll() async throws -> [TheoryArticle] {
        fetchAllCallCount += 1
        return try fetchAllResult.get()
    }

    func fetch(id: String) async throws -> TheoryArticle? {
        fetchCallCount += 1
        lastFetchedId = id
        return try fetchResult.get()
    }
}
