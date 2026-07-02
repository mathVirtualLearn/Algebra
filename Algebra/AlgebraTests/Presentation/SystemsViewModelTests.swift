import Testing
@testable import Algebra

@MainActor
struct SystemsViewModelTests {
    private func makeSUT(useCase: SolveSystemUseCaseMock) -> SystemsViewModel {
        SystemsViewModel(solve: useCase, mapper: SystemUIMapperImpl())
    }

    @Test
    func test_givenValid2x2_whenSolve_thenUseCaseReceivesParsedInputAndResultSet() {

        let useCase = SolveSystemUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.sizeIndex = 0
        sut.coefficients[0] = ["1", "1", ""]
        sut.coefficients[1] = ["1", "-1", ""]
        sut.constants = ["3", "1", ""]

        sut.solveTapped()

        let expected = SystemInputBuilder()
            .with(size: .two)
            .with(coefficients: [[1, 1], [1, -1]])
            .with(constants: [3, 1])
            .build()
        #expect(useCase.lastInput == expected)
        #expect(useCase.executeCallCount == 1)
        #expect(sut.result != nil)
        #expect(sut.inputError == nil)
    }

    @Test
    func test_givenNonNumericInput_whenSolve_thenErrorAndUseCaseNotCalled() {
        let useCase = SolveSystemUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.sizeIndex = 0
        sut.coefficients[0] = ["abc", "1", ""]
        sut.coefficients[1] = ["1", "-1", ""]
        sut.constants = ["3", "1", ""]
        sut.solveTapped()
        #expect(sut.inputError != nil)
        #expect(sut.result == nil)
        #expect(useCase.executeCallCount == 0)
    }

    @Test
    func test_givenSizeIndex_whenChanged_thenVariableNamesCountMatchesSize() {
        let sut = makeSUT(useCase: SolveSystemUseCaseMock())
        sut.sizeIndex = 0
        #expect(sut.variableNames.count == 2)
        sut.sizeIndex = 1
        #expect(sut.variableNames.count == 3)
    }

    @Test
    func test_givenMethodSelector_whenChanged_thenIndexUpdatesAndThreeTitlesExist() {
        let sut = makeSUT(useCase: SolveSystemUseCaseMock())

        #expect(sut.methodTitles.count == 3)

        #expect(sut.methodIndex == 0)
        sut.methodIndex = 2
        #expect(sut.methodIndex == 2)
    }

    @Test
    func test_givenMethodSelected_whenSolve_thenResultSetAndUseCaseCalled() {

        let useCase = SolveSystemUseCaseMock()
        let sut = makeSUT(useCase: useCase)
        sut.sizeIndex = 0
        sut.methodIndex = 1
        sut.coefficients[0] = ["1", "1", ""]
        sut.coefficients[1] = ["1", "-1", ""]
        sut.constants = ["3", "1", ""]
        sut.solveTapped()
        #expect(useCase.executeCallCount == 1)
        #expect(sut.result != nil)
        #expect(sut.inputError == nil)
    }
}
