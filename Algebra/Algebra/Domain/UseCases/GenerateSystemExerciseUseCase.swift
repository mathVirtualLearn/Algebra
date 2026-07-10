protocol GenerateSystemExerciseUseCase {
    func execute(size: SystemSize) -> SystemExercise
}

struct GenerateSystemExerciseUseCaseImpl: GenerateSystemExerciseUseCase {
    private let random: RandomSource

    init(random: RandomSource) {
        self.random = random
    }

    // Elige A con det≠0 y ~30% de las veces b entera libre (solución fraccionaria por Cramer); el resto, b = A·solución entera.
    func execute(size: SystemSize) -> SystemExercise {
        let n = size.equationCount
        let coefficientRange: ClosedRange<Int> = n == 2 ? -4...4 : -3...3

        var matrix = identity(n)
        for _ in 0..<50 {
            let candidate = (0..<n).map { _ in (0..<n).map { _ in random.int(in: coefficientRange) } }
            if determinant(candidate) != 0 {
                matrix = candidate
                break
            }
        }

        let constants: [Int]
        let solution: [Fraction]
        if random.int(in: 0...9) < 3 {
            let constantRange: ClosedRange<Int> = n == 2 ? -8...8 : -6...6
            constants = (0..<n).map { _ in random.int(in: constantRange) }
            solution = cramerSolution(matrix: matrix, constants: constants)
        } else {
            let solutionRange: ClosedRange<Int> = n == 2 ? -5...5 : -4...4
            let integerSolution = (0..<n).map { _ in random.int(in: solutionRange) }
            constants = (0..<n).map { row in
                (0..<n).reduce(0) { $0 + matrix[row][$1] * integerSolution[$1] }
            }
            solution = integerSolution.map { Fraction($0) }
        }

        let input = SystemInput(
            size: size,
            coefficients: matrix.map { $0.map(Double.init) },
            constants: constants.map(Double.init))
        return SystemExercise(input: input, solution: solution)
    }

    // Resuelve el sistema en fracciones exactas por Cramer (det≠0 garantizado por la selección de A).
    private func cramerSolution(matrix: [[Int]], constants: [Int]) -> [Fraction] {
        let n = matrix.count
        let delta = determinant(matrix)
        var solution: [Fraction] = []
        for column in 0..<n {
            var replaced = matrix
            for row in 0..<n { replaced[row][column] = constants[row] }
            solution.append(Fraction(determinant(replaced), delta))
        }
        return solution
    }

    private func identity(_ n: Int) -> [[Int]] {
        (0..<n).map { i in (0..<n).map { j in i == j ? 1 : 0 } }
    }

    private func determinant(_ m: [[Int]]) -> Int {
        if m.count == 2 {
            return m[0][0] * m[1][1] - m[0][1] * m[1][0]
        }
        return m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
            - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
            + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
    }
}
