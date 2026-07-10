import Foundation
import Observation

@MainActor
@Observable
final class EquationsViewModel {

    var typeIndex: Int = 1
    var coefficients: [String] = Array(repeating: "", count: 5)

    let typeTitles: [String] = [
        String(localized: "Grado 1"),
        String(localized: "Grado 2"),
        String(localized: "Grado 3"),
        String(localized: "Grado 4"),
        String(localized: "Bicuadrada")
    ]

    private(set) var result: EquationResultState?
    private(set) var inputError: String?

    var coefficientLabels: [String] {
        switch selectedType {
        case .linear:
            return ["a", "b"]
        case .quadratic:
            return ["a", "b", "c"]
        case .cubic:
            return ["a", "b", "c", "d"]
        case .quartic:
            return ["a", "b", "c", "d", "e"]
        case .biquadratic:
            return [
                String(localized: "a (x⁴)"),
                String(localized: "b (x²)"),
                "c"
            ]
        }
    }

    private let solve: SolveEquationUseCase
    private let mapper: EquationUIMapper

    init(solve: SolveEquationUseCase, mapper: EquationUIMapper) {
        self.solve = solve
        self.mapper = mapper
    }

    func solveTapped() {
        inputError = nil
        let count = coefficientLabels.count
        var parsed: [Double] = []
        for index in 0..<count {
            let raw = index < coefficients.count ? coefficients[index] : ""
            guard let value = parse(raw) else {
                inputError = String(localized: "Introduce coeficientes numéricos válidos.")
                result = nil
                return
            }
            parsed.append(value)
        }
        let input = EquationInput(type: selectedType, coefficients: parsed)
        result = mapper.map(input: input, result: solve.execute(input))
    }

    private var selectedType: EquationType {
        switch typeIndex {
        case 0: return .linear
        case 2: return .cubic
        case 3: return .quartic
        case 4: return .biquadratic
        default: return .quadratic
        }
    }

    private func parse(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return 0 }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }
}
