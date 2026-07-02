import Testing
@testable import Algebra

struct GetExpressionsUseCaseImplTests {
    @Test
    func test_givenRepoReturnsItems_whenExecute_thenMatchItems() async throws {

        let expected = [ExpressionBuilder().with(id: "7").build()]
        let repo = ExpressionRepositoryMock()
        repo.fetchResult = .success(expected)
        let sut = GetExpressionsUseCaseImpl(repository: repo)

        let result = try await sut.execute(topicId: nil)

        #expect(result == expected)
        #expect(repo.fetchCallCount == 1)
    }

    @Test
    func test_givenTopicId_whenExecute_thenForwardTopicToRepo() async throws {

        let repo = ExpressionRepositoryMock()
        repo.fetchResult = .success([])
        let sut = GetExpressionsUseCaseImpl(repository: repo)

        _ = try await sut.execute(topicId: "geometry")

        #expect(repo.lastTopicId == "geometry")
    }

    @Test
    func test_givenRepoThrows_whenExecute_thenThrow() async throws {

        let repo = ExpressionRepositoryMock()
        repo.fetchResult = .failure(AlgebraError.loadFailed)
        let sut = GetExpressionsUseCaseImpl(repository: repo)

        await #expect(throws: AlgebraError.loadFailed) {
            _ = try await sut.execute(topicId: nil)
        }
    }
}
