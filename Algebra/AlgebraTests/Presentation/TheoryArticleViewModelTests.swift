import Testing
@testable import Algebra

@MainActor
struct TheoryArticleViewModelTests {
    private func makeArticle(id: String) -> TheoryArticle {
        TheoryArticle(id: id, title: "Título", summary: "S", blocks: [.heading("H"), .paragraph("p")])
    }

    private func makeSUT(id: String, useCase: GetTheoryArticleUseCaseMock) -> TheoryArticleViewModel {
        TheoryArticleViewModel(id: id, getArticle: useCase, mapper: TheoryUIMapperImpl())
    }

    @Test
    func test_givenExistingArticle_whenLoad_thenStateLoaded() async {
        let useCase = GetTheoryArticleUseCaseMock()
        useCase.result = .success(makeArticle(id: "eq1"))
        let sut = makeSUT(id: "eq1", useCase: useCase)

        await sut.load()

        #expect(sut.state == .loaded(TheoryArticleState(
            title: "Título",
            blocks: [.heading(id: 0, "H"), .paragraph(id: 1, "p")]
        )))
        #expect(useCase.lastId == "eq1")
    }

    @Test
    func test_givenUnknownArticle_whenLoad_thenStateNotFound() async {
        let useCase = GetTheoryArticleUseCaseMock()
        useCase.result = .success(nil)
        let sut = makeSUT(id: "missing", useCase: useCase)

        await sut.load()

        #expect(sut.state == .notFound)
    }

    @Test
    func test_givenUseCaseThrows_whenLoad_thenStateError() async {
        let useCase = GetTheoryArticleUseCaseMock()
        useCase.result = .failure(AlgebraError.loadFailed)
        let sut = makeSUT(id: "eq1", useCase: useCase)

        await sut.load()

        if case .error = sut.state {
            #expect(Bool(true))
        } else {
            Issue.record("Expected error state, got \(sut.state)")
        }
    }
}
