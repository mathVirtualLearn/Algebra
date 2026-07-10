protocol GenerateEquationExerciseUseCase {
    func execute(type: EquationType) -> EquationExercise
}

struct GenerateEquationExerciseUseCaseImpl: GenerateEquationExerciseUseCase {
    private let random: RandomSource
    private let coefficientLimit = 200

    init(random: RandomSource) {
        self.random = random
    }

    func execute(type: EquationType) -> EquationExercise {
        switch type {
        case .linear:      return linear()
        case .quadratic:   return quadratic()
        case .cubic:       return polynomial(type: .cubic, rootCount: 3)
        case .quartic:     return polynomial(type: .quartic, rootCount: 4)
        case .biquadratic: return biquadratic()
        }
    }

    private func linear() -> EquationExercise {
        build {
            let (factor, root) = linearRootFactor()
            let coefficients = expandFactors([factor])
            return (EquationInput(type: .linear, coefficients: coefficients.map(Double.init)), [root])
        }
    }

    // ~15% raíz doble a·(x−r)²; del resto, ~30% con alguna raíz fraccionaria y ~70% con raíces enteras y líder variado.
    private func quadratic() -> EquationExercise {
        build {
            if random.int(in: 0...99) < 15 {
                let a = random.int(in: 1...3)
                let r = nonZeroRoot(in: -6...6)
                let coefficients = expandFactors([(1, -r), (1, -r)], leading: a)
                return (EquationInput(type: .quadratic, coefficients: coefficients.map(Double.init)),
                        [Fraction(r)])
            }
            if random.int(in: 0...9) < 3 {
                let (f1, r1) = quadraticFractionalRootFactor()
                var (f2, r2) = quadraticRootFactor()
                var attempts = 0
                while r2 == r1 && attempts < 20 {
                    (f2, r2) = quadraticRootFactor()
                    attempts += 1
                }
                let coefficients = expandFactors([f1, f2])
                return (EquationInput(type: .quadratic, coefficients: coefficients.map(Double.init)),
                        distinctSorted([r1, r2]))
            }
            let a = random.int(in: 1...3)
            let r1 = nonZeroRoot(in: -6...6)
            var r2 = nonZeroRoot(in: -6...6)
            var attempts = 0
            while r2 == r1 && attempts < 20 {
                r2 = nonZeroRoot(in: -6...6)
                attempts += 1
            }
            let coefficients = expandFactors([(1, -r1), (1, -r2)], leading: a)
            return (EquationInput(type: .quadratic, coefficients: coefficients.map(Double.init)),
                    distinctSorted([Fraction(r1), Fraction(r2)]))
        }
    }

    // Construye desde raíces enteras (a veces con una repetida) un polinomio y lo multiplica por un líder a para variar el coeficiente principal.
    private func polynomial(type: EquationType, rootCount: Int) -> EquationExercise {
        build {
            let a = self.random.int(in: 1...3)
            let raw = self.polynomialRoots(count: rootCount)
            let coefficients = self.expandFactors(raw.map { (1, -$0) }, leading: a)
            return (EquationInput(type: type, coefficients: coefficients.map(Double.init)),
                    self.distinctSorted(raw.map { Fraction($0) }))
        }
    }

    // Genera la bicuadrada con raíces ±k enteras y multiplica por un líder a para variar el coeficiente principal.
    private func biquadratic() -> EquationExercise {
        build {
            let a = self.random.int(in: 1...3)
            let k1 = self.random.int(in: 1...4)
            var k2 = self.random.int(in: 1...4)
            while k2 == k1 { k2 = self.random.int(in: 1...4) }
            let t1 = k1 * k1
            let t2 = k2 * k2
            let coefficients: [Int] = [a, -a * (t1 + t2), a * t1 * t2]
            let roots = self.distinctSorted([-k1, k1, -k2, k2].map { Fraction($0) })
            return (EquationInput(type: .biquadratic, coefficients: coefficients.map(Double.init)), roots)
        }
    }

    // ~30% raíz fraccionaria (q∈{2,3}); ~70% raíz entera con líder a∈{1,2,3}.
    private func linearRootFactor() -> (factor: (Int, Int), root: Fraction) {
        let makeFraction = random.int(in: 0...9) < 3
        if makeFraction {
            let q = random.int(in: 2...3)
            var p = nonZeroRoot(in: -6...6)
            while p % q == 0 { p = nonZeroRoot(in: -6...6) }
            return ((q, -p), Fraction(p, q))
        }
        let a = random.int(in: 1...3)
        let p = nonZeroRoot(in: -9...9)
        return ((a, -a * p), Fraction(p))
    }

    private func quadraticRootFactor() -> (factor: (Int, Int), root: Fraction) {
        let q = random.int(in: 1...3)
        if q == 1 {
            let p = nonZeroRoot(in: -6...6)
            return ((1, -p), Fraction(p))
        }
        var p = nonZeroRoot(in: -6...6)
        while p % q == 0 { p = nonZeroRoot(in: -6...6) }
        return ((q, -p), Fraction(p, q))
    }

    private func quadraticFractionalRootFactor() -> (factor: (Int, Int), root: Fraction) {
        let q = random.int(in: 2...3)
        var p = nonZeroRoot(in: -6...6)
        while p % q == 0 { p = nonZeroRoot(in: -6...6) }
        return ((q, -p), Fraction(p, q))
    }

    // Repite la generación hasta que ningún coeficiente supere el tope; devuelve el último intento si se agotan.
    private func build(_ make: () -> (EquationInput, [Fraction])) -> EquationExercise {
        var last = make()
        for _ in 0..<40 {
            last = make()
            if last.0.coefficients.allSatisfy({ abs($0) <= Double(coefficientLimit) }) {
                return EquationExercise(input: last.0, roots: last.1)
            }
        }
        return EquationExercise(input: last.0, roots: last.1)
    }

    // Expande el producto de factores (aᵢ·x + bᵢ) a coeficientes enteros en orden descendente, con coeficiente líder dado.
    private func expandFactors(_ factors: [(Int, Int)], leading: Int = 1) -> [Int] {
        var coefficients = [leading]
        for (a, b) in factors {
            var next = [Int](repeating: 0, count: coefficients.count + 1)
            for i in coefficients.indices {
                next[i] += a * coefficients[i]
                next[i + 1] += b * coefficients[i]
            }
            coefficients = next
        }
        return coefficients
    }

    private func nonZeroRoot(in range: ClosedRange<Int>) -> Int {
        var r = random.int(in: range)
        while r == 0 { r = random.int(in: range) }
        return r
    }

    // ~20% con una raíz repetida ({r,r,…}); el resto, todas distintas.
    private func polynomialRoots(count: Int) -> [Int] {
        if random.int(in: 0...99) < 20 {
            let base = distinctIntegerRoots(count: count - 1)
            return [base[0]] + base
        }
        return distinctIntegerRoots(count: count)
    }

    private func distinctIntegerRoots(count: Int) -> [Int] {
        var roots: [Int] = []
        while roots.count < count {
            let r = random.int(in: -5...5)
            if !roots.contains(r) { roots.append(r) }
        }
        return roots
    }

    private func distinctSorted(_ values: [Fraction]) -> [Fraction] {
        var seen = Set<Fraction>()
        var result: [Fraction] = []
        for value in values where seen.insert(value).inserted { result.append(value) }
        return result.sorted { $0.doubleValue < $1.doubleValue }
    }
}
