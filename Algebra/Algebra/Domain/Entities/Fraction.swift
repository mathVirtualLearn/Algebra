import Foundation

struct Fraction: Equatable, Hashable, Sendable {
    let numerator: Int
    let denominator: Int

    init(_ n: Int, _ d: Int) {
        guard d != 0 else {
            numerator = 0
            denominator = 1
            return
        }
        var num = n
        var den = d
        if den < 0 {
            num = -num
            den = -den
        }
        let divisor = Fraction.gcd(abs(num), den)
        let safeDivisor = divisor == 0 ? 1 : divisor
        numerator = num / safeDivisor
        denominator = den / safeDivisor
    }

    init(_ n: Int) {
        numerator = n
        denominator = 1
    }

    init?(parsing text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(separator: "/", omittingEmptySubsequences: false)
        if parts.count == 1 {
            guard let n = Int(parts[0].trimmingCharacters(in: .whitespaces)) else { return nil }
            self = Fraction(n)
        } else if parts.count == 2 {
            guard let n = Int(parts[0].trimmingCharacters(in: .whitespaces)),
                  let d = Int(parts[1].trimmingCharacters(in: .whitespaces)),
                  d != 0 else { return nil }
            self = Fraction(n, d)
        } else {
            return nil
        }
    }

    // Aproxima un Double por una fracción mediante el desarrollo en fracción continua (convergentes).
    init(approximating value: Double, maxDenominator: Int = 100_000) {
        guard value.isFinite else {
            numerator = 0
            denominator = 1
            return
        }
        let rounded = value.rounded()
        if abs(value - rounded) < 1e-9, abs(rounded) < 1e15 {
            self = Fraction(Int(rounded))
            return
        }

        let sign = value < 0 ? -1 : 1
        let target = abs(value)
        var x = target
        var h0 = 0, h1 = 1
        var k0 = 1, k1 = 0
        var bestNum = 0, bestDen = 1
        var bestError = Double.greatestFiniteMagnitude

        for _ in 0..<64 {
            let a = Int(x.rounded(.down))
            let h2 = a * h1 + h0
            let k2 = a * k1 + k0
            guard k2 > 0, k2 <= maxDenominator else { break }
            let approx = Double(h2) / Double(k2)
            let error = abs(approx - target)
            if error < bestError {
                bestError = error
                bestNum = h2
                bestDen = k2
            }
            if bestError < 1e-12 { break }
            let fractionalPart = x - Double(a)
            if fractionalPart < 1e-12 { break }
            x = 1.0 / fractionalPart
            h0 = h1; h1 = h2
            k0 = k1; k1 = k2
        }

        self = Fraction(sign * bestNum, bestDen)
    }

    var isInteger: Bool { denominator == 1 }
    var isZero: Bool { numerator == 0 }
    var isNegative: Bool { numerator < 0 }

    var magnitude: Fraction { Fraction(abs(numerator), denominator) }
    var doubleValue: Double { Double(numerator) / Double(denominator) }

    static prefix func - (value: Fraction) -> Fraction {
        Fraction(-value.numerator, value.denominator)
    }

    static func + (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.denominator + rhs.numerator * lhs.denominator,
                 lhs.denominator * rhs.denominator)
    }

    static func - (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.denominator - rhs.numerator * lhs.denominator,
                 lhs.denominator * rhs.denominator)
    }

    static func * (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.numerator, lhs.denominator * rhs.denominator)
    }

    static func / (lhs: Fraction, rhs: Fraction) -> Fraction {
        Fraction(lhs.numerator * rhs.denominator, lhs.denominator * rhs.numerator)
    }

    func latex() -> String {
        if denominator == 1 { return String(numerator) }
        if numerator < 0 { return "-\\displaystyle\\frac{\(-numerator)}{\(denominator)}" }
        return "\\displaystyle\\frac{\(numerator)}{\(denominator)}"
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var x = a
        var y = b
        while y != 0 {
            (x, y) = (y, x % y)
        }
        return x
    }
}
