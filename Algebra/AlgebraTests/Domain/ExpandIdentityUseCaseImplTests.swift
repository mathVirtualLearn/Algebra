import Testing
@testable import Algebra

struct ExpandIdentityUseCaseImplTests {
    private let sut = ExpandIdentityUseCaseImpl()

    @Test
    func test_givenSquareSum_whenExecute_thenReturnsSquareOfBinomialTerms() {
        let input = IdentityInputBuilder()
            .with(identity: .squareSum)
            .with(a: Monomial(coefficient: 1, variables: ["x": 1]))
            .with(b: Monomial(coefficient: 3))
            .build()

        let result = sut.execute(input)

        #expect(result.terms == [
            Monomial(coefficient: 1, variables: ["x": 2]),
            Monomial(coefficient: 6, variables: ["x": 1]),
            Monomial(coefficient: 9)
        ])
    }

    @Test
    func test_givenSquareDifference_whenExecute_thenMiddleTermIsNegative() {
        let input = IdentityInputBuilder()
            .with(identity: .squareDifference)
            .with(a: Monomial(coefficient: 1, variables: ["x": 1]))
            .with(b: Monomial(coefficient: 3))
            .build()

        let result = sut.execute(input)

        #expect(result.terms == [
            Monomial(coefficient: 1, variables: ["x": 2]),
            Monomial(coefficient: -6, variables: ["x": 1]),
            Monomial(coefficient: 9)
        ])
    }

    @Test
    func test_givenSumByDifference_whenExecute_thenReturnsDifferenceOfSquares() {
        let input = IdentityInputBuilder()
            .with(identity: .sumByDifference)
            .with(a: Monomial(coefficient: 1, variables: ["x": 1]))
            .with(b: Monomial(coefficient: 3))
            .build()

        let result = sut.execute(input)

        #expect(result.terms == [
            Monomial(coefficient: 1, variables: ["x": 2]),
            Monomial(coefficient: -9)
        ])
    }

    @Test
    func test_givenNumericOperands_whenExecute_thenTermsCollapseToConstant() {
        let input = IdentityInputBuilder()
            .with(identity: .squareSum)
            .with(a: Monomial(coefficient: 2))
            .with(b: Monomial(coefficient: 3))
            .build()

        let result = sut.execute(input)

        #expect(result.terms == [Monomial(coefficient: 25)])
    }
}
