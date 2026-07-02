import Testing
@testable import Algebra

@MainActor
struct FunctionsViewModelTests {
    private func makeSUT(
        parse: ParseFunctionUseCaseMock,
        sample: SampleFunctionUseCaseMock
    ) -> FunctionsViewModel {
        FunctionsViewModel(parse: parse, sample: sample, mapper: FunctionUIMapperImpl())
    }

    @Test
    func test_givenValidExpression_whenPlot_thenPlotStateSetAndErrorCleared() {
        let parse = ParseFunctionUseCaseMock()
        parse.result = .pow(.variable, .constant(2))
        let sample = SampleFunctionUseCaseMock()
        sample.result = [FunctionSample(x: 0, y: 0), FunctionSample(x: 1, y: 1)]
        let sut = makeSUT(parse: parse, sample: sample)
        sut.expressionText = "x^2"

        sut.plotTapped()

        #expect(sut.plot != nil)
        #expect(sut.inputError == nil)
        #expect(parse.lastText == "x^2")
        #expect(sample.executeCallCount == 1)
        #expect(sut.plot?.functionLatex == "y = x^{2}")
    }

    @Test
    func test_givenInvalidExpression_whenPlot_thenErrorSetAndPlotNil() {
        let parse = ParseFunctionUseCaseMock()
        parse.result = nil
        let sample = SampleFunctionUseCaseMock()
        let sut = makeSUT(parse: parse, sample: sample)
        sut.expressionText = "???"

        sut.plotTapped()

        #expect(sut.plot == nil)
        #expect(sut.inputError != nil)
        #expect(sample.executeCallCount == 0)
    }
}
