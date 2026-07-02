import Testing
import Foundation
@testable import Algebra

struct FunctionExprTests {
    private func isClose(_ lhs: Double, _ rhs: Double) -> Bool {
        Swift.abs(lhs - rhs) < 1e-9
    }

    @Test
    func test_givenConstant_whenEvaluate_thenReturnsValue() {
        #expect(FunctionExpr.constant(5).evaluate(99) == 5)
    }

    @Test
    func test_givenVariable_whenEvaluate_thenReturnsX() {
        #expect(FunctionExpr.variable.evaluate(3) == 3)
    }

    @Test
    func test_givenNeg_whenEvaluate_thenNegatesOperand() {
        #expect(FunctionExpr.neg(.variable).evaluate(3) == -3)
    }

    @Test
    func test_givenAdd_whenEvaluate_thenSum() {
        #expect(FunctionExpr.add(.variable, .constant(1)).evaluate(2) == 3)
    }

    @Test
    func test_givenSub_whenEvaluate_thenDifference() {
        #expect(FunctionExpr.sub(.variable, .constant(1)).evaluate(2) == 1)
    }

    @Test
    func test_givenMul_whenEvaluate_thenProduct() {
        #expect(FunctionExpr.mul(.variable, .constant(2)).evaluate(3) == 6)
    }

    @Test
    func test_givenDiv_whenEvaluate_thenQuotient() {
        #expect(FunctionExpr.div(.constant(6), .constant(2)).evaluate(0) == 3)
    }

    @Test
    func test_givenPow_whenEvaluate_thenPower() {
        #expect(FunctionExpr.pow(.variable, .constant(2)).evaluate(3) == 9)
    }

    @Test
    func test_givenSin_whenEvaluate_thenSine() {
        #expect(FunctionExpr.call(.sin, .constant(0)).evaluate(0) == 0)
    }

    @Test
    func test_givenCos_whenEvaluate_thenCosine() {
        #expect(FunctionExpr.call(.cos, .constant(0)).evaluate(0) == 1)
    }

    @Test
    func test_givenTan_whenEvaluate_thenTangent() {
        #expect(FunctionExpr.call(.tan, .constant(0)).evaluate(0) == 0)
    }

    @Test
    func test_givenLn_whenEvaluate_thenNaturalLog() {
        #expect(isClose(FunctionExpr.call(.ln, .constant(M_E)).evaluate(0), 1))
    }

    @Test
    func test_givenLog_whenEvaluate_thenBase10Log() {
        #expect(isClose(FunctionExpr.call(.log, .constant(100)).evaluate(0), 2))
    }

    @Test
    func test_givenExp_whenEvaluate_thenExponential() {
        #expect(FunctionExpr.call(.exp, .constant(0)).evaluate(0) == 1)
    }

    @Test
    func test_givenSqrtOfPositive_whenEvaluate_thenRoot() {
        #expect(FunctionExpr.call(.sqrt, .constant(9)).evaluate(0) == 3)
    }

    @Test
    func test_givenSqrtOfNegative_whenEvaluate_thenNaN() {
        #expect(FunctionExpr.call(.sqrt, .constant(-1)).evaluate(0).isNaN)
    }

    @Test
    func test_givenAbs_whenEvaluate_thenAbsoluteValue() {
        #expect(FunctionExpr.call(.abs, .constant(-5)).evaluate(0) == 5)
    }

    @Test
    func test_givenConstant_whenLatex_thenNumber() {
        #expect(FunctionExpr.constant(5).latex() == "5")
    }

    @Test
    func test_givenVariable_whenLatex_thenX() {
        #expect(FunctionExpr.variable.latex() == "x")
    }

    @Test
    func test_givenAdd_whenLatex_thenJoinedWithPlus() {
        #expect(FunctionExpr.add(.variable, .constant(1)).latex() == "x + 1")
    }

    @Test
    func test_givenSub_whenLatex_thenJoinedWithMinus() {
        #expect(FunctionExpr.sub(.variable, .constant(1)).latex() == "x - 1")
    }

    @Test
    func test_givenNumberTimesNumber_whenLatex_thenCdot() {
        #expect(FunctionExpr.mul(.constant(2), .constant(3)).latex() == "2 \\cdot 3")
    }

    @Test
    func test_givenNumberTimesVariable_whenLatex_thenJuxtaposed() {
        #expect(FunctionExpr.mul(.constant(2), .variable).latex() == "2x")
    }

    @Test
    func test_givenDiv_whenLatex_thenFraction() {
        #expect(FunctionExpr.div(.variable, .constant(2)).latex() == "\\frac{x}{2}")
    }

    @Test
    func test_givenPow_whenLatex_thenBaseWithExponent() {
        #expect(FunctionExpr.pow(.variable, .constant(2)).latex() == "x^{2}")
    }

    @Test
    func test_givenSin_whenLatex_thenSinCommand() {
        #expect(FunctionExpr.call(.sin, .variable).latex() == "\\sin(x)")
    }

    @Test
    func test_givenExp_whenLatex_thenEPower() {
        #expect(FunctionExpr.call(.exp, .variable).latex() == "e^{x}")
    }

    @Test
    func test_givenAbs_whenLatex_thenBars() {
        #expect(FunctionExpr.call(.abs, .variable).latex() == "\\left|x\\right|")
    }

    @Test
    func test_givenNegatedSqrt_whenLatex_thenWrapsInParentheses() {
        #expect(FunctionExpr.neg(.call(.sqrt, .variable)).latex() == "-\\left(\\sqrt{x}\\right)")
    }
}
