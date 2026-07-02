import Foundation

indirect enum FunctionExpr: Equatable, Sendable {
    case constant(Double)
    case variable
    case neg(FunctionExpr)
    case add(FunctionExpr, FunctionExpr)
    case sub(FunctionExpr, FunctionExpr)
    case mul(FunctionExpr, FunctionExpr)
    case div(FunctionExpr, FunctionExpr)
    case pow(FunctionExpr, FunctionExpr)
    case call(Func, FunctionExpr)

    enum Func: String, Equatable, Sendable {
        case sin, cos, tan, ln, log, exp, sqrt, abs
    }

    // Intérprete: evalúa el AST recursivamente para un valor concreto de x.
    func evaluate(_ x: Double) -> Double {
        switch self {
        case .constant(let value):
            return value
        case .variable:
            return x
        case .neg(let operand):
            return -operand.evaluate(x)
        case .add(let lhs, let rhs):
            return lhs.evaluate(x) + rhs.evaluate(x)
        case .sub(let lhs, let rhs):
            return lhs.evaluate(x) - rhs.evaluate(x)
        case .mul(let lhs, let rhs):
            return lhs.evaluate(x) * rhs.evaluate(x)
        case .div(let lhs, let rhs):
            return lhs.evaluate(x) / rhs.evaluate(x)
        case .pow(let base, let exponent):
            return Foundation.pow(base.evaluate(x), exponent.evaluate(x))
        case .call(let function, let argument):
            let value = argument.evaluate(x)
            switch function {
            case .sin: return Foundation.sin(value)
            case .cos: return Foundation.cos(value)
            case .tan: return Foundation.tan(value)
            case .ln: return Foundation.log(value)
            case .log: return Foundation.log10(value)
            case .exp: return Foundation.exp(value)
            case .sqrt: return value < 0 ? Double.nan : Foundation.sqrt(value)
            case .abs: return Swift.abs(value)
            }
        }
    }

    func latex() -> String {
        switch self {
        case .constant(let value):
            return Self.numberLatex(value)
        case .variable:
            return "x"
        case .neg(let operand):
            let inner = operand.parenthesizedLatex(minPrecedence: 2)

            if inner.hasPrefix("\\sqrt") {
                return "-\\left(\(inner)\\right)"
            }
            return "-" + inner
        case .add(let lhs, let rhs):
            return lhs.parenthesizedLatex(minPrecedence: 1) + " + " + rhs.parenthesizedLatex(minPrecedence: 1)
        case .sub(let lhs, let rhs):

            return lhs.parenthesizedLatex(minPrecedence: 1) + " - " + rhs.parenthesizedLatex(minPrecedence: 2)
        case .mul(let lhs, let rhs):
            return Self.multiplicationLatex(lhs, rhs)
        case .div(let lhs, let rhs):
            return "\\frac{\(lhs.latex())}{\(rhs.latex())}"
        case .pow(let base, let exponent):

            return "\(base.parenthesizedLatex(minPrecedence: 4))^{\(exponent.latex())}"
        case .call(let function, let argument):
            return Self.callLatex(function, argument)
        }
    }

    private var precedence: Int {
        switch self {
        case .add, .sub: return 1
        case .mul, .div, .neg: return 2
        case .pow: return 3
        case .constant, .variable, .call: return 4
        }
    }

    private func parenthesizedLatex(minPrecedence: Int) -> String {
        precedence < minPrecedence ? "\\left(\(latex())\\right)" : latex()
    }

    private static func multiplicationLatex(_ lhs: FunctionExpr, _ rhs: FunctionExpr) -> String {
        let left = lhs.parenthesizedLatex(minPrecedence: 2)
        let right = rhs.parenthesizedLatex(minPrecedence: 2)
        if let last = left.last, let first = right.first,
           last.isNumber, first.isNumber || first == "." {
            return "\(left) \\cdot \(right)"
        }
        return "\(left)\(right)"
    }

    private static func callLatex(_ function: Func, _ argument: FunctionExpr) -> String {
        let arg = argument.latex()
        switch function {
        case .sin: return "\\sin(\(arg))"
        case .cos: return "\\cos(\(arg))"
        case .tan: return "\\tan(\(arg))"
        case .ln: return "\\ln(\(arg))"
        case .log: return "\\log(\(arg))"
        case .exp: return "e^{\(arg)}"
        case .sqrt: return "\\sqrt{\(arg)}"
        case .abs: return "\\left|\(arg)\\right|"
        }
    }

    private static func numberLatex(_ value: Double) -> String {
        if value == Double.pi { return "\\pi" }
        if value == M_E { return "e" }
        if value == value.rounded(), Swift.abs(value) < 1e15 {
            return String(Int(value))
        }
        return String(format: "%g", value)
    }
}
