import Foundation
import Observation

@MainActor
@Observable
final class SystemsViewModel {

    var sizeIndex: Int = 0 {
        didSet {
            guard sizeIndex != oldValue else { return }

            methodIndex = 0

            coefficients = Array(repeating: Array(repeating: "", count: 3), count: 3)
            constants = ["", "", ""]
            result = nil
            inputError = nil
        }
    }
    var methodIndex: Int = 0
    var coefficients: [[String]]
    var constants: [String]

    let sizeTitles: [String] = [
        String(localized: "2 ecuaciones"),
        String(localized: "3 ecuaciones")
    ]

    var methodTitles: [String] {
        sizeIndex == 1
            ? [String(localized: "Cramer"), String(localized: "Gauss")]
            : [String(localized: "Sustitución"),
               String(localized: "Igualación"),
               String(localized: "Reducción")]
    }

    private(set) var result: SystemResultState?
    private(set) var inputError: String?

    var variableNames: [String] {
        sizeIndex == 1 ? ["x", "y", "z"] : ["x", "y"]
    }

    let variableSymbols = ["x", "y", "z"]

    var equationCount: Int { sizeIndex == 1 ? 3 : 2 }

    private let solve: SolveSystemUseCase
    private let mapper: SystemUIMapper

    init(solve: SolveSystemUseCase, mapper: SystemUIMapper) {
        self.solve = solve
        self.mapper = mapper
        self.coefficients = Array(repeating: Array(repeating: "", count: 3), count: 3)
        self.constants = ["", "", ""]
    }

    func solveTapped() {
        inputError = nil
        let n = sizeIndex == 1 ? 3 : 2

        var parsedCoefficients: [[Double]] = []
        for row in 0..<n {
            var parsedRow: [Double] = []
            for column in 0..<n {
                guard let value = parse(coefficientAt(row: row, column: column)) else {
                    return failInput()
                }
                parsedRow.append(value)
            }
            parsedCoefficients.append(parsedRow)
        }

        var parsedConstants: [Double] = []
        for row in 0..<n {
            let raw = row < constants.count ? constants[row] : ""
            guard let value = parse(raw) else {
                return failInput()
            }
            parsedConstants.append(value)
        }

        let size: SystemSize = n == 3 ? .three : .two
        let input = SystemInput(size: size, coefficients: parsedCoefficients, constants: parsedConstants)
        let method = systemMethod(for: methodIndex)
        result = mapper.map(input: input, result: solve.execute(input), method: method)
    }

    private func systemMethod(for index: Int) -> SystemMethod {
        if sizeIndex == 1 {
            switch index {
            case 1: return .gauss
            default: return .cramer
            }
        }
        switch index {
        case 1: return .equalization
        case 2: return .reduction
        default: return .substitution
        }
    }

    private func coefficientAt(row: Int, column: Int) -> String {
        guard row < coefficients.count, column < coefficients[row].count else { return "" }
        return coefficients[row][column]
    }

    private func failInput() {
        inputError = String(localized: "Introduce coeficientes numéricos válidos.")
        result = nil
    }

    private func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return 0 }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
