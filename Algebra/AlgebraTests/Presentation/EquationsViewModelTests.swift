import Testing
@testable import Algebra

@MainActor
struct EquationsViewModelTests {
    private func makeSUT(useCase: SolveEquationUseCaseMock) -> EquationsViewModel {
        EquationsViewModel(solve: useCase, mapper: EquationUIMapperImpl())
    }

    @Test
    func test_givenValidQuadratic_whenSolve_thenUseCaseReceivesParsedInputAndResultSet() {

        let useCase = SolveEquationUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.typeIndex = 1
        sut.coefficients = ["1", "-3", "2", "", ""]

        sut.solveTapped()

        let expected = EquationInputBuilder().with(type: .quadratic)
            .with(coefficients: [1, -3, 2]).build()
        #expect(useCase.lastInput == expected)
        #expect(useCase.executeCallCount == 1)
        #expect(sut.result != nil)
        #expect(sut.inputError == nil)
    }

    @Test
    func test_givenNonNumericInput_whenSolve_thenErrorAndUseCaseNotCalled() {
        let useCase = SolveEquationUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.typeIndex = 1
        sut.coefficients = ["abc", "0", "0", "", ""]
        sut.solveTapped()
        #expect(sut.inputError != nil)
        #expect(sut.result == nil)
        #expect(useCase.executeCallCount == 0)
    }

    @Test
    func test_givenTypeIndex_whenChanged_thenCoefficientLabelsCountMatchesType() {
        let sut = makeSUT(useCase: SolveEquationUseCaseMock())
        sut.typeIndex = 2
        #expect(sut.coefficientLabels.count == 4)
        sut.typeIndex = 4
        #expect(sut.coefficientLabels.count == 3)
    }

    @Test
    func test_givenCommaDecimal_whenSolve_thenParsesAsDouble() {
        let useCase = SolveEquationUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.typeIndex = 1
        sut.coefficients = ["1,5", "", "", "", ""]
        sut.solveTapped()
        #expect(useCase.lastInput?.coefficients.first == 1.5)
    }
}
