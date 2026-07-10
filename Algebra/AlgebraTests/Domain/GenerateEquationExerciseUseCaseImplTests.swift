import Testing
@testable import Algebra

struct GenerateEquationExerciseUseCaseImplTests {
    private let solver = SolveEquationUseCaseImpl()

    private func distinctValues(_ values: [Double], tolerance: Double = 1e-6) -> [Double] {
        var result: [Double] = []
        for value in values where !result.contains(where: { abs($0 - value) < tolerance }) {
            result.append(value)
        }
        return result.sorted()
    }

    private func degree(of type: EquationType) -> Int {
        switch type {
        case .linear: return 1
        case .quadratic: return 2
        case .cubic: return 3
        case .quartic, .biquadratic: return 4
        }
    }

    @Test(arguments: EquationType.allCases)
    func test_givenEachEquationType_whenGeneratedAcrossManySeeds_thenSolverMatchesDistinctFractionRoots(type: EquationType) {
        for seed in UInt64(1)...UInt64(40) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: type)
            let result = solver.execute(exercise.input)

            #expect(result.outcome == .solved, "type \(type) seed \(seed) outcome \(result.outcome)")

            let expected = distinctValues(exercise.roots.map(\.doubleValue))
            let solverDistinct = distinctValues(result.roots)

            #expect(
                expected.count == solverDistinct.count,
                "type \(type) seed \(seed) solver \(result.roots) expected \(exercise.roots)")

            for expectedRoot in expected {
                #expect(
                    solverDistinct.contains { abs($0 - expectedRoot) < 1e-6 },
                    "type \(type) seed \(seed) solver \(result.roots) expected \(exercise.roots)")
            }

            for solverRoot in solverDistinct {
                #expect(
                    expected.contains { abs($0 - solverRoot) < 1e-6 },
                    "type \(type) seed \(seed) solver \(result.roots) expected \(exercise.roots)")
            }
        }
    }

    @Test(arguments: EquationType.allCases)
    func test_givenEachEquationType_whenGenerated_thenRootsAreDistinctAndAscending(type: EquationType) {
        for seed in UInt64(1)...UInt64(40) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: type)

            #expect(!exercise.roots.isEmpty, "type \(type) seed \(seed)")
            let doubles = exercise.roots.map(\.doubleValue)
            #expect(doubles == doubles.sorted(), "type \(type) seed \(seed) not ascending")
            #expect(Set(exercise.roots).count == exercise.roots.count, "type \(type) seed \(seed) has duplicates")
        }
    }

    @Test(arguments: EquationType.allCases)
    func test_givenEachEquationType_whenGeneratedAcrossManySeeds_thenLeadingCoefficientVaries(type: EquationType) {
        var leadingValues: Set<Double> = []
        for seed in UInt64(1)...UInt64(60) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: type)
            if let leading = exercise.input.coefficients.first {
                leadingValues.insert(abs(leading))
            }
        }
        #expect(leadingValues.contains { $0 != 1 }, "type \(type) never produced a leading coefficient other than 1")
    }

    @Test(arguments: [EquationType.linear, EquationType.quadratic])
    func test_givenLinearOrQuadratic_whenGeneratedAcrossManySeeds_thenFractionalRootsAppear(type: EquationType) {
        var fractionalFound = false
        for seed in UInt64(1)...UInt64(60) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: type)
            if exercise.roots.contains(where: { $0.denominator != 1 }) {
                fractionalFound = true
                break
            }
        }
        #expect(fractionalFound, "type \(type) never produced a fractional root")
    }

    @Test
    func test_givenQuadratic_whenGeneratedAcrossManySeeds_thenDoubleRootAppears() {
        var doubleRootFound = false
        for seed in UInt64(1)...UInt64(100) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: .quadratic)
            let result = solver.execute(exercise.input)
            if exercise.roots.count == 1, result.outcome == .solved,
               let discriminant = result.discriminant, abs(discriminant) < 1e-6 {
                doubleRootFound = true
                break
            }
        }
        #expect(doubleRootFound, "quadratic never produced a double root over 100 seeds")
    }

    @Test(arguments: [EquationType.cubic, EquationType.quartic])
    func test_givenCubicOrQuartic_whenGeneratedAcrossManySeeds_thenRepeatedRootAppears(type: EquationType) {
        var repeatedRootFound = false
        for seed in UInt64(1)...UInt64(100) {
            let generator = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: seed))
            let exercise = generator.execute(type: type)
            if exercise.roots.count < degree(of: type) {
                repeatedRootFound = true
                break
            }
        }
        #expect(repeatedRootFound, "type \(type) never produced a repeated root over 100 seeds")
    }

    @Test
    func test_givenLinearAndDeterministicSeed_whenGeneratedTwice_thenIdenticalExercise() {
        let first = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: 7)).execute(type: .linear)
        let second = GenerateEquationExerciseUseCaseImpl(random: SeededRandomSource(seed: 7)).execute(type: .linear)
        #expect(first == second)
    }
}
