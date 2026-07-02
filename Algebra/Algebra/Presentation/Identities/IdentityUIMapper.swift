import Foundation

protocol IdentityUIMapper: Sendable {
    func map(input: IdentityInput, result: IdentityResult) -> IdentityExpansionState
}

struct IdentityUIMapperImpl: IdentityUIMapper {
    func map(input: IdentityInput, result: IdentityResult) -> IdentityExpansionState {
        IdentityExpansionState(
            identityLatex: identityLatex(for: input.identity),
            developmentLatex: developmentLatex(for: input, result: result),
            summary: summary(for: input, result: result)
        )
    }

    private func identityLatex(for identity: NotableIdentity) -> String {
        switch identity {
        case .squareSum:
            return "(a + b)^2 = a^2 + 2ab + b^2"
        case .squareDifference:
            return "(a - b)^2 = a^2 - 2ab + b^2"
        case .sumByDifference:
            return "(a + b)(a - b) = a^2 - b^2"
        }
    }

    private func developmentLatex(for input: IdentityInput, result: IdentityResult) -> String {
        let a = input.a.latex()
        let b = input.b.latex()
        let binomial: String
        let substituted: String

        switch input.identity {
        case .squareSum:
            binomial = "(\(a) + \(b))^2"
            substituted = "(\(a))^2 + 2(\(a))(\(b)) + (\(b))^2"
        case .squareDifference:
            binomial = "(\(a) - \(b))^2"
            substituted = "(\(a))^2 - 2(\(a))(\(b)) + (\(b))^2"
        case .sumByDifference:
            binomial = "(\(a) + \(b))(\(a) - \(b))"
            substituted = "(\(a))^2 - (\(b))^2"
        }

        let grouped = polynomialLatex(result.terms)
        return "\(binomial) = \(substituted) = \(grouped)"
    }

    private func polynomialLatex(_ terms: [Monomial]) -> String {
        guard let first = terms.first else { return "0" }
        var output = first.latex()
        for term in terms.dropFirst() {
            if term.coefficient < 0 {
                let positive = Monomial(coefficient: -term.coefficient, variables: term.variables)
                output += " - \(positive.latex())"
            } else {
                output += " + \(term.latex())"
            }
        }
        return output
    }

    private func summary(for input: IdentityInput, result: IdentityResult) -> String {
        let name: String
        switch input.identity {
        case .squareSum:
            name = String(localized: "Cuadrado de la suma")
        case .squareDifference:
            name = String(localized: "Cuadrado de la diferencia")
        case .sumByDifference:
            name = String(localized: "Suma por diferencia")
        }
        let a = input.a.latex()
        let b = input.b.latex()
        let development = polynomialLatex(result.terms)
        return String(
            localized: "\(name) con a = \(a) y b = \(b): el desarrollo es \(development)."
        )
    }
}
