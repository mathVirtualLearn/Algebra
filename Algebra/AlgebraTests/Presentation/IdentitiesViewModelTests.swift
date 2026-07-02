import Testing
@testable import Algebra

@MainActor
struct IdentitiesViewModelTests {
    private func makeSUT(useCase: ExpandIdentityUseCaseMock) -> IdentitiesViewModel {
        IdentitiesViewModel(expand: useCase, mapper: IdentityUIMapperImpl())
    }

    @Test
    func test_givenValidInput_whenExpand_thenUseCaseReceivesParsedInputAndResultSet() {
        let useCase = ExpandIdentityUseCaseMock()
        useCase.result = IdentityResult(terms: [Monomial(coefficient: 25)])
        let sut = makeSUT(useCase: useCase)
        sut.identityIndex = 0
        sut.a = "2"
        sut.b = "3"

        sut.expandTapped()

        let expected = IdentityInputBuilder()
            .with(identity: .squareSum)
            .with(a: Monomial(coefficient: 2))
            .with(b: Monomial(coefficient: 3))
            .build()
        #expect(useCase.lastInput == expected)
        #expect(sut.result != nil)
        #expect(sut.inputError == nil)
    }

    @Test
    func test_givenNonMonomialInput_whenExpand_thenErrorAndUseCaseNotCalled() {
        let useCase = ExpandIdentityUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.a = "abc"
        sut.b = "3"

        sut.expandTapped()

        #expect(sut.inputError != nil)
        #expect(sut.result == nil)
        #expect(useCase.executeCallCount == 0)
    }

    @Test
    func test_givenMonomialInput_whenExpand_thenParsesVariable() {
        let useCase = ExpandIdentityUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.a = "x"
        sut.b = "3"

        sut.expandTapped()

        #expect(useCase.lastInput?.a == Monomial(coefficient: 1, variables: ["x": 1]))
    }

    @Test
    func test_givenIdentityIndexTwo_whenExpand_thenMapsToSumByDifference() {
        let useCase = ExpandIdentityUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.identityIndex = 2
        sut.a = "5"
        sut.b = "3"

        sut.expandTapped()

        #expect(useCase.lastInput?.identity == .sumByDifference)
    }

    @Test
    func test_givenIdentityIndexOne_whenExpand_thenMapsToSquareDifference() {
        let useCase = ExpandIdentityUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.identityIndex = 1
        sut.a = "5"
        sut.b = "3"

        sut.expandTapped()

        #expect(useCase.lastInput?.identity == .squareDifference)
    }
}
