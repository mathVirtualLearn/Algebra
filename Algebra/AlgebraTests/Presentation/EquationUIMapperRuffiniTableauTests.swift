import Testing
@testable import Algebra

struct EquationUIMapperRuffiniTableauTests {
    private let sut = EquationUIMapperImpl()
    private let solver = SolveEquationUseCaseImpl()

    private func map(_ input: EquationInput) -> EquationResultState {
        sut.map(input: input, result: solver.execute(input))
    }

    @Test
    func test_givenCubic_whenMap_thenBuildRuffiniTableauWithFirstDivision() throws {

        let input = EquationInputBuilder().with(type: .cubic).with(coefficients: [1, -6, 11, -6]).build()

        let state = map(input)

        let tableau = try #require(state.ruffiniTableau)
        #expect(tableau.header == ["1", "-6", "11", "-6"])
        let division = try #require(tableau.divisions.first)
        #expect(division.root == "1")
        #expect(division.products == ["", "1", "-5", "6"])
        #expect(division.results == ["1", "-5", "6", "0"])
    }

    @Test
    func test_givenQuadratic_whenMap_thenRuffiniTableauIsNil() {
        let input = EquationInputBuilder().with(type: .quadratic).with(coefficients: [1, -3, 2]).build()
        let state = map(input)
        #expect(state.ruffiniTableau == nil)
    }

    @Test
    func test_givenLinear_whenMap_thenRuffiniTableauIsNil() {
        let input = EquationInputBuilder().with(type: .linear).with(coefficients: [2, -4]).build()
        let state = map(input)
        #expect(state.ruffiniTableau == nil)
    }

    @Test
    func test_givenQuartic_whenMap_thenTableauRootsAreAmongSolutions() throws {
        let input = EquationInputBuilder().with(type: .quartic).with(coefficients: [1, -10, 35, -50, 24]).build()
        let state = map(input)
        let tableau = try #require(state.ruffiniTableau)
        #expect(tableau.header == ["1", "-10", "35", "-50", "24"])
        #expect(tableau.divisions.count >= 1)
        for division in tableau.divisions {
            #expect(state.solutionLatex.contains("= \(division.root)"))
        }
    }
}
