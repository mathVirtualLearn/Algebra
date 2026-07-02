import Testing
@testable import Algebra

@MainActor
struct HomeViewModelTests {
    private func makeSUT(useCase: GetTopicsUseCaseMock) -> HomeViewModel {
        HomeViewModel(getTopics: useCase, mapper: TopicUIMapperImpl())
    }

    @Test
    func test_givenUseCaseReturnsTopics_whenLoad_thenStateLoaded() async {

        let useCase = GetTopicsUseCaseMock()
        useCase.result = .success([TopicBuilder().build(), TopicBuilder().with(id: "geometry").build()])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        guard case .loaded(let cards) = sut.state else {
            Issue.record("Esperaba .loaded, fue \(sut.state)")
            return
        }
        #expect(cards.count == 2)
        #expect(useCase.executeCallCount == 1)
    }

    @Test
    func test_givenUseCaseReturnsEmpty_whenLoad_thenStateEmpty() async {

        let useCase = GetTopicsUseCaseMock()
        useCase.result = .success([])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test
    func test_givenUseCaseThrows_whenLoad_thenStateError() async {

        let useCase = GetTopicsUseCaseMock()
        useCase.result = .failure(AlgebraError.loadFailed)
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        guard case .error = sut.state else {
            Issue.record("Esperaba .error, fue \(sut.state)")
            return
        }
    }
}
