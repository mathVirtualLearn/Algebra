import Testing
@testable import Algebra

struct SolveEquationUseCaseImplTests {
    private let sut = SolveEquationUseCaseImpl()

    @Test
    func test_givenLinear_whenSolve_thenReturnUniqueRoot() {

        let input = EquationInputBuilder().with(type: .linear).with(coefficients: [2, -4]).build()
        let result = sut.execute(input)
        #expect(result.roots == [2])
        #expect(result.outcome == .solved)
        #expect(result.method == .linearFormula)
    }

    @Test
    func test_givenLinearWithZeroSlopeAndConstant_whenSolve_thenNoSolution() {

        let input = EquationInputBuilder().with(type: .linear).with(coefficients: [0, 5]).build()
        let result = sut.execute(input)
        #expect(result.outcome == .noSolution)
        #expect(result.roots.isEmpty)
    }

    @Test
    func test_givenLinearAllZero_whenSolve_thenInfiniteSolutions() {

        let input = EquationInputBuilder().with(type: .linear).with(coefficients: [0, 0]).build()
        let result = sut.execute(input)
        #expect(result.outcome == .infiniteSolutions)
        #expect(result.roots.isEmpty)
    }

    @Test
    func test_givenQuadraticPositiveDiscriminant_whenSolve_thenTwoRoots() {

        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, -3, 2]).build()
        let result = sut.execute(input)
        #expect(result.roots == [1, 2])
        #expect(result.outcome == .solved)
        #expect(result.method == .quadraticFormula)
        #expect(result.discriminant == 1)
    }

    @Test
    func test_givenQuadraticNegativeDiscriminant_whenSolve_thenNoRealSolutions() {

        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, 0, 1]).build()
        let result = sut.execute(input)
        #expect(result.outcome == .noRealSolutions)
        #expect(result.roots.isEmpty)
    }

    @Test
    func test_givenCubicWithRationalRoots_whenSolve_thenRuffiniReturnsThreeRoots() {

        let input = EquationInputBuilder().with(type: .cubic).with(coefficients: [1, -6, 11, -6]).build()
        let result = sut.execute(input)
        #expect(result.roots == [1, 2, 3])
        #expect(result.outcome == .solved)
        #expect(result.method == .ruffini)
        #expect(!result.ruffiniSteps.isEmpty)
    }

    @Test
    func test_givenCubicWithoutRationalRoot_whenSolve_thenPartial() {

        let input = EquationInputBuilder().with(type: .cubic).with(coefficients: [1, 0, 0, -2]).build()
        let result = sut.execute(input)
        #expect(result.outcome == .partial)
        #expect(result.roots.isEmpty)
        #expect(result.method == .ruffini)
    }

    @Test
    func test_givenQuarticWithRationalRoots_whenSolve_thenRuffiniReturnsFourRoots() {

        let input = EquationInputBuilder().with(type: .quartic)
            .with(coefficients: [1, -10, 35, -50, 24]).build()
        let result = sut.execute(input)
        #expect(result.roots == [1, 2, 3, 4])
        #expect(result.outcome == .solved)
        #expect(result.method == .ruffini)
        #expect(!result.ruffiniSteps.isEmpty)
    }

    @Test
    func test_givenBiquadraticWithFourRoots_whenSolve_thenReturnsSymmetricRoots() {

        let input = EquationInputBuilder().with(type: .biquadratic)
            .with(coefficients: [1, -5, 4]).build()
        let result = sut.execute(input)
        #expect(result.roots == [-2, -1, 1, 2])
        #expect(result.outcome == .solved)
        #expect(result.method == .biquadratic)
    }

    @Test
    func test_givenBiquadraticWithoutRealRoots_whenSolve_thenNoRealSolutions() {

        let input = EquationInputBuilder().with(type: .biquadratic)
            .with(coefficients: [1, 0, 1]).build()
        let result = sut.execute(input)
        #expect(result.outcome == .noRealSolutions)
        #expect(result.roots.isEmpty)
        #expect(result.method == .biquadratic)
    }
}
