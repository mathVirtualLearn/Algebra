import Testing
@testable import Algebra

struct GetTheoryArticleUseCaseImplTests {
    private func makeArticle(id: String) -> TheoryArticle {
        TheoryArticle(id: id, title: "T\(id)", summary: "S\(id)", blocks: [.paragraph("p")])
    }

    @Test
    func test_givenExistingId_whenExecute_thenReturnsArticle() async throws {
        let repository = TheoryRepositoryMock()
        repository.fetchResult = .success(makeArticle(id: "eq1"))
        let sut = GetTheoryArticleUseCaseImpl(repository: repository)

        let article = try await sut.execute(id: "eq1")

        #expect(article?.id == "eq1")
        #expect(repository.lastFetchedId == "eq1")
    }

    @Test
    func test_givenUnknownId_whenExecute_thenReturnsNil() async throws {
        let repository = TheoryRepositoryMock()
        repository.fetchResult = .success(nil)
        let sut = GetTheoryArticleUseCaseImpl(repository: repository)

        let article = try await sut.execute(id: "missing")

        #expect(article == nil)
    }

    @Test
    func test_givenRepositoryThrows_whenExecute_thenPropagatesError() async {
        let repository = TheoryRepositoryMock()
        repository.fetchResult = .failure(AlgebraError.loadFailed)
        let sut = GetTheoryArticleUseCaseImpl(repository: repository)

        await #expect(throws: AlgebraError.self) {
            _ = try await sut.execute(id: "eq1")
        }
    }
}
