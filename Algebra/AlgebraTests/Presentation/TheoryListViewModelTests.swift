import Testing
@testable import Algebra

@MainActor
struct TheoryListViewModelTests {
    private func makeArticle(id: String) -> TheoryArticle {
        TheoryArticle(id: id, title: "T\(id)", summary: "S\(id)", blocks: [.paragraph("p")])
    }

    private func makeSUT(useCase: GetTheoryArticlesUseCaseMock) -> TheoryListViewModel {
        TheoryListViewModel(getArticles: useCase, mapper: TheoryUIMapperImpl())
    }

    @Test
    func test_givenArticles_whenLoad_thenStateLoaded() async {
        let useCase = GetTheoryArticlesUseCaseMock()
        useCase.result = .success([makeArticle(id: "a"), makeArticle(id: "b")])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        #expect(sut.state == .loaded([
            TheoryListItemState(id: "a", title: "Ta", summary: "Sa"),
            TheoryListItemState(id: "b", title: "Tb", summary: "Sb")
        ]))
    }

    @Test
    func test_givenNoArticles_whenLoad_thenStateEmpty() async {
        let useCase = GetTheoryArticlesUseCaseMock()
        useCase.result = .success([])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test
    func test_givenUseCaseThrows_whenLoad_thenStateError() async {
        let useCase = GetTheoryArticlesUseCaseMock()
        useCase.result = .failure(AlgebraError.loadFailed)
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        if case .error = sut.state {
            #expect(Bool(true))
        } else {
            Issue.record("Expected error state, got \(sut.state)")
        }
    }
}
