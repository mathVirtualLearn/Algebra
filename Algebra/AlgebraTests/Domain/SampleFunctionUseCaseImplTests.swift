import Testing
@testable import Algebra

struct SampleFunctionUseCaseImplTests {
    private let sut = SampleFunctionUseCaseImpl()

    @Test
    func test_givenCount_whenSample_thenReturnsThatManyPoints() {
        let samples = sut.execute(expression: .variable, domain: 0...10, count: 5)
        #expect(samples.count == 5)
    }

    @Test
    func test_givenSample_whenEvaluated_thenRespectsDomainBounds() {
        let samples = sut.execute(expression: .variable, domain: 0...10, count: 5)
        #expect(samples.first?.x == 0)
        #expect(samples.last?.x == 10)
    }

    @Test
    func test_givenLinearExpression_whenSample_thenYMatchesX() {
        let samples = sut.execute(expression: .variable, domain: 0...10, count: 5)
        #expect(samples.map(\.y) == samples.map(\.x))
    }

    @Test
    func test_givenCountBelowTwo_whenSample_thenClampsToTwoPoints() {
        let samples = sut.execute(expression: .variable, domain: 0...10, count: 1)
        #expect(samples.count == 2)
    }

    @Test
    func test_givenNonFinitePoints_whenSample_thenDropsThem() {
        let samples = sut.execute(expression: .call(.sqrt, .variable), domain: -1...1, count: 3)
        #expect(samples.count == 2)
        #expect(samples.allSatisfy { $0.y.isFinite })
    }
}
