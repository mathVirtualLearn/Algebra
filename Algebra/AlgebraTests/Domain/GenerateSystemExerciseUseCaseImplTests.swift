import Testing
@testable import Algebra

struct GenerateSystemExerciseUseCaseImplTests {
    private let solver = SolveSystemUseCaseImpl()

    @Test(arguments: [SystemSize.two, SystemSize.three])
    func test_givenEachSystemSize_whenGeneratedAcrossManySeeds_thenSolverFindsUniqueMatchingSolution(size: SystemSize) {
        for seed in UInt64(1)...UInt64(40) {
            let generator = GenerateSystemExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(size: size)
            let result = solver.execute(exercise.input)

            guard case .unique(let solution) = result.outcome else {
                Issue.record("size \(size) seed \(seed) outcome \(result.outcome) is not unique")
                continue
            }

            #expect(solution.count == size.equationCount, "size \(size) seed \(seed)")
            #expect(
                solution.count == exercise.solution.count,
                "size \(size) seed \(seed) solver \(solution) expected \(exercise.solution)")

            for (actual, expected) in zip(solution, exercise.solution) {
                #expect(
                    abs(actual - expected.doubleValue) < 1e-6,
                    "size \(size) seed \(seed) solver \(solution) expected \(exercise.solution)")
            }
        }
    }

    @Test(arguments: [SystemSize.two, SystemSize.three])
    func test_givenEachSystemSize_whenGeneratedAcrossManySeeds_thenFractionalSolutionAppears(size: SystemSize) {
        var fractionalFound = false
        for seed in UInt64(1)...UInt64(60) {
            let generator = GenerateSystemExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(size: size)
            if exercise.solution.contains(where: { $0.denominator != 1 }) {
                fractionalFound = true
                break
            }
        }
        #expect(fractionalFound, "size \(size) never produced a fractional solution")
    }

    @Test
    func test_givenSameSeed_whenGeneratedTwice_thenIdenticalSystem() {
        let first = GenerateSystemExerciseUseCaseImpl(random: SeededRandomSource(seed: 11)).execute(size: .three)
        let second = GenerateSystemExerciseUseCaseImpl(random: SeededRandomSource(seed: 11)).execute(size: .three)
        #expect(first == second)
    }
}
