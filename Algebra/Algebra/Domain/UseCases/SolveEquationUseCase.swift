protocol SolveEquationUseCase: Sendable {
    func execute(_ input: EquationInput) -> EquationResult
}

struct SolveEquationUseCaseImpl: SolveEquationUseCase {
    private let epsilon = 1e-9
    private let rootTolerance = 1e-6

    func execute(_ input: EquationInput) -> EquationResult {
        switch input.type {
        case .linear:
            return solveLinear(a: coeff(input.coefficients, 0), b: coeff(input.coefficients, 1))
        case .quadratic:
            return solveQuadratic(a: coeff(input.coefficients, 0),
                                  b: coeff(input.coefficients, 1),
                                  c: coeff(input.coefficients, 2))
        case .cubic, .quartic:
            return solveRuffini(input.coefficients)
        case .biquadratic:
            return solveBiquadratic(a: coeff(input.coefficients, 0),
                                    b: coeff(input.coefficients, 1),
                                    c: coeff(input.coefficients, 2))
        }
    }

    // Resuelve ax + b = 0 despejando x = -b/a (contempla los casos degenerados).
    private func solveLinear(a: Double, b: Double) -> EquationResult {
        guard abs(a) >= epsilon else {
            let outcome: SolveOutcome = abs(b) < epsilon ? .infiniteSolutions : .noSolution
            return EquationResult(roots: [], outcome: outcome, method: .linearFormula,
                                  discriminant: nil, ruffiniSteps: [], finalQuadratic: nil)
        }
        return EquationResult(roots: normalize([-b / a]), outcome: .solved, method: .linearFormula,
                              discriminant: nil, ruffiniSteps: [], finalQuadratic: nil)
    }

    // Resuelve la ecuación de 2.º grado con la fórmula general según el signo del discriminante.
    private func solveQuadratic(a: Double, b: Double, c: Double) -> EquationResult {

        guard abs(a) >= epsilon else {
            return solveLinear(a: b, b: c)
        }
        let discriminant = b * b - 4 * a * c
        let roots: [Double]
        let outcome: SolveOutcome
        if discriminant > epsilon {
            let r = discriminant.squareRoot()
            let x1 = (-b - r) / (2 * a)
            let x2 = (-b + r) / (2 * a)
            roots = normalize([min(x1, x2), max(x1, x2)])
            outcome = .solved
        } else if abs(discriminant) <= epsilon {
            roots = normalize([-b / (2 * a)])
            outcome = .solved
        } else {
            roots = []
            outcome = .noRealSolutions
        }
        return EquationResult(roots: roots, outcome: outcome, method: .quadraticFormula,
                              discriminant: discriminant, ruffiniSteps: [], finalQuadratic: nil)
    }

    // Baja el grado extrayendo raíces racionales por Ruffini y resuelve el resto (cuadrática o lineal).
    private func solveRuffini(_ coefficients: [Double]) -> EquationResult {

        var work = coefficients
        while work.count > 1 && abs(work[0]) < epsilon {
            work.removeFirst()
        }

        guard work.count >= 2 else {
            let k = work.first ?? 0
            let outcome: SolveOutcome = abs(k) < epsilon ? .infiniteSolutions : .noSolution
            return EquationResult(roots: [], outcome: outcome, method: .ruffini,
                                  discriminant: nil, ruffiniSteps: [], finalQuadratic: nil)
        }

        var roots: [Double] = []
        var steps: [RuffiniStep] = []
        var bailedOut = false

        while work.count >= 4 {
            if let r = findRationalRoot(work) {
                let quotient = syntheticDivision(work, root: r)
                steps.append(RuffiniStep(root: r, quotient: quotient))
                roots.append(r)
                work = quotient
            } else {
                bailedOut = true
                break
            }
        }

        var finalQuadratic: QuadraticInfo?
        if !bailedOut {
            if work.count == 3 {
                let info = quadraticInfo(a: work[0], b: work[1], c: work[2])
                finalQuadratic = info
                roots.append(contentsOf: info.roots)
            } else if work.count == 2 {
                roots.append(-work[1] / work[0])
            }

        }

        let cleaned = cleanRoots(roots)
        let outcome: SolveOutcome
        if bailedOut {
            outcome = .partial
        } else if cleaned.isEmpty {
            outcome = .noRealSolutions
        } else {
            outcome = .solved
        }
        return EquationResult(roots: cleaned, outcome: outcome, method: .ruffini,
                              discriminant: nil, ruffiniSteps: steps, finalQuadratic: finalQuadratic)
    }

    // Resuelve la bicuadrada con el cambio t = x² y deshaciendo el cambio (x = ±√t).
    private func solveBiquadratic(a: Double, b: Double, c: Double) -> EquationResult {

        guard abs(a) >= epsilon else {
            return solveQuadratic(a: b, b: 0, c: c)
        }

        let info = quadraticInfo(a: a, b: b, c: c)
        var xs: [Double] = []
        for t in info.roots {
            if t > epsilon {
                let s = t.squareRoot()
                xs.append(s)
                xs.append(-s)
            } else if abs(t) <= epsilon {
                xs.append(0)
            }

        }
        let cleaned = cleanRoots(xs)
        let outcome: SolveOutcome = cleaned.isEmpty ? .noRealSolutions : .solved
        return EquationResult(roots: cleaned, outcome: outcome, method: .biquadratic,
                              discriminant: nil, ruffiniSteps: [], finalQuadratic: info)
    }

    private func quadraticInfo(a: Double, b: Double, c: Double) -> QuadraticInfo {
        let discriminant = b * b - 4 * a * c
        var roots: [Double] = []
        if abs(a) < epsilon {

            if abs(b) >= epsilon { roots = [-c / b] }
        } else if discriminant > epsilon {
            let r = discriminant.squareRoot()
            let x1 = (-b - r) / (2 * a)
            let x2 = (-b + r) / (2 * a)
            roots = [min(x1, x2), max(x1, x2)]
        } else if abs(discriminant) <= epsilon {
            roots = [-b / (2 * a)]
        }
        return QuadraticInfo(a: a, b: b, c: c, discriminant: discriminant, roots: normalize(roots))
    }

    // Busca una raíz racional probando divisores p/q del término independiente y del coeficiente líder.
    private func findRationalRoot(_ coefficients: [Double]) -> Double? {
        guard let lead = coefficients.first, let constant = coefficients.last else { return nil }

        var candidates: Set<Double> = []

        if abs(constant) < epsilon { candidates.insert(0) }

        if let leadInt = nearestInt(lead), let constInt = nearestInt(constant),
           leadInt != 0, constInt != 0 {
            let ps = divisors(abs(constInt))
            let qs = divisors(abs(leadInt))
            for p in ps {
                for q in qs {
                    let value = Double(p) / Double(q)
                    candidates.insert(value)
                    candidates.insert(-value)
                }
            }
        } else {

            for i in -20...20 { candidates.insert(Double(i)) }
        }

        let ordered = candidates.sorted { abs($0) == abs($1) ? $0 < $1 : abs($0) < abs($1) }
        for candidate in ordered where abs(horner(coefficients, x: candidate)) < rootTolerance {
            return candidate
        }
        return nil
    }

    private func horner(_ coefficients: [Double], x: Double) -> Double {
        var accumulator = 0.0
        for coefficient in coefficients {
            accumulator = accumulator * x + coefficient
        }
        return accumulator
    }

    // Divide el polinomio entre (x - raíz) por división sintética (regla de Ruffini).
    private func syntheticDivision(_ coefficients: [Double], root: Double) -> [Double] {
        guard coefficients.count >= 2 else { return [] }
        var b: [Double] = [coefficients[0]]
        for i in 1..<coefficients.count {
            b.append(coefficients[i] + root * b[i - 1])
        }
        return Array(b.dropLast())
    }

    private func coeff(_ values: [Double], _ index: Int) -> Double {
        index < values.count ? values[index] : 0
    }

    private func nearestInt(_ value: Double) -> Int? {
        let rounded = value.rounded()
        guard abs(value - rounded) < rootTolerance, abs(rounded) < 1e9 else { return nil }
        return Int(rounded)
    }

    private func divisors(_ n: Int) -> [Int] {
        guard n > 0 else { return [] }
        var result: [Int] = []
        var i = 1
        while i <= n {
            if n % i == 0 { result.append(i) }
            i += 1
        }
        return result
    }

    private func normalize(_ roots: [Double]) -> [Double] {
        roots.map { abs($0) < epsilon ? 0 : $0 }
    }

    private func cleanRoots(_ roots: [Double]) -> [Double] {
        let sorted = normalize(roots).sorted()
        var result: [Double] = []
        for root in sorted {
            if let last = result.last, abs(last - root) < rootTolerance { continue }
            result.append(root)
        }
        return result
    }
}
