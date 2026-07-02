import Testing
@testable import Algebra

struct MonomialTests {
    @Test
    func test_givenNumber_whenParse_thenConstantMonomial() {
        #expect(Monomial.parse("7") == Monomial(coefficient: 7))
    }

    @Test
    func test_givenNegativeVariable_whenParse_thenCoefficientAndExponent() {
        #expect(Monomial.parse("-3x^2") == Monomial(coefficient: -3, variables: ["x": 2]))
    }

    @Test
    func test_givenBareVariable_whenParse_thenCoefficientOne() {
        #expect(Monomial.parse("x") == Monomial(coefficient: 1, variables: ["x": 1]))
    }

    @Test
    func test_givenEmptyString_whenParse_thenZeroMonomial() {
        #expect(Monomial.parse("   ") == Monomial(coefficient: 0))
    }

    @Test
    func test_givenInvalidText_whenParse_thenNil() {
        #expect(Monomial.parse("3xy") == nil)
        #expect(Monomial.parse("2x^") == nil)
    }

    @Test
    func test_givenVariable_whenSquared_thenExponentDoublesAndCoefficientSquared() {
        let m = Monomial(coefficient: 3, variables: ["x": 2])
        #expect(m.squared == Monomial(coefficient: 9, variables: ["x": 4]))
    }

    @Test
    func test_givenTwoMonomials_whenMultiplied_thenExponentsAddAndCoefficientsMultiply() {
        let lhs = Monomial(coefficient: 2, variables: ["x": 1])
        let rhs = Monomial(coefficient: 3, variables: ["x": 2, "y": 1])
        #expect(lhs * rhs == Monomial(coefficient: 6, variables: ["x": 3, "y": 1]))
    }

    @Test
    func test_givenMonomial_whenNegated_thenCoefficientSignFlips() {
        #expect(-Monomial(coefficient: 4, variables: ["x": 1]) == Monomial(coefficient: -4, variables: ["x": 1]))
    }

    @Test
    func test_givenZeroCoefficient_whenCreated_thenIsZeroAndDropsVariables() {
        let m = Monomial(coefficient: 0, variables: ["x": 3])
        #expect(m.isZero)
        #expect(m.variables.isEmpty)
    }

    @Test
    func test_givenConstant_whenLatex_thenNumberString() {
        #expect(Monomial(coefficient: 5).latex() == "5")
    }

    @Test
    func test_givenCoefficientOne_whenLatex_thenOmitsCoefficient() {
        #expect(Monomial(coefficient: 1, variables: ["x": 2]).latex() == "x^2")
    }

    @Test
    func test_givenCoefficientMinusOne_whenLatex_thenLeadingMinus() {
        #expect(Monomial(coefficient: -1, variables: ["x": 1]).latex() == "-x")
    }

    @Test
    func test_givenExponentOne_whenLatex_thenNoExponent() {
        #expect(Monomial(coefficient: 4, variables: ["x": 1]).latex() == "4x")
    }
}
