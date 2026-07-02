import Foundation

protocol SystemUIMapper: Sendable {
    func map(input: SystemInput, result: SystemResult, method: SystemMethod) -> SystemResultState
}

struct SystemUIMapperImpl: SystemUIMapper {

    func map(input: SystemInput, result: SystemResult, method: SystemMethod) -> SystemResultState {
        let variables = variableNames(for: input.size)
        return SystemResultState(
            equationsLatex: equationsLatex(for: input, variables: variables),
            steps: steps(for: input, result: result, method: method, variables: variables),
            solutionLatex: solutionLatex(for: input, result: result, variables: variables),
            summary: summary(for: input, result: result, variables: variables)
        )
    }

    private func variableNames(for size: SystemSize) -> [String] {
        size == .two ? ["x", "y"] : ["x", "y", "z"]
    }

    private func equationsLatex(for input: SystemInput, variables: [String]) -> [String] {
        let n = input.size.equationCount
        var lines: [String] = []
        for row in 0..<n {
            let coefficients = row < input.coefficients.count ? input.coefficients[row] : []
            let terms = variables.enumerated().map { index, name in
                (coeff(coefficients, index), name)
            }
            let constant = row < input.constants.count ? input.constants[row] : 0
            lines.append("\(linearExpression(terms)) = \(number(constant))")
        }
        return lines
    }

    private func linearExpression(_ terms: [(Double, String)]) -> String {
        var parts: [String] = []
        for (coefficient, symbol) in terms where coefficient != 0 {
            let magnitude = abs(coefficient)
            let factor = magnitude == 1 ? "" : number(magnitude)
            let term = "\(factor)\(symbol)"
            if parts.isEmpty {
                parts.append(coefficient < 0 ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient < 0 ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func steps(for input: SystemInput, result: SystemResult,
                       method: SystemMethod, variables: [String]) -> [ExplanationStep] {
        switch result.outcome {
        case .unique:
            let rows = augmented(input)
            let solution = solutionFractions(rows: rows, result: result)
            return uniqueSteps(rows: rows, solution: solution, method: method, variables: variables)
        case .noSolution, .infiniteSolutions:
            return degenerateSteps(for: input, result: result, method: method, variables: variables)
        }
    }

    private func degenerateSteps(for input: SystemInput, result: SystemResult,
                                 method: SystemMethod, variables: [String]) -> [ExplanationStep] {
        if variables.count == 2 {
            return twoDegenerate(rows: augmented(input), result: result, method: method)
        }
        let rows = augmented(input)
        switch method {
        case .gauss: return threeDegenerateGauss(rows: rows, result: result, variables: variables)
        default:     return threeDegenerateCramer(rows: rows, result: result, variables: variables)
        }
    }

    private func twoDegenerate(rows: [[Fraction]], result: SystemResult,
                               method: SystemMethod) -> [ExplanationStep] {
        let n = 2
        let a1 = rows[0][0], b1 = rows[0][1], c1 = rows[0][n]
        let a2 = rows[1][0], b2 = rows[1][1], c2 = rows[1][n]

        let rhs = a2 * c1 - a1 * c2

        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Aplicamos \(methodName(method)) para eliminar una incógnita; como los coeficientes son proporcionales, también desaparece la otra y queda:",
                latex: "0 = \(numberF(rhs))")
        ]

        var ratios: [String] = []
        if !a2.isZero { ratios.append("\\displaystyle\\frac{a_1}{a_2} = \((a1 / a2).latex())") }
        if !b2.isZero { ratios.append("\\displaystyle\\frac{b_1}{b_2} = \((b1 / b2).latex())") }
        if !c2.isZero { ratios.append("\\displaystyle\\frac{c_1}{c_2} = \((c1 / c2).latex())") }
        steps.append(ExplanationStep(
            text: "Comparamos los coeficientes de cada término:",
            latex: ratios.joined(separator: " \\quad ")))

        switch result.outcome {
        case .infiniteSolutions:
            var latex: String? = nil
            if let parametric = parametric2x2(rows: rows) {
                let expr = affineExpression(constant: parametric.constant, terms: [(parametric.tCoeff, "t")])
                latex = "x = \(expr) \\quad y = t"
            }
            steps.append(ExplanationStep(
                text: "Las tres razones son iguales (a/a' = b/b' = c/c'): las dos ecuaciones son equivalentes, así que hay infinitas soluciones. Tomamos una incógnita como parámetro t y despejamos la otra.",
                latex: latex))
        case .noSolution:
            steps.append(ExplanationStep(
                text: "Los coeficientes son proporcionales pero los términos independientes no (a/a' = b/b' ≠ c/c'): son rectas paralelas, el sistema no tiene solución.",
                latex: nil))
        case .unique:
            break
        }
        return steps
    }

    private func threeDegenerateCramer(rows: [[Fraction]], result: SystemResult,
                                       variables: [String]) -> [ExplanationStep] {
        let matrix = rows.map { Array($0.prefix(3)) }
        let constants = rows.map { $0[3] }
        let delta = determinant3x3(matrix)

        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Calculamos el determinante del sistema Δ por la regla de Sarrus.",
                latex: "\\Delta = \(sarrusLatex(matrix)) = \(delta.latex())")
        ]

        for column in 0..<3 {
            var replaced = matrix
            for row in 0..<3 { replaced[row][column] = constants[row] }
            let detVar = determinant3x3(replaced)
            steps.append(ExplanationStep(
                text: "Sustituimos la columna de \(variables[column]) por los términos independientes y calculamos Δ de \(variables[column]).",
                latex: "\\Delta_\(variables[column]) = \(sarrusLatex(replaced)) = \(detVar.latex())"))
        }

        switch result.outcome {
        case .infiniteSolutions:
            steps.append(ExplanationStep(
                text: "Como Δ = 0 y Δx = Δy = Δz = 0, el sistema es compatible indeterminado: infinitas soluciones.",
                latex: nil))
            steps.append(ExplanationStep(
                text: "Cramer no da la solución cuando Δ = 0, así que escalonamos el sistema y tomamos la(s) variable(s) libre(s) como parámetro(s).",
                latex: parametricLatex(rows: rows, variables: variables)))
        case .noSolution:
            steps.append(ExplanationStep(
                text: "Como Δ = 0 pero algún Δᵢ ≠ 0, el sistema es incompatible: no tiene solución.",
                latex: nil))
        case .unique:
            break
        }
        return steps
    }

    private func threeDegenerateGauss(rows: [[Fraction]], result: SystemResult,
                                      variables: [String]) -> [ExplanationStep] {
        let echelon = rowEchelon(rows)
        let n = variables.count

        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Escribimos la matriz ampliada y hacemos ceros bajo los pivotes.",
                latex: matrixLatex(echelon))
        ]

        let zeroRow = echelon.first { row in row.prefix(n).allSatisfy { $0.isZero } }
        let k = zeroRow.map { $0[n] } ?? Fraction(0)

        switch result.outcome {
        case .noSolution:
            steps.append(ExplanationStep(
                text: "La última fila dice 0 = \(plain(k)): es incompatible, no tiene solución.",
                latex: "0 = \(k.latex())"))
        case .infiniteSolutions:
            steps.append(ExplanationStep(
                text: "La última fila dice 0 = 0: hay incógnita libre, infinitas soluciones.",
                latex: "0 = 0"))
            steps.append(ExplanationStep(
                text: "Tomamos la(s) variable(s) libre(s) como parámetro(s) y despejamos las demás.",
                latex: parametricLatex(rows: rows, variables: variables)))
        case .unique:
            break
        }
        return steps
    }

    private func parametric2x2(rows: [[Fraction]]) -> (constant: Fraction, tCoeff: Fraction)? {
        guard let r = rows.indices.first(where: { !rows[$0][0].isZero }) else { return nil }
        let a = rows[r][0], b = rows[r][1], c = rows[r][2]
        return (c / a, -(b / a))
    }

    private func uniqueSteps(rows: [[Fraction]], solution: [Fraction],
                             method: SystemMethod, variables: [String]) -> [ExplanationStep] {
        if variables.count == 2 {
            switch method {
            case .substitution: return twoSubstitution(rows: rows, variables: variables, solution: solution)
            case .equalization: return twoEqualization(rows: rows, variables: variables, solution: solution)
            default:            return twoReduction(rows: rows, variables: variables, solution: solution)
            }
        } else {
            switch method {
            case .gauss: return threeGauss(rows: rows, variables: variables, solution: solution)
            default:     return threeCramer(rows: rows, variables: variables, solution: solution)
            }
        }
    }

    private func twoSubstitution(rows: [[Fraction]], variables: [String], solution: [Fraction]) -> [ExplanationStep] {
        let n = 2
        let x = variables[0], y = variables[1]
        let fx = value(solution, 0), fy = value(solution, 1)

        let isoEq = preferUnitRow(rows, column: 0) ?? rows.indices.first { !rows[$0][0].isZero } ?? 0
        let otherEq = isoEq == 0 ? 1 : 0

        let a1 = rows[isoEq][0], b1 = rows[isoEq][1], c1 = rows[isoEq][n]
        let a2 = rows[otherEq][0], b2 = rows[otherEq][1], c2 = rows[otherEq][n]

        let isoExpr = isolatedExpr(row: rows[isoEq], isolate: 0, variables: variables)

        var subLeft = ""
        if !a2.isZero { subLeft = crossTerm(a2, isoExpr) }
        if !b2.isZero {
            subLeft += subLeft.isEmpty ? coeffTimes(b2, y) : " \(signedTerm(b2, y))"
        }
        if subLeft.isEmpty { subLeft = "0" }

        let distConst = (a2 * c1) / a1
        let distYCoeff = -(a2 * b1) / a1
        let distributed = affineExpression(constant: distConst, terms: [(distYCoeff, y), (b2, y)])

        let coeffY = distYCoeff + b2
        let grouped = affineExpression(constant: distConst, terms: [(coeffY, y)])

        let rhsY = c2 - distConst
        let rhsMove = numericSum(constant: c2, terms: [-distConst])

        let yQuotient = divisionLatex(rhsY, coeffY)

        let xSubExpr = affineSubstituted(constant: c1, terms: [(-b1, fy)])
        let xBody = fractionBody(numerator: xSubExpr, denominator: a1)
        let xMidNum = numericSum(constant: c1, terms: [(-b1) * fy])
        let xMid = fractionBody(numerator: xMidNum, denominator: a1)

        return [
            ExplanationStep(
                text: "Despejamos \(x) en la \(ordinal(isoEq + 1)) ecuación.",
                latex: "\(x) = \(isoExpr)"),
            ExplanationStep(
                text: "Sustituimos esa \(x) en la \(ordinal(otherEq + 1)) ecuación.",
                latex: "\(subLeft) = \(numberF(c2))"),
            ExplanationStep(
                text: "Quitamos el paréntesis multiplicando.",
                latex: "\(distributed) = \(numberF(c2))"),
            ExplanationStep(
                text: "Agrupamos los términos con \(y).",
                latex: "\(grouped) = \(numberF(c2))"),
            ExplanationStep(
                text: "Pasamos el término independiente al otro lado.",
                latex: "\(coeffTimes(coeffY, y)) = \(rhsMove) = \(numberF(rhsY))"),
            ExplanationStep(
                text: "Despejamos \(y) dividiendo entre su coeficiente.",
                latex: "\(y) = \(yQuotient) = \(fy.latex())"),
            ExplanationStep(
                text: "Sustituimos el valor de \(y) en \(x) = \(isoExpr) y operamos.",
                latex: "\(x) = \(xBody) = \(xMid) = \(fx.latex())")
        ]
    }

    private func twoEqualization(rows: [[Fraction]], variables: [String], solution: [Fraction]) -> [ExplanationStep] {

        guard let isoVar = [0, 1].first(where: { !rows[0][$0].isZero && !rows[1][$0].isZero }) else {
            return twoSubstitution(rows: rows, variables: variables, solution: solution)
        }
        let n = 2
        let otherVar = isoVar == 0 ? 1 : 0
        let vIso = variables[isoVar], vOther = variables[otherVar]
        let fIso = value(solution, isoVar), fOther = value(solution, otherVar)

        let a1 = rows[0][isoVar], b1 = rows[0][otherVar], c1 = rows[0][n]
        let a2 = rows[1][isoVar], b2 = rows[1][otherVar], c2 = rows[1][n]

        let iso0 = isolatedExpr(row: rows[0], isolate: isoVar, variables: variables)
        let iso1 = isolatedExpr(row: rows[1], isolate: isoVar, variables: variables)
        let num0 = isolatedNumerator(row: rows[0], isolate: isoVar, variables: variables)
        let num1 = isolatedNumerator(row: rows[1], isolate: isoVar, variables: variables)

        let crossLeft = crossTerm(a2, num0)
        let crossRight = crossTerm(a1, num1)

        let leftDist = affineExpression(constant: a2 * c1, terms: [(-(a2 * b1), vOther)])
        let rightDist = affineExpression(constant: a1 * c2, terms: [(-(a1 * b2), vOther)])

        let coeffOther = a1 * b2 - a2 * b1
        let rhsOther = a1 * c2 - a2 * c1
        let rhsOtherSum = numericSum(constant: a1 * c2, terms: [-(a2 * c1)])

        let otherQuotient = divisionLatex(rhsOther, coeffOther)

        let isoSubExpr = affineSubstituted(constant: c1, terms: [(-b1, fOther)])
        let isoBody = fractionBody(numerator: isoSubExpr, denominator: a1)
        let isoMidNum = numericSum(constant: c1, terms: [(-b1) * fOther])
        let isoMid = fractionBody(numerator: isoMidNum, denominator: a1)

        return [
            ExplanationStep(
                text: "Despejamos \(vIso) en las dos ecuaciones.",
                latex: "\(vIso) = \(iso0) \\quad \(vIso) = \(iso1)"),
            ExplanationStep(
                text: "Igualamos las dos expresiones (las dos valen \(vIso)).",
                latex: "\(iso0) = \(iso1)"),
            ExplanationStep(
                text: "Multiplicamos en cruz para quitar las fracciones.",
                latex: "\(crossLeft) = \(crossRight)"),
            ExplanationStep(
                text: "Quitamos los paréntesis multiplicando en cada lado.",
                latex: "\(leftDist) = \(rightDist)"),
            ExplanationStep(
                text: "Pasamos los términos con \(vOther) a un lado y los números al otro.",
                latex: "\(coeffTimes(coeffOther, vOther)) = \(rhsOtherSum) = \(numberF(rhsOther))"),
            ExplanationStep(
                text: "Despejamos \(vOther) dividiendo entre su coeficiente.",
                latex: "\(vOther) = \(otherQuotient) = \(fOther.latex())"),
            ExplanationStep(
                text: "Sustituimos el valor de \(vOther) en \(vIso) = \(iso0) y operamos.",
                latex: "\(vIso) = \(isoBody) = \(isoMid) = \(fIso.latex())")
        ]
    }

    private func twoReduction(rows: [[Fraction]], variables: [String], solution: [Fraction]) -> [ExplanationStep] {
        let n = 2
        let x = variables[0], y = variables[1]
        let fx = value(solution, 0), fy = value(solution, 1)
        let a1 = rows[0][0], b1 = rows[0][1], c1 = rows[0][n]
        let a2 = rows[1][0], b2 = rows[1][1], c2 = rows[1][n]

        let mult0 = [a2 * a1, a2 * b1, a2 * c1]
        let mult1 = [a1 * a2, a1 * b2, a1 * c2]
        let coeffY = a2 * b1 - a1 * b2
        let rhs = a2 * c1 - a1 * c2

        let elimination =
            "(\(numberF(mult0[0])) - \(numberF(mult1[0])))\(x) "
            + "+ (\(numberF(mult0[1])) - \(numberF(mult1[1])))\(y) "
            + "= \(numberF(mult0[2])) - \(numberF(mult1[2]))"

        let yQuotient = divisionLatex(rhs, coeffY)

        let backEq = !a1.isZero ? 0 : 1
        let aBack = rows[backEq][0], bBack = rows[backEq][1], cBack = rows[backEq][n]
        let xSubExpr = affineSubstituted(constant: cBack, terms: [(-bBack, fy)])
        let xBody = fractionBody(numerator: xSubExpr, denominator: aBack)
        let xMidNum = numericSum(constant: cBack, terms: [(-bBack) * fy])
        let xMid = fractionBody(numerator: xMidNum, denominator: aBack)

        return [
            ExplanationStep(
                text: "Multiplicamos la 1.ª ecuación por \(numberF(a2)) y la 2.ª por \(numberF(a1)) para igualar el coeficiente de \(x).",
                latex: "E_1 \\times \(numberF(a2)) \\quad E_2 \\times \(numberF(a1))"),
            ExplanationStep(
                text: "Las ecuaciones quedan así:",
                latex: "\(equationFractionLatex(mult0, variables: variables)) \\quad \(equationFractionLatex(mult1, variables: variables))"),
            ExplanationStep(
                text: "Restamos la 2.ª de la 1.ª; la \(x) se elimina.",
                latex: elimination),
            ExplanationStep(
                text: "Queda solo \(y); lo despejamos dividiendo entre su coeficiente.",
                latex: "\(coeffTimes(coeffY, y)) = \(numberF(rhs)) \\;\\Rightarrow\\; \(y) = \(yQuotient) = \(fy.latex())"),
            ExplanationStep(
                text: "Sustituimos el valor de \(y) en la \(ordinal(backEq + 1)) ecuación y operamos.",
                latex: "\(x) = \(xBody) = \(xMid) = \(fx.latex())")
        ]
    }

    private func threeCramer(rows: [[Fraction]], variables: [String], solution: [Fraction]) -> [ExplanationStep] {
        let matrix = rows.map { Array($0.prefix(3)) }
        let constants = rows.map { $0[3] }
        let delta = determinant3x3(matrix)

        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Calculamos el determinante del sistema Δ con la regla de Sarrus.",
                latex: "\\Delta = \(sarrusLatex(matrix)) = \(delta.latex())")
        ]

        var variableDeterminants: [Fraction] = []
        for column in 0..<3 {
            var replaced = matrix
            for row in 0..<3 { replaced[row][column] = constants[row] }
            let detVar = determinant3x3(replaced)
            variableDeterminants.append(detVar)
            steps.append(ExplanationStep(
                text: "Sustituimos la columna de \(variables[column]) por los términos independientes y calculamos Δ de \(variables[column]).",
                latex: "\\Delta_\(variables[column]) = \(sarrusLatex(replaced)) = \(detVar.latex())"))
        }

        for column in 0..<3 {
            let v = variables[column]
            steps.append(ExplanationStep(
                text: "Aplicamos Cramer: dividimos Δ de \(v) entre Δ.",
                latex: "\(v) = \\displaystyle\\frac{\\Delta_\(v)}{\\Delta} = \(divisionLatex(variableDeterminants[column], delta)) = \(value(solution, column).latex())"))
        }
        return steps
    }

    private func threeGauss(rows: [[Fraction]], variables: [String], solution: [Fraction]) -> [ExplanationStep] {
        let x = variables[0], y = variables[1], z = variables[2]
        let fx = value(solution, 0), fy = value(solution, 1), fz = value(solution, 2)

        var matrix = rows
        var steps: [ExplanationStep] = [
            ExplanationStep(
                text: "Escribimos la matriz ampliada (coeficientes y términos independientes).",
                latex: matrixLatex(matrix))
        ]

        if matrix[0][0].isZero, let swapWith = (1..<3).first(where: { !matrix[$0][0].isZero }) {
            matrix.swapAt(0, swapWith)
        }

        var ops1: [String] = []
        if !matrix[0][0].isZero {
            for r in 1..<3 {
                let factor = matrix[r][0] / matrix[0][0]
                if !factor.isZero {
                    matrix[r] = subtractRows(matrix[r], scaleRow(matrix[0], by: factor))
                    ops1.append("F_\(r + 1) \\to F_\(r + 1) - \(numberF(factor)) F_1")
                }
            }
        }
        steps.append(ExplanationStep(
            text: "Hacemos ceros bajo el primer pivote para eliminar \(x) de la 2.ª y la 3.ª ecuación.",
            latex: "\(ops1.isEmpty ? "" : ops1.joined(separator: " \\quad ") + " \\;\\Rightarrow\\; ")\(matrixLatex(matrix))"))

        if matrix[1][1].isZero, !matrix[2][1].isZero {
            matrix.swapAt(1, 2)
        }
        if !matrix[1][1].isZero {
            let factor = matrix[2][1] / matrix[1][1]
            if !factor.isZero {
                matrix[2] = subtractRows(matrix[2], scaleRow(matrix[1], by: factor))
                steps.append(ExplanationStep(
                    text: "Hacemos cero bajo el segundo pivote para eliminar \(y) de la 3.ª ecuación.",
                    latex: "F_3 \\to F_3 - \(numberF(factor)) F_2 \\;\\Rightarrow\\; \(matrixLatex(matrix))"))
            } else {
                steps.append(ExplanationStep(
                    text: "La 3.ª ecuación ya no tiene \(y): el sistema queda triangular.",
                    latex: matrixLatex(matrix)))
            }
        }

        let cz = matrix[2][2], dz = matrix[2][3]
        steps.append(ExplanationStep(
            text: "La última fila es \(coeffTimes(cz, z)) = \(numberF(dz)); despejamos \(z).",
            latex: "\(z) = \(divisionLatex(dz, cz)) = \(fz.latex())"))

        let b1y = matrix[1][1], c1z = matrix[1][2], d1 = matrix[1][3]
        let ySubExpr = affineSubstituted(constant: d1, terms: [(-c1z, fz)])
        let yBody = fractionBody(numerator: ySubExpr, denominator: b1y)
        let yMidNum = numericSum(constant: d1, terms: [(-c1z) * fz])
        let yMid = fractionBody(numerator: yMidNum, denominator: b1y)
        steps.append(ExplanationStep(
            text: "Sustituimos \(z) en la 2.ª fila y despejamos \(y).",
            latex: "\(y) = \(yBody) = \(yMid) = \(fy.latex())"))

        let a0x = matrix[0][0], b0y = matrix[0][1], c0z = matrix[0][2], d0 = matrix[0][3]
        let xSubExpr = affineSubstituted(constant: d0, terms: [(-b0y, fy), (-c0z, fz)])
        let xBody = fractionBody(numerator: xSubExpr, denominator: a0x)
        let xMidNum = numericSum(constant: d0, terms: [(-b0y) * fy, (-c0z) * fz])
        let xMid = fractionBody(numerator: xMidNum, denominator: a0x)
        steps.append(ExplanationStep(
            text: "Sustituimos \(y) y \(z) en la 1.ª fila y despejamos \(x).",
            latex: "\(x) = \(xBody) = \(xMid) = \(fx.latex())"))

        return steps
    }

    private func augmented(_ input: SystemInput) -> [[Fraction]] {
        let n = input.size.equationCount
        var rows: [[Fraction]] = []
        for r in 0..<n {
            var coeffs = (r < input.coefficients.count ? input.coefficients[r] : []).map { Fraction(approximating: $0) }
            while coeffs.count < n { coeffs.append(Fraction(0)) }
            let constant = r < input.constants.count ? Fraction(approximating: input.constants[r]) : Fraction(0)
            rows.append(Array(coeffs.prefix(n)) + [constant])
        }
        return rows
    }

    private func solutionFractions(rows: [[Fraction]], result: SystemResult) -> [Fraction] {
        cramerSolution(rows: rows) ?? result.solution.map { Fraction(approximating: $0) }
    }

    // Resuelve el sistema en fracciones exactas por Cramer (Δ y cada Δ de variable).
    private func cramerSolution(rows: [[Fraction]]) -> [Fraction]? {
        let n = rows.count
        guard n > 0 else { return nil }
        let matrix = rows.map { Array($0.prefix(n)) }
        let constants = rows.map { $0[n] }
        let delta = determinant(matrix)
        guard !delta.isZero else { return nil }
        var solution: [Fraction] = []
        for column in 0..<n {
            var replaced = matrix
            for row in 0..<n { replaced[row][column] = constants[row] }
            solution.append(determinant(replaced) / delta)
        }
        return solution
    }

    private func determinant(_ m: [[Fraction]]) -> Fraction {
        if m.count >= 3 { return determinant3x3(m) }
        return determinant2x2(m)
    }

    private func determinant2x2(_ m: [[Fraction]]) -> Fraction {
        m[0][0] * m[1][1] - m[0][1] * m[1][0]
    }

    // Calcula el determinante 3×3 por la regla de Sarrus.
    private func determinant3x3(_ m: [[Fraction]]) -> Fraction {
        m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
        - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
        + m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0])
    }

    private func sarrusLatex(_ m: [[Fraction]]) -> String {
        func factor(_ value: Fraction) -> String {
            value.isNegative ? "\\left(\(value.latex())\\right)" : value.latex()
        }
        func product(_ a: Fraction, _ b: Fraction, _ c: Fraction) -> String {
            "\(factor(a)) \\cdot \(factor(b)) \\cdot \(factor(c))"
        }
        let positive =
            "\(product(m[0][0], m[1][1], m[2][2])) + \(product(m[0][1], m[1][2], m[2][0])) + \(product(m[0][2], m[1][0], m[2][1]))"
        let negative =
            "\(product(m[0][2], m[1][1], m[2][0])) + \(product(m[0][0], m[1][2], m[2][1])) + \(product(m[0][1], m[1][0], m[2][2]))"
        return "\(positive) - \\left(\(negative)\\right)"
    }

    private func matrixLatex(_ rows: [[Fraction]]) -> String {
        let body = rows.map { row in
            row.map { $0.latex() }.joined(separator: " & ")
        }.joined(separator: " \\\\ ")
        return "\\begin{bmatrix} \(body) \\end{bmatrix}"
    }

    private struct ParametricSolution {

        let expressions: [(constant: Fraction, terms: [(Fraction, String)])]

        let parameterSymbols: [String]
    }

    // Construye la solución paramétrica: detecta las variables libres y despeja las pivote vía RREF.
    private func parametricSolution(rows: [[Fraction]]) -> ParametricSolution? {
        let n = rows.count
        guard n >= 1, rows.allSatisfy({ $0.count >= n + 1 }) else { return nil }
        let (reduced, pivotRowForColumn) = rref(rows)

        let freeColumns = (0..<n).filter { pivotRowForColumn[$0] == nil }
        guard !freeColumns.isEmpty else { return nil }

        let paramOrder = ["t", "s"]
        let freeDescending = freeColumns.sorted(by: >)
        var symbolForColumn: [Int: String] = [:]
        for (i, column) in freeDescending.enumerated() {
            symbolForColumn[column] = i < paramOrder.count ? paramOrder[i] : "t_{\(i)}"
        }

        var expressions: [(constant: Fraction, terms: [(Fraction, String)])] = []
        for column in 0..<n {
            if let symbol = symbolForColumn[column] {

                expressions.append((Fraction(0), [(Fraction(1), symbol)]))
            } else if let pivotRow = pivotRowForColumn[column] {

                let constant = reduced[pivotRow][n]
                var terms: [(Fraction, String)] = []
                for freeColumn in freeDescending {
                    let coefficient = -reduced[pivotRow][freeColumn]
                    if !coefficient.isZero, let symbol = symbolForColumn[freeColumn] {
                        terms.append((coefficient, symbol))
                    }
                }
                expressions.append((constant, terms))
            } else {
                expressions.append((Fraction(0), []))
            }
        }

        let usedSymbols = freeDescending.compactMap { symbolForColumn[$0] }
        return ParametricSolution(expressions: expressions, parameterSymbols: usedSymbols)
    }

    // Reduce la matriz a forma escalonada reducida (Gauss-Jordan).
    private func rref(_ matrix: [[Fraction]]) -> (reduced: [[Fraction]], pivotRowForColumn: [Int?]) {
        var m = matrix
        let rowCount = m.count
        let varCount = rowCount
        var pivotRowForColumn = [Int?](repeating: nil, count: varCount)
        var pivotRow = 0
        for column in 0..<varCount {
            guard pivotRow < rowCount else { break }
            guard let selected = (pivotRow..<rowCount).first(where: { !m[$0][column].isZero }) else { continue }
            m.swapAt(pivotRow, selected)
            let pivotValue = m[pivotRow][column]
            m[pivotRow] = m[pivotRow].map { $0 / pivotValue }
            for r in 0..<rowCount where r != pivotRow {
                let factor = m[r][column]
                if !factor.isZero {
                    m[r] = zip(m[r], m[pivotRow]).map { $0 - factor * $1 }
                }
            }
            pivotRowForColumn[column] = pivotRow
            pivotRow += 1
        }
        return (m, pivotRowForColumn)
    }

    // Escalona la matriz por eliminación de Gauss haciendo ceros bajo cada pivote.
    private func rowEchelon(_ matrix: [[Fraction]]) -> [[Fraction]] {
        var m = matrix
        let rowCount = m.count
        let varCount = rowCount
        var pivotRow = 0
        for column in 0..<varCount {
            guard pivotRow < rowCount else { break }
            guard let selected = (pivotRow..<rowCount).first(where: { !m[$0][column].isZero }) else { continue }
            m.swapAt(pivotRow, selected)
            for r in (pivotRow + 1)..<rowCount {
                let factor = m[r][column] / m[pivotRow][column]
                if !factor.isZero {
                    m[r] = zip(m[r], m[pivotRow]).map { $0 - factor * $1 }
                }
            }
            pivotRow += 1
        }
        return m
    }

    private func parametricLatex(rows: [[Fraction]], variables: [String]) -> String? {
        guard let parametric = parametricSolution(rows: rows) else { return nil }
        return zip(variables, parametric.expressions)
            .map { name, expression in
                "\(name) = \(affineExpression(constant: expression.constant, terms: expression.terms))"
            }
            .joined(separator: " \\quad ")
    }

    private func scaleRow(_ row: [Fraction], by k: Fraction) -> [Fraction] {
        row.map { $0 * k }
    }

    private func subtractRows(_ lhs: [Fraction], _ rhs: [Fraction]) -> [Fraction] {
        zip(lhs, rhs).map { $0 - $1 }
    }

    private func solutionLatex(for input: SystemInput, result: SystemResult, variables: [String]) -> String {
        switch result.outcome {
        case .unique:
            let solution = solutionFractions(rows: augmented(input), result: result)
            return zip(variables, solution)
                .map { "\($0.0) = \($0.1.latex())" }
                .joined(separator: " \\quad ")
        case .noSolution:
            return "\\text{Sin solución}"
        case .infiniteSolutions:

            if variables.count == 2, let parametric = parametric2x2(rows: augmented(input)) {
                let expr = affineExpression(constant: parametric.constant, terms: [(parametric.tCoeff, "t")])
                return "x = \(expr) \\quad y = t"
            }
            if let latex = parametricLatex(rows: augmented(input), variables: variables) {
                return latex
            }
            return "\\text{Infinitas soluciones}"
        }
    }

    private func summary(for input: SystemInput, result: SystemResult, variables: [String]) -> String {
        switch result.outcome {
        case .unique:
            let solution = solutionFractions(rows: augmented(input), result: result)
            let list = zip(variables, solution)
                .map { "\($0.0) = \(plain($0.1))" }
                .joined(separator: ", ")
            return "Solución única: \(list)"
        case .noSolution:
            return "Sistema incompatible: sin solución"
        case .infiniteSolutions:
            if variables.count == 2, let parametric = parametric2x2(rows: augmented(input)) {
                let expr = affinePlain(constant: parametric.constant, terms: [(parametric.tCoeff, "t")])
                return "Infinitas soluciones: x = \(expr), y = t (t es un parámetro)"
            }
            if let parametric = parametricSolution(rows: augmented(input)) {
                let list = zip(variables, parametric.expressions)
                    .map { name, expression in
                        "\(name) = \(affinePlain(constant: expression.constant, terms: expression.terms))"
                    }
                    .joined(separator: ", ")
                let symbols = parametric.parameterSymbols
                let tail = symbols.count == 1
                    ? "(\(symbols[0]) es un parámetro)"
                    : "(\(symbols.joined(separator: " y ")) son parámetros)"
                return "Infinitas soluciones: \(list) \(tail)"
            }
            return "Sistema compatible indeterminado: infinitas soluciones"
        }
    }

    private func isolatedExpr(row: [Fraction], isolate iv: Int, variables: [String]) -> String {
        let coefficient = row[iv]
        let numerator = isolatedNumerator(row: row, isolate: iv, variables: variables)
        if coefficient == Fraction(1) { return numerator }
        if coefficient == Fraction(-1) { return "-\\left(\(numerator)\\right)" }
        return "\\displaystyle\\frac{\(numerator)}{\(numberF(coefficient))}"
    }

    private func isolatedNumerator(row: [Fraction], isolate iv: Int, variables: [String]) -> String {
        let constant = row[variables.count]
        var terms: [(Fraction, String)] = []
        for j in variables.indices where j != iv {
            terms.append((-row[j], variables[j]))
        }
        return affineExpression(constant: constant, terms: terms)
    }

    private func affineExpression(constant: Fraction, terms: [(Fraction, String)]) -> String {
        var parts: [String] = []
        let hasTerm = terms.contains { !$0.0.isZero }
        if !constant.isZero || !hasTerm {
            parts.append(numberF(constant))
        }
        for (coefficient, symbol) in terms where !coefficient.isZero {
            let magnitude = coefficient.magnitude
            let factor = magnitude == Fraction(1) ? "" : numberF(magnitude)
            let term = "\(factor)\(symbol)"
            if parts.isEmpty {
                parts.append(coefficient.isNegative ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient.isNegative ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func affineSubstituted(constant: Fraction, terms: [(Fraction, Fraction)]) -> String {
        var parts: [String] = []
        let hasTerm = terms.contains { !$0.0.isZero }
        if !constant.isZero || !hasTerm {
            parts.append(numberF(constant))
        }
        for (coefficient, valueFraction) in terms where !coefficient.isZero {
            let magnitude = coefficient.magnitude
            let factor = magnitude == Fraction(1) ? "" : "\(numberF(magnitude)) \\cdot "
            let term = "\(factor)\\left(\(valueFraction.latex())\\right)"
            if parts.isEmpty {
                parts.append(coefficient.isNegative ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient.isNegative ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func numericSum(constant: Fraction, terms: [Fraction]) -> String {
        var parts: [String] = []
        let hasTerm = terms.contains { !$0.isZero }
        if !constant.isZero || !hasTerm {
            parts.append(numberF(constant))
        }
        for value in terms where !value.isZero {
            if parts.isEmpty {
                parts.append(value.isNegative ? "-\(numberF(value.magnitude))" : numberF(value.magnitude))
            } else {
                parts.append("\(value.isNegative ? "-" : "+") \(numberF(value.magnitude))")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func divisionLatex(_ numerator: Fraction, _ denominator: Fraction) -> String {
        if numerator.isInteger, denominator.isInteger {
            return "\\displaystyle\\frac{\(numerator.numerator)}{\(denominator.numerator)}"
        }
        return "\\displaystyle\\frac{\(numerator.latex())}{\(denominator.latex())}"
    }

    private func fractionBody(numerator: String, denominator: Fraction) -> String {
        if denominator == Fraction(1) { return numerator }
        if denominator == Fraction(-1) { return "-\\left(\(numerator)\\right)" }
        return "\\displaystyle\\frac{\(numerator)}{\(numberF(denominator))}"
    }

    private func equationFractionLatex(_ row: [Fraction], variables: [String]) -> String {
        let terms = variables.indices.map { (row[$0], variables[$0]) }
        return "\(linearFraction(terms)) = \(numberF(row[variables.count]))"
    }

    private func linearFraction(_ terms: [(Fraction, String)]) -> String {
        var parts: [String] = []
        for (coefficient, symbol) in terms where !coefficient.isZero {
            let magnitude = coefficient.magnitude
            let factor = magnitude == Fraction(1) ? "" : numberF(magnitude)
            let term = "\(factor)\(symbol)"
            if parts.isEmpty {
                parts.append(coefficient.isNegative ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient.isNegative ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func value(_ solution: [Fraction], _ index: Int) -> Fraction {
        index < solution.count ? solution[index] : Fraction(0)
    }

    private func preferUnitRow(_ rows: [[Fraction]], column: Int) -> Int? {
        rows.indices.first { rows[$0][column].magnitude == Fraction(1) }
    }

    private func coeffTimes(_ coefficient: Fraction, _ symbol: String) -> String {
        if coefficient == Fraction(1) { return symbol }
        if coefficient == Fraction(-1) { return "-\(symbol)" }
        return "\(numberF(coefficient))\(symbol)"
    }

    private func crossTerm(_ coefficient: Fraction, _ inner: String) -> String {
        if coefficient == Fraction(1) { return "\\left(\(inner)\\right)" }
        if coefficient == Fraction(-1) { return "-\\left(\(inner)\\right)" }
        return "\(numberF(coefficient))\\left(\(inner)\\right)"
    }

    private func signedTerm(_ coefficient: Fraction, _ symbol: String) -> String {
        guard !coefficient.isZero else { return "" }
        let sign = coefficient.isNegative ? "-" : "+"
        let magnitude = coefficient.magnitude
        let factor = magnitude == Fraction(1) ? "" : numberF(magnitude)
        return "\(sign) \(factor)\(symbol)"
    }

    private func plain(_ f: Fraction) -> String {
        f.isInteger ? "\(f.numerator)" : "\(f.numerator)/\(f.denominator)"
    }

    private func affinePlain(constant: Fraction, terms: [(Fraction, String)]) -> String {
        var parts: [String] = []
        let hasTerm = terms.contains { !$0.0.isZero }
        if !constant.isZero || !hasTerm {
            parts.append(plain(constant))
        }
        for (coefficient, symbol) in terms where !coefficient.isZero {
            let magnitude = coefficient.magnitude
            let factor = magnitude == Fraction(1) ? "" : plain(magnitude)
            let term = "\(factor)\(symbol)"
            if parts.isEmpty {
                parts.append(coefficient.isNegative ? "-\(term)" : term)
            } else {
                parts.append("\(coefficient.isNegative ? "-" : "+") \(term)")
            }
        }
        return parts.isEmpty ? "0" : parts.joined(separator: " ")
    }

    private func methodName(_ method: SystemMethod) -> String {
        switch method {
        case .substitution: return "sustitución"
        case .equalization: return "igualación"
        case .reduction:    return "reducción"
        case .cramer:       return "Cramer"
        case .gauss:        return "Gauss"
        }
    }

    private func coeff(_ values: [Double], _ index: Int) -> Double {
        index < values.count ? values[index] : 0
    }

    private func ordinal(_ n: Int) -> String {
        switch n {
        case 1: return "1.ª"
        case 2: return "2.ª"
        case 3: return "3.ª"
        default: return "\(n).ª"
        }
    }

    private func numberF(_ f: Fraction) -> String {
        f.latex()
    }

    private func number(_ value: Double) -> String {
        if value == value.rounded(), abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(format: "%g", value)
    }
}
