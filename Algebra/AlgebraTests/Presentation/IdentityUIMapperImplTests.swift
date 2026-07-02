import Testing
@testable import Algebra

struct IdentityUIMapperImplTests {
    private let sut = IdentityUIMapperImpl()

    private func makeInput(_ identity: NotableIdentity, a: Int, b: Int) -> IdentityInput {
        IdentityInputBuilder()
            .with(identity: identity)
            .with(a: Monomial(coefficient: a))
            .with(b: Monomial(coefficient: b))
            .build()
    }

    @Test
    func test_givenSquareSum_whenMap_thenBuildsGeneralIdentityLatex() {
        let state = sut.map(input: makeInput(.squareSum, a: 2, b: 3), result: IdentityResult(terms: [Monomial(coefficient: 25)]))
        #expect(state.identityLatex == "(a + b)^2 = a^2 + 2ab + b^2")
    }

    @Test
    func test_givenSquareDifference_whenMap_thenBuildsGeneralIdentityLatex() {
        let state = sut.map(input: makeInput(.squareDifference, a: 5, b: 3), result: IdentityResult(terms: [Monomial(coefficient: 4)]))
        #expect(state.identityLatex == "(a - b)^2 = a^2 - 2ab + b^2")
    }

    @Test
    func test_givenSumByDifference_whenMap_thenBuildsGeneralIdentityLatex() {
        let state = sut.map(input: makeInput(.sumByDifference, a: 5, b: 3), result: IdentityResult(terms: [Monomial(coefficient: 16)]))
        #expect(state.identityLatex == "(a + b)(a - b) = a^2 - b^2")
    }

    @Test
    func test_givenAnyIdentity_whenMap_thenDevelopmentLatexHasEqualityAndResult() {
        let state = sut.map(input: makeInput(.squareSum, a: 2, b: 3), result: IdentityResult(terms: [Monomial(coefficient: 25)]))
        #expect(state.developmentLatex.contains("="))
        #expect(state.developmentLatex.contains("25"))
        #expect(state.identityLatex.isEmpty == false)
    }

    @Test
    func test_givenAnyIdentity_whenMap_thenSummaryMentionsResult() {
        let state = sut.map(input: makeInput(.sumByDifference, a: 5, b: 3), result: IdentityResult(terms: [Monomial(coefficient: 16)]))
        #expect(state.summary.contains("16"))
        #expect(state.summary.isEmpty == false)
    }

    @Test
    func test_givenPolynomialTerms_whenMap_thenDevelopmentJoinsWithSignedTerms() {
        let input = makeInput(.squareDifference, a: 1, b: 3)
        let terms = [
            Monomial(coefficient: 1, variables: ["x": 2]),
            Monomial(coefficient: -6, variables: ["x": 1]),
            Monomial(coefficient: 9)
        ]
        let state = sut.map(input: input, result: IdentityResult(terms: terms))
        #expect(state.developmentLatex.hasSuffix("x^2 - 6x + 9"))
    }
}
