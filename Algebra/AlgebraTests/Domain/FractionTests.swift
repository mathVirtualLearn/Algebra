import Testing
@testable import Algebra

struct FractionTests {

    @Test
    func test_givenReducibleFraction_whenInit_thenReducedToLowestTerms() async throws {

        let sut = Fraction(2, 4)

        #expect(sut.numerator == 1)
        #expect(sut.denominator == 2)
    }

    @Test
    func test_givenZeroDenominator_whenInit_thenSafeZeroOverOne() async throws {
        let sut = Fraction(5, 0)
        #expect(sut.numerator == 0)
        #expect(sut.denominator == 1)
    }

    @Test
    func test_givenNegativeDenominator_whenInit_thenSignMovesToNumerator() async throws {
        let sut = Fraction(1, -2)
        #expect(sut.numerator == -1)
        #expect(sut.denominator == 2)
    }

    @Test
    func test_givenBothNegative_whenInit_thenResultIsPositive() async throws {
        let sut = Fraction(-3, -6)
        #expect(sut.numerator == 1)
        #expect(sut.denominator == 2)
        #expect(sut.isNegative == false)
    }

    @Test
    func test_givenTwoFractions_whenAdd_thenMatchExactSum() async throws {
        let sut = Fraction(1, 2) + Fraction(1, 3)
        #expect(sut == Fraction(5, 6))
    }

    @Test
    func test_givenTwoFractions_whenSubtract_thenMatchExactDifference() async throws {
        let sut = Fraction(1, 2) - Fraction(1, 3)
        #expect(sut == Fraction(1, 6))
    }

    @Test
    func test_givenTwoFractions_whenMultiply_thenMatchReducedProduct() async throws {
        let sut = Fraction(1, 2) * Fraction(2, 3)
        #expect(sut == Fraction(1, 3))
    }

    @Test
    func test_givenTwoFractions_whenDivide_thenMatchReducedQuotient() async throws {
        let sut = Fraction(1, 2) / Fraction(1, 3)
        #expect(sut == Fraction(3, 2))
    }

    @Test
    func test_givenFraction_whenNegate_thenSignFlips() async throws {
        let sut = -Fraction(19, 64)
        #expect(sut == Fraction(-19, 64))
        #expect(sut.isNegative == true)
    }

    @Test
    func test_givenOneHalf_whenApproximating_thenMatchOneHalf() async throws {
        let sut = Fraction(approximating: 0.5)
        #expect(sut.numerator == 1)
        #expect(sut.denominator == 2)
    }

    @Test
    func test_givenExactRational_whenApproximating_thenMatchExactFraction() async throws {

        let sut = Fraction(approximating: -0.296875)
        #expect(sut.numerator == -19)
        #expect(sut.denominator == 64)
    }

    @Test
    func test_givenIntegerValued_whenApproximating_thenDenominatorIsOne() async throws {
        let sut = Fraction(approximating: 5.0)
        #expect(sut.numerator == 5)
        #expect(sut.denominator == 1)
        #expect(sut.isInteger == true)
    }

    @Test
    func test_givenIntegerFraction_whenIsInteger_thenTrue() async throws {
        #expect(Fraction(5).isInteger == true)
    }

    @Test
    func test_givenProperFraction_whenIsInteger_thenFalse() async throws {
        #expect(Fraction(1, 2).isInteger == false)
    }

    @Test
    func test_givenInteger_whenLatex_thenPlainNumber() async throws {
        #expect(Fraction(5).latex() == "5")
    }

    @Test
    func test_givenProperFraction_whenLatex_thenContainsDisplaystyleFrac() async throws {
        let latex = Fraction(59, 64).latex()
        #expect(latex.contains("\\displaystyle\\frac{59}{64}"))

        #expect(latex.contains("\\frac"))
    }

    @Test
    func test_givenNegativeFraction_whenLatex_thenStartsWithMinus() async throws {
        let latex = Fraction(-19, 64).latex()
        #expect(latex.hasPrefix("-"))
        #expect(latex.contains("\\displaystyle\\frac{19}{64}"))
    }

    @Test
    func test_givenPositiveInteger_whenParsing_thenMatchesInteger() async throws {
        #expect(Fraction(parsing: "2") == Fraction(2))
    }

    @Test
    func test_givenNegativeInteger_whenParsing_thenMatchesInteger() async throws {
        #expect(Fraction(parsing: "-2") == Fraction(-2))
    }

    @Test
    func test_givenPositiveFraction_whenParsing_thenMatchesFraction() async throws {
        #expect(Fraction(parsing: "3/2") == Fraction(3, 2))
    }

    @Test
    func test_givenNegativeFraction_whenParsing_thenMatchesFraction() async throws {
        #expect(Fraction(parsing: "-3/2") == Fraction(-3, 2))
    }

    @Test
    func test_givenSurroundingWhitespace_whenParsing_thenParsedIgnoringSpaces() async throws {
        #expect(Fraction(parsing: "  3 / 2 ") == Fraction(3, 2))
    }

    @Test
    func test_givenEmptyString_whenParsing_thenNil() async throws {
        #expect(Fraction(parsing: "") == nil)
    }

    @Test
    func test_givenDecimalString_whenParsing_thenNil() async throws {
        #expect(Fraction(parsing: "1.5") == nil)
    }

    @Test
    func test_givenNonNumericString_whenParsing_thenNil() async throws {
        #expect(Fraction(parsing: "x") == nil)
    }

    @Test
    func test_givenZeroDenominatorString_whenParsing_thenNil() async throws {
        #expect(Fraction(parsing: "3/0") == nil)
    }

    @Test
    func test_givenTooManyParts_whenParsing_thenNil() async throws {
        #expect(Fraction(parsing: "1/2/3") == nil)
    }

    @Test
    func test_givenEquivalentFractions_whenCompared_thenEqual() async throws {
        #expect(Fraction(2, 4) == Fraction(1, 2))
    }

    @Test
    func test_givenEquivalentFractions_whenHashed_thenSameHashValue() async throws {
        #expect(Fraction(2, 4).hashValue == Fraction(1, 2).hashValue)
    }

    @Test
    func test_givenEquivalentFractions_whenInsertedInSet_thenDeduplicated() async throws {
        let set: Set<Fraction> = [Fraction(2, 4), Fraction(1, 2), Fraction(3, 6)]
        #expect(set == [Fraction(1, 2)])
    }
}
