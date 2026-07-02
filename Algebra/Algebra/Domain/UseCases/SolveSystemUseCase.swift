protocol SolveSystemUseCase: Sendable {
    func execute(_ input: SystemInput) -> SystemResult
}

struct SolveSystemUseCaseImpl: SolveSystemUseCase {
    private let epsilon = 1e-9

    // Resuelve el sistema por Cramer: calcula Δ y cada Δᵢ y divide para obtener las incógnitas.
    func execute(_ input: SystemInput) -> SystemResult {
        let n = input.size.equationCount
        let matrix = input.coefficients
        let constants = input.constants

        let delta = determinant(matrix)

        var variableDeterminants: [Double] = []
        for column in 0..<n {
            variableDeterminants.append(determinant(replacingColumn: column, in: matrix, with: constants))
        }

        guard abs(delta) >= epsilon else {

            let allZero = variableDeterminants.allSatisfy { abs($0) < epsilon }
            let outcome: SystemOutcome = allZero ? .infiniteSolutions : .noSolution
            return SystemResult(outcome: outcome, determinant: normalize(delta),
                                variableDeterminants: normalize(variableDeterminants), solution: [])
        }

        let solution = normalize(variableDeterminants.map { $0 / delta })
        return SystemResult(outcome: .unique(solution), determinant: normalize(delta),
                            variableDeterminants: normalize(variableDeterminants), solution: solution)
    }

    private func determinant(_ m: [[Double]]) -> Double {
        if m.count >= 3 {
            return determinant3x3(m)
        }
        return determinant2x2(m)
    }

    private func determinant(replacingColumn column: Int, in m: [[Double]], with values: [Double]) -> Double {
        var copy = m
        for row in copy.indices where column < copy[row].count && row < values.count {
            copy[row][column] = values[row]
        }
        return determinant(copy)
    }

    private func determinant2x2(_ m: [[Double]]) -> Double {
        m[0][0] * m[1][1] - m[0][1] * m[1][0]
    }

    // Calcula el determinante 3×3 por la regla de Sarrus.
    private func determinant3x3(_ m: [[Double]]) -> Double {
        m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
        - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
        + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
    }

    private func normalize(_ value: Double) -> Double {
        abs(value) < epsilon ? 0 : value
    }

    private func normalize(_ values: [Double]) -> [Double] {
        values.map(normalize)
    }
}
