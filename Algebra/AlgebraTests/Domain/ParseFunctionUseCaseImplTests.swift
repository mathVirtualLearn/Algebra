import Testing
@testable import Algebra

struct ParseFunctionUseCaseImplTests {
    private let sut = ParseFunctionUseCaseImpl()

    @Test
    func test_givenImplicitMultiplication_whenParse_thenMulOfConstantAndVariable() {
        #expect(sut.execute("2x") == .mul(.constant(2), .variable))
    }

    @Test
    func test_givenCoefficientTimesFunction_whenParse_thenNestedCall() {
        let expected: FunctionExpr = .mul(.constant(2), .call(.cos, .mul(.constant(3), .variable)))
        #expect(sut.execute("2cos3x") == expected)
    }

    @Test
    func test_givenPower_whenParse_thenPowExpression() {
        #expect(sut.execute("x^2") == .pow(.variable, .constant(2)))
    }

    @Test
    func test_givenFunctionPlusConstant_whenParse_thenAddExpression() {
        #expect(sut.execute("sin(x)+1") == .add(.call(.sin, .variable), .constant(1)))
    }

    @Test
    func test_givenLeadingYEquals_whenParse_thenStripsPrefix() {
        #expect(sut.execute("y=x^2") == .pow(.variable, .constant(2)))
    }

    @Test
    func test_givenCommaDecimal_whenParse_thenTreatedAsDot() {
        #expect(sut.execute("1,5") == .constant(1.5))
    }

    @Test
    func test_givenEmptyText_whenParse_thenNil() {
        #expect(sut.execute("") == nil)
    }

    @Test
    func test_givenUnknownSymbol_whenParse_thenNil() {
        #expect(sut.execute("@") == nil)
    }

    @Test
    func test_givenUnbalancedParenthesis_whenParse_thenNil() {
        #expect(sut.execute("sin(x") == nil)
    }
}
