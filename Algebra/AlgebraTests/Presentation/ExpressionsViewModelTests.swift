import Testing
@testable import Algebra

@MainActor
struct ExpressionsViewModelTests {
    private func makeSUT(
        topicId: String? = nil,
        useCase: GetExpressionsUseCaseMock
    ) -> ExpressionsViewModel {
        ExpressionsViewModel(topicId: topicId, getExpressions: useCase, mapper: ExpressionUIMapperImpl())
    }

    @Test
    func test_givenUseCaseReturnsItems_whenLoad_thenStateLoaded() async {

        let useCase = GetExpressionsUseCaseMock()
        useCase.result = .success([ExpressionBuilder().build()])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        guard case .loaded(let rows) = sut.state else {
            Issue.record("Esperaba .loaded, fue \(sut.state)")
            return
        }
        #expect(rows.count == 1)
        #expect(useCase.executeCallCount == 1)
    }

    @Test
    func test_givenTopicId_whenLoad_thenUseCaseReceivesTopic() async {

        let useCase = GetExpressionsUseCaseMock()
        useCase.result = .success([ExpressionBuilder().build()])
        let sut = makeSUT(topicId: "identities", useCase: useCase)

        await sut.load()

        #expect(useCase.lastTopicId == "identities")
    }

    @Test
    func test_givenUseCaseReturnsEmpty_whenLoad_thenStateEmpty() async {

        let useCase = GetExpressionsUseCaseMock()
        useCase.result = .success([])
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        #expect(sut.state == .empty)
    }

    @Test
    func test_givenUseCaseThrows_whenLoad_thenStateError() async {

        let useCase = GetExpressionsUseCaseMock()
        useCase.result = .failure(AlgebraError.loadFailed)
        let sut = makeSUT(useCase: useCase)

        await sut.load()

        guard case .error = sut.state else {
            Issue.record("Esperaba .error, fue \(sut.state)")
            return
        }
    }
}
