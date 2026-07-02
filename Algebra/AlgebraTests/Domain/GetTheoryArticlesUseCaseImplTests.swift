import Testing
@testable import Algebra

struct GetTheoryArticlesUseCaseImplTests {
    private func makeArticle(id: String) -> TheoryArticle {
        TheoryArticle(id: id, title: "T\(id)", summary: "S\(id)", blocks: [.paragraph("p")])
    }

    @Test
    func test_givenRepositoryReturnsArticles_whenExecute_thenForwardsThem() async throws {
        let repository = TheoryRepositoryMock()
        repository.fetchAllResult = .success([makeArticle(id: "a"), makeArticle(id: "b")])
        let sut = GetTheoryArticlesUseCaseImpl(repository: repository)

        let articles = try await sut.execute()

        #expect(articles.map(\.id) == ["a", "b"])
        #expect(repository.fetchAllCallCount == 1)
    }

    @Test
    func test_givenRepositoryThrows_whenExecute_thenPropagatesError() async {
        let repository = TheoryRepositoryMock()
        repository.fetchAllResult = .failure(AlgebraError.loadFailed)
        let sut = GetTheoryArticlesUseCaseImpl(repository: repository)

        await #expect(throws: AlgebraError.self) {
            _ = try await sut.execute()
        }
    }
}
