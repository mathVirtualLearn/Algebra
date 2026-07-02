protocol ExpandIdentityUseCase: Sendable {
    func execute(_ input: IdentityInput) -> IdentityResult
}

struct ExpandIdentityUseCaseImpl: ExpandIdentityUseCase {
    // Desarrolla la identidad notable como suma de monomios y agrupa los términos semejantes.
    func execute(_ input: IdentityInput) -> IdentityResult {
        let a = input.a
        let b = input.b
        let two = Monomial(coefficient: 2)

        let expanded: [Monomial]
        switch input.identity {
        case .squareSum:
            expanded = [a.squared, two * a * b, b.squared]
        case .squareDifference:
            expanded = [a.squared, -(two * a * b), b.squared]
        case .sumByDifference:
            expanded = [a.squared, -(b.squared)]
        }

        return IdentityResult(terms: group(expanded))
    }

    // Agrupa monomios semejantes sumando sus coeficientes por la signatura de variables.
    private func group(_ terms: [Monomial]) -> [Monomial] {
        var orderedSignatures: [[String: Int]] = []
        var sums: [Int] = []
        var indexBySignature: [[String: Int]: Int] = [:]

        for term in terms {
            let signature = term.signature
            if let existing = indexBySignature[signature] {
                sums[existing] += term.coefficient
            } else {
                indexBySignature[signature] = orderedSignatures.count
                orderedSignatures.append(signature)
                sums.append(term.coefficient)
            }
        }

        var grouped: [Monomial] = []
        for (index, signature) in orderedSignatures.enumerated() {
            let monomial = Monomial(coefficient: sums[index], variables: signature)
            if !monomial.isZero {
                grouped.append(monomial)
            }
        }
        return grouped
    }
}
