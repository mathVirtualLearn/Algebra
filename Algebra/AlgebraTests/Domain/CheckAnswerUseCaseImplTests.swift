import Testing
@testable import Algebra

struct CheckEquationAnswerUseCaseImplTests {
    private let sut = CheckEquationAnswerUseCaseImpl()

    @Test
    func test_givenIntegerRootsInSameOrder_whenCheck_thenTrue() {
        #expect(sut.execute(answer: "-1, 2, 3", roots: [Fraction(-1), Fraction(2), Fraction(3)]))
    }

    @Test
    func test_givenIntegerRootsSpaceSeparatedOutOfOrder_whenCheck_thenTrue() {
        #expect(sut.execute(answer: "3 2 -1", roots: [Fraction(-1), Fraction(2), Fraction(3)]))
    }

    @Test
    func test_givenFractionalRootsOutOfOrder_whenCheck_thenTrue() {
        #expect(sut.execute(answer: "-1, 3/2", roots: [Fraction(3, 2), Fraction(-1)]))
    }

    @Test
    func test_givenFractionalRootsInOrder_whenCheck_thenTrue() {
        #expect(sut.execute(answer: "3/2, -1", roots: [Fraction(3, 2), Fraction(-1)]))
    }

    @Test
    func test_givenEquivalentUnreducedFraction_whenCheck_thenTrue() {
        #expect(sut.execute(answer: "6/4, -1", roots: [Fraction(3, 2), Fraction(-1)]))
    }

    @Test
    func test_givenFractionNotInRoots_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "1/2", roots: [Fraction(3, 2), Fraction(-1)]))
    }

    @Test
    func test_givenMissingRoot_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "2, 3", roots: [Fraction(-1), Fraction(2), Fraction(3)]))
    }

    @Test
    func test_givenExtraRoot_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "-1, 2, 3, 4", roots: [Fraction(-1), Fraction(2), Fraction(3)]))
    }

    @Test
    func test_givenNonParseableToken_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "2, x", roots: [Fraction(2)]))
    }

    @Test
    func test_givenDecimalToken_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "1.5, 3", roots: [Fraction(3, 2), Fraction(3)]))
    }

    @Test
    func test_givenEmptyAnswer_whenCheck_thenFalse() {
        #expect(!sut.execute(answer: "", roots: [Fraction(2), Fraction(3)]))
    }
}

struct CheckSystemAnswerUseCaseImplTests {
    private let sut = CheckSystemAnswerUseCaseImpl()

    @Test
    func test_givenCorrectIntegerAnswers_whenCheck_thenTrue() {
        #expect(sut.execute(answers: ["1", "-2", "3"], solution: [Fraction(1), Fraction(-2), Fraction(3)]))
    }

    @Test
    func test_givenCorrectFractionalAnswers_whenCheck_thenTrue() {
        #expect(sut.execute(answers: ["3/2", "-2"], solution: [Fraction(3, 2), Fraction(-2)]))
    }

    @Test
    func test_givenEquivalentUnreducedFractionalAnswers_whenCheck_thenTrue() {
        #expect(sut.execute(answers: ["6/4", "-2"], solution: [Fraction(3, 2), Fraction(-2)]))
    }

    @Test
    func test_givenOneWrongAnswer_whenCheck_thenFalse() {
        #expect(!sut.execute(answers: ["1", "5", "3"], solution: [Fraction(1), Fraction(-2), Fraction(3)]))
    }

    @Test
    func test_givenNonParseableAnswer_whenCheck_thenFalse() {
        #expect(!sut.execute(answers: ["3/2", "y"], solution: [Fraction(3, 2), Fraction(-2)]))
    }

    @Test
    func test_givenEmptyAnswer_whenCheck_thenFalse() {
        #expect(!sut.execute(answers: ["1", "", "3"], solution: [Fraction(1), Fraction(-2), Fraction(3)]))
    }

    @Test
    func test_givenWrongNumberOfElements_whenCheck_thenFalse() {
        #expect(!sut.execute(answers: ["1", "-2"], solution: [Fraction(1), Fraction(-2), Fraction(3)]))
    }
}
