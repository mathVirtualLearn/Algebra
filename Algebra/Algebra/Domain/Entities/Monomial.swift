struct Monomial: Equatable, Sendable {

    let coefficient: Int

    let variables: [String: Int]

    init(coefficient: Int, variables: [String: Int] = [:]) {
        if coefficient == 0 {
            self.coefficient = 0
            self.variables = [:]
        } else {
            self.coefficient = coefficient
            self.variables = variables.filter { $0.value != 0 }
        }
    }

    // Parsea un texto tipo "-3x^2" en un Monomial (signo, coeficiente, variable y exponente).
    static func parse(_ text: String) -> Monomial? {
        var chars = Array(text)

        while let first = chars.first, first == " " || first == "\t" { chars.removeFirst() }
        while let last = chars.last, last == " " || last == "\t" { chars.removeLast() }
        if chars.isEmpty { return Monomial(coefficient: 0) }

        let digitRange: ClosedRange<Character> = "0"..."9"
        let letterRange: ClosedRange<Character> = "a"..."z"

        var index = 0

        var sign = 1
        if chars[index] == "+" {
            index += 1
        } else if chars[index] == "-" {
            sign = -1
            index += 1
        }

        var digits = ""
        while index < chars.count, digitRange.contains(chars[index]) {
            digits.append(chars[index])
            index += 1
        }

        var variable: String?
        var exponent = 1
        if index < chars.count {
            let letter = chars[index]
            guard letterRange.contains(letter) else { return nil }
            variable = String(letter)
            index += 1
            if index < chars.count, chars[index] == "^" {
                index += 1
                var expDigits = ""
                while index < chars.count, digitRange.contains(chars[index]) {
                    expDigits.append(chars[index])
                    index += 1
                }
                guard let value = Int(expDigits) else { return nil }
                exponent = value
            }
        }

        guard index == chars.count else { return nil }
        guard !digits.isEmpty || variable != nil else { return nil }

        let base: Int
        if digits.isEmpty {
            base = 1
        } else {
            guard let value = Int(digits) else { return nil }
            base = value
        }
        let coefficient = sign * base

        if let variable {
            return Monomial(coefficient: coefficient, variables: [variable: exponent])
        }
        return Monomial(coefficient: coefficient)
    }

    static func * (lhs: Monomial, rhs: Monomial) -> Monomial {
        var combined = lhs.variables
        for (name, exp) in rhs.variables {
            combined[name, default: 0] += exp
        }
        return Monomial(coefficient: lhs.coefficient * rhs.coefficient, variables: combined)
    }

    var squared: Monomial { self * self }

    static prefix func - (m: Monomial) -> Monomial {
        Monomial(coefficient: -m.coefficient, variables: m.variables)
    }

    var isZero: Bool { coefficient == 0 }

    var signature: [String: Int] { variables }

    func latex() -> String {
        if variables.isEmpty {
            return String(coefficient)
        }

        var varsPart = ""
        for (name, exp) in variables.sorted(by: { $0.key < $1.key }) {
            varsPart += exp == 1 ? name : "\(name)^\(exp)"
        }

        switch coefficient {
        case 1:
            return varsPart
        case -1:
            return "-\(varsPart)"
        default:
            return "\(coefficient)\(varsPart)"
        }
    }
}
