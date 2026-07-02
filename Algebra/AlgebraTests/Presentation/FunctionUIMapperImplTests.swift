import Testing
@testable import Algebra

struct FunctionUIMapperImplTests {
    private let sut = FunctionUIMapperImpl()

    @Test
    func test_whenMap_thenLatexPrefixedWithY() {
        let state = sut.map(expression: .variable, samples: [FunctionSample(x: 0, y: 0)], domain: -1...1)
        #expect(state.functionLatex == "y = x")
    }

    @Test
    func test_whenMap_thenPointsMatchSamplesWithSequentialIds() {
        let samples = [FunctionSample(x: -1, y: -1), FunctionSample(x: 0, y: 0), FunctionSample(x: 1, y: 1)]
        let state = sut.map(expression: .variable, samples: samples, domain: -1...1)

        #expect(state.points.count == 3)
        #expect(state.points.map(\.id) == [0, 1, 2])
        #expect(state.points.map(\.x) == [-1, 0, 1])
        #expect(state.points.map(\.y) == [-1, 0, 1])
    }

    @Test
    func test_whenMap_thenXBoundsComeFromDomain() {
        let state = sut.map(expression: .variable, samples: [FunctionSample(x: 0, y: 0)], domain: -10...10)
        #expect(state.xMin == -10)
        #expect(state.xMax == 10)
    }

    @Test
    func test_givenSpreadSamples_whenMap_thenYWindowHasMargin() {
        let samples = [FunctionSample(x: -1, y: -1), FunctionSample(x: 1, y: 1)]
        let state = sut.map(expression: .variable, samples: samples, domain: -1...1)
        #expect(state.yMin == -1.2)
        #expect(state.yMax == 1.2)
    }

    @Test
    func test_givenLargeValues_whenMap_thenYWindowClampedToLimit() {
        let samples = [FunctionSample(x: 0, y: 0), FunctionSample(x: 1, y: 100)]
        let state = sut.map(expression: .variable, samples: samples, domain: 0...1)
        #expect(state.yMax == 55)
        #expect(state.yMin == -5)
    }
}
