import Foundation

protocol EquationUIMapper: Sendable {
    func map(input: EquationInput, result: EquationResult) -> EquationResultState
}

struct EquationUIMapperImpl: EquationUIMapper {
    private let epsilon = 1e-9

    func map(input: EquationInput, result: EquationResult) -> EquationResultState {
        EquationResultState(
            equationLatex: equationLatex(for: input),
            steps: steps(for: input, result: result),
            solutionLatex: solutionLatex(for: result),
            summary: summary(for: result),
            ruffiniTableau: ruffiniTableau(input: input, result: result)
        )
    }

    private func equationLatex(for input: EquationInput) -> String {
        let c = input.coefficients
        let terms: [(Double, String)]
        switch input.type {
        case .linear:
            terms = [(coeff(c, 0), "x"), (coeff(c, 1), "")]
        case .quadratic:
            terms = [(coeff(c, 0), "x^2"), (coeff(c, 1), "x"), (coeff(c, 2), "")]
        case .cubic:
            terms = [(coeff(c, 0), "x^3"), (coeff(c, 1), "x^2"), (coeff(c, 2), "x"), (coeff(c, 3), "")]
        case .quartic:
            terms = [(coeff(c, 0), "x^4"), (coeff(c, 1), "x^3"), (coeff(c, 2), "x^2"),
                     (coeff(c, 3), "x"), (coeff(c, 4), "")]
        case .biquadratic:
            terms = [(coeff(c, 0), "x^4"), (coeff(c, 1), "x^2"), (coeff(c, 2), "")]
        }
        return "\(polynomial(terms)) = 0"
    }

    private func steps(for input: EquationInput, result: EquationResult) -> [ExplanationStep] {
        switch result.method {
        case .linearFormula:
            return linearSteps(result)
        case .quadraticFormula:
            return quadraticSteps(result)
        case .ruffini:
            return ruffiniSteps(result)
        case .biquadratic:
            return biquadraticSteps(result)
        }
    }

    private func linearSteps(_ result: EquationResult) -> [ExplanationStep] {
        switch result.outcome {
        case .infiniteSolutions:
            return [ExplanationStep(
                text: "Al simplificar desaparece la incógnita y queda una identidad (0 = 0): la ecuación se cumple siempre, así que tiene infinitas soluciones.",
                latex: nil)]
        case .noSolution:
            return [ExplanationStep(
                text: "Al simplificar desaparece la incógnita y queda una igualdad imposible, por lo que la ecuación no tiene solución.",
                latex: nil)]
        default:
            let value = result.roots.first.map(number) ?? ""
            return [ExplanationStep(
                text: "Despejamos la incógnita pasando el término independiente al otro lado y dividiendo por el coeficiente.",
                latex: "x = -\\displaystyle\\frac{b}{a} = \(value)")]
        }
    }

    private func quadraticSteps(_ result: EquationResult) -> [ExplanationStep] {
        guard let discriminant = result.discriminant else { return [] }
        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Calculamos el discriminante Δ = b² − 4ac, que nos dirá cuántas soluciones reales hay.",
                latex: "\\Delta = b^2 - 4ac = \(number(discriminant))")
        ]
        if discriminant > epsilon {
            steps.append(ExplanationStep(
                text: "Como Δ > 0, hay dos soluciones reales. Aplicamos la fórmula general: la raíz del discriminante nos da las dos soluciones.",
                latex: "x = \\displaystyle\\frac{-b \\pm \\sqrt{\\Delta}}{2a} \\Rightarrow \(rootsLatex(result.roots))"))
        } else if abs(discriminant) <= epsilon {
            let value = result.roots.first.map(number) ?? ""
            steps.append(ExplanationStep(
                text: "Como Δ = 0, la fórmula da una única solución real (raíz doble).",
                latex: "x = \\displaystyle\\frac{-b}{2a} = \(value)"))
        } else {
            steps.append(ExplanationStep(
                text: "Como Δ < 0, la raíz cuadrada no es real: la ecuación no tiene soluciones reales.",
                latex: nil))
        }
        return steps
    }

    private func ruffiniSteps(_ result: EquationResult) -> [ExplanationStep] {
        let foundRoots = result.ruffiniSteps.map { number($0.root) }
        let intro: String
        if foundRoots.isEmpty {
            intro = "Aplicamos Ruffini: probamos divisores del término independiente buscando raíces racionales."
        } else {
            let list = foundRoots.joined(separator: ", ")
            intro = "Aplicamos Ruffini: probamos divisores del término independiente y, por cada raíz hallada (x = \(list)), dividimos para bajar el grado (ver la caja de la división)."
        }
        var steps: [ExplanationStep] = [
            ExplanationStep(text: intro, latex: nil)
        ]
        if let quadratic = result.finalQuadratic {
            steps.append(ExplanationStep(
                text: "Nos queda una cuadrática; la resolvemos con su discriminante.",
                latex: "\\Delta = b^2 - 4ac = \(number(quadratic.discriminant))"))
            if quadratic.roots.count == 2 {
                steps.append(ExplanationStep(
                    text: "Aplicamos la fórmula general a la cuadrática; la raíz del discriminante da sus dos soluciones.",
                    latex: "x = \\displaystyle\\frac{-b \\pm \\sqrt{\\Delta}}{2a} \\Rightarrow \(rootsLatex(quadratic.roots))"))
            } else if quadratic.roots.count == 1 {
                steps.append(ExplanationStep(
                    text: "La cuadrática tiene una raíz doble.",
                    latex: "x = \(number(quadratic.roots[0]))"))
            }
        }
        if result.outcome == .partial {
            steps.append(ExplanationStep(
                text: "No encontramos más raíces racionales por Ruffini, así que el procedimiento se detiene aquí.",
                latex: nil))
        }
        return steps
    }

    private func biquadraticSteps(_ result: EquationResult) -> [ExplanationStep] {
        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Como solo aparecen x⁴ y x², hacemos el cambio de variable t = x² para obtener una cuadrática.",
                latex: "t = x^2")
        ]
        if let quadratic = result.finalQuadratic {
            let inT = polynomial([(quadratic.a, "t^2"), (quadratic.b, "t"), (quadratic.c, "")])
            steps.append(ExplanationStep(
                text: "Resolvemos la cuadrática en t calculando su discriminante.",
                latex: "\(inT) = 0 \\quad \\Delta = \(number(quadratic.discriminant))"))
            if quadratic.roots.isEmpty {
                steps.append(ExplanationStep(
                    text: "La cuadrática en t no tiene soluciones reales, por lo que la ecuación tampoco.",
                    latex: nil))
            } else {
                steps.append(ExplanationStep(
                    text: "Obtenemos los valores de t.",
                    latex: tRootsLatex(quadratic.roots)))
            }
        }
        steps.append(ExplanationStep(
            text: "Deshacemos el cambio: por cada valor de t ≥ 0 obtenemos dos soluciones, x = +√t y x = −√t (para t = 0, una sola: x = 0).",
            latex: nil))
        return steps
    }

    // Construye la caja de Ruffini calculando la división sintética para cada raíz hallada.
    private func ruffiniTableau(input: EquationInput, result: EquationResult) -> RuffiniTableauState? {
        guard result.method == .ruffini, !result.ruffiniSteps.isEmpty else { return nil }

        let header = input.coefficients.map(number)
        var divisions: [RuffiniTableauState.Division] = []
        var dividend = input.coefficients

        for step in result.ruffiniSteps {
            let r = step.root

            var b = [Double](repeating: 0, count: dividend.count)
            if !dividend.isEmpty { b[0] = dividend[0] }
            for k in 1..<dividend.count {
                b[k] = dividend[k] + r * b[k - 1]
            }

            var products: [String] = [""]
            for k in 1..<dividend.count {
                products.append(number(r * b[k - 1]))
            }
            divisions.append(RuffiniTableauState.Division(
                root: number(r),
                products: products,
                results: b.map(number)))

            dividend = Array(b.dropLast())
        }

        return RuffiniTableauState(header: header, divisions: divisions)
    }

    private func solutionLatex(for result: EquationResult) -> String {
        switch result.outcome {
        case .noRealSolutions:
            return "\\text{Sin soluciones reales}"
        case .noSolution:
            return "\\text{Sin solución}"
        case .infiniteSolutions:
            return "\\text{Infinitas soluciones}"
        case .solved:
            return rootsLatex(result.roots)
        case .partial:
            guard !result.roots.isEmpty else {
                return "\\text{No se hallaron raíces racionales}"
            }
            return "\(rootsLatex(result.roots)) \\quad \\text{(no se hallaron más raíces racionales)}"
        }
    }

    private func rootsLatex(_ roots: [Double]) -> String {
        if roots.isEmpty { return "\\text{Sin soluciones reales}" }
        if roots.count == 1 { return "x = \(number(roots[0]))" }
        return roots.enumerated()
            .map { "x_\($0.offset + 1) = \(number($0.element))" }
            .joined(separator: " \\quad ")
    }

    private func tRootsLatex(_ roots: [Double]) -> String {
        if roots.count == 1 { return "t = \(number(roots[0]))" }
        return roots.enumerated()
            .map { "t_\($0.offset + 1) = \(number($0.element))" }
            .joined(separator: " \\quad ")
    }

    private func summary(for result: EquationResult) -> String {
        switch result.outcome {
        case .noRealSolutions:
            return "Sin soluciones reales"
        case .noSolution:
            return "Sin solución"
        case .infiniteSolutions:
            return "Infinitas soluciones"
        case .solved:
            return solvedSummary(result.roots)
        case .partial:
            guard !result.roots.isEmpty else {
                return "No se hallaron raíces racionales"
            }
            return "\(solvedSummary(result.roots)). No se hallaron más raíces racionales"
        }
    }

    private func solvedSummary(_ roots: [Double]) -> String {
        switch roots.count {
        case 0:
            return "Sin soluciones reales"
        case 1:
            return "Una solución: x = \(number(roots[0]))"
        default:
            let list = roots.enumerated()
                .map { "x\(subscriptDigits($0.offset + 1)) = \(number($0.element))" }
                .joined(separator: ", ")
            return "\(roots.count) soluciones: \(list)"
        }
    }

    private func polynomial(fromCoefficients coefficients: [Double]) -> String {
        let degree = coefficients.count - 1
        let terms = coefficients.enumerated().map { index, coefficient in
            (coefficient, symbol(forExponent: degree - index))
        }
        return polynomial(terms)
    }

    private func symbol(forExponent exponent: Int) -> String {
        switch exponent {
        case 0: return ""
        case 1: return "x"
        default: return "x^\(exponent)"
        }
    }

    private func polynomial(_ terms: [(Double, String)]) -> String {
        var parts: [String] = []
        for (coefficient, symbol) in terms where coefficient != 0 {
            let magnitude = abs(coefficient)
            let factor = symbol.isEmpty ? number(magnitude) : (magnitude == 1 ? "" : number(magnitude))
            let term = "\(factor)\(symbol)"
            if parts.isEmpty {
                parts.append(coefficient < 0 ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient < 0 ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func factor(root: Double) -> String {
        if root == 0 { return "x" }
        return root > 0 ? "(x - \(number(root)))" : "(x + \(number(-root)))"
    }

    private func coeff(_ values: [Double], _ index: Int) -> Double {
        index < values.count ? values[index] : 0
    }

    private func number(_ value: Double) -> String {
        if value == value.rounded(), abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(format: "%g", value)
    }

    private func subscriptDigits(_ n: Int) -> String {
        let digits: [Character: Character] = [
            "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
            "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉"
        ]
        return String(String(n).map { digits[$0] ?? $0 })
    }
}
