import Testing
@testable import Algebra

struct GetTopicsUseCaseImplTests {
    @Test
    func test_givenRepoReturnsTopics_whenExecute_thenMatchTopics() async throws {

        let expected = [TopicBuilder().with(id: "geometry").build()]
        let repo = TopicRepositoryMock()
        repo.fetchAllResult = .success(expected)
        let sut = GetTopicsUseCaseImpl(repository: repo)

        let result = try await sut.execute()

        #expect(result == expected)
        #expect(repo.fetchAllCallCount == 1)
    }

    @Test
    func test_givenRepoThrows_whenExecute_thenThrow() async throws {

        let repo = TopicRepositoryMock()
        repo.fetchAllResult = .failure(AlgebraError.loadFailed)
        let sut = GetTopicsUseCaseImpl(repository: repo)

        await #expect(throws: AlgebraError.loadFailed) {
            _ = try await sut.execute()
        }
    }
}
