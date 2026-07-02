import Foundation

protocol ParseFunctionUseCase: Sendable {

    func execute(_ text: String) -> FunctionExpr?
}

struct ParseFunctionUseCaseImpl: ParseFunctionUseCase {

    // Convierte el texto en un FunctionExpr: preprocesa, tokeniza y parsea por descenso recursivo.
    func execute(_ text: String) -> FunctionExpr? {
        let normalized = preprocess(text)
        guard !normalized.isEmpty else { return nil }
        guard let tokens = Tokenizer.tokenize(normalized), !tokens.isEmpty else { return nil }

        var parser = Parser(tokens: tokens)
        guard let expression = parser.parseExpression() else { return nil }
        guard parser.isAtEnd else { return nil }
        return expression
    }

    private func preprocess(_ text: String) -> String {
        var string = text.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        if string.hasPrefix("f(x)=") {
            string.removeFirst("f(x)=".count)
        } else if string.hasPrefix("y=") {
            string.removeFirst("y=".count)
        }
        return string
    }
}

private enum Token: Equatable {
    case number(Double)
    case identifier(String)
    case plus, minus, star, slash, caret, lparen, rparen
}

private enum Tokenizer {

    private static let names = ["sqrt", "sin", "cos", "tan", "log", "exp", "abs", "ln", "pi", "x", "e"]

    // Analizador léxico: convierte la cadena en tokens (números, identificadores y operadores).
    static func tokenize(_ string: String) -> [Token]? {
        var tokens: [Token] = []
        let chars = Array(string)
        var index = 0
        while index < chars.count {
            let char = chars[index]
            if char.isNumber || char == "." {
                var literal = ""
                while index < chars.count, chars[index].isNumber || chars[index] == "." {
                    literal.append(chars[index])
                    index += 1
                }
                guard let value = Double(literal) else { return nil }
                tokens.append(.number(value))
            } else if char.isLetter {
                var run = ""
                while index < chars.count, chars[index].isLetter {
                    run.append(chars[index])
                    index += 1
                }
                guard let split = splitLetters(run) else { return nil }
                tokens.append(contentsOf: split)
            } else {
                switch char {
                case "+": tokens.append(.plus)
                case "-": tokens.append(.minus)
                case "*": tokens.append(.star)
                case "/": tokens.append(.slash)
                case "^": tokens.append(.caret)
                case "(": tokens.append(.lparen)
                case ")": tokens.append(.rparen)
                default: return nil
                }
                index += 1
            }
        }
        return tokens
    }

    private static func splitLetters(_ run: String) -> [Token]? {
        var tokens: [Token] = []
        var rest = Substring(run)
        outer: while !rest.isEmpty {
            for name in names where rest.hasPrefix(name) {
                switch name {
                case "pi": tokens.append(.number(Double.pi))
                case "e": tokens.append(.number(M_E))
                default: tokens.append(.identifier(name))
                }
                rest = rest.dropFirst(name.count)
                continue outer
            }
            return nil
        }
        return tokens
    }
}

private struct Parser {
    private let tokens: [Token]
    private var position = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    var isAtEnd: Bool { position >= tokens.count }
    private var current: Token? { position < tokens.count ? tokens[position] : nil }
    private mutating func advance() { position += 1 }

    // Descenso recursivo, nivel suma/resta (menor precedencia).
    mutating func parseExpression() -> FunctionExpr? {
        guard var node = parseTerm() else { return nil }
        while let token = current, token == .plus || token == .minus {
            advance()
            guard let rhs = parseTerm() else { return nil }
            node = token == .plus ? .add(node, rhs) : .sub(node, rhs)
        }
        return node
    }

    // Descenso recursivo, nivel producto/división (incluye el producto implícito).
    private mutating func parseTerm() -> FunctionExpr? {
        guard var node = parsePower() else { return nil }
        while true {
            if let token = current, token == .star || token == .slash {
                advance()
                guard let rhs = parsePower() else { return nil }
                node = token == .star ? .mul(node, rhs) : .div(node, rhs)
            } else if startsFactor {
                guard let rhs = parsePower() else { return nil }
                node = .mul(node, rhs)
            } else {
                break
            }
        }
        return node
    }

    // Descenso recursivo, nivel potencia (asociativa por la derecha).
    private mutating func parsePower() -> FunctionExpr? {
        guard let base = parseUnary() else { return nil }
        guard current == .caret else { return base }
        advance()
        guard let exponent = parsePower() else { return nil }
        return .pow(base, exponent)
    }

    private mutating func parseUnary() -> FunctionExpr? {
        if current == .minus {
            advance()
            guard let operand = parseUnary() else { return nil }
            return .neg(operand)
        }
        if current == .plus {
            advance()
            return parseUnary()
        }
        return parsePrimary()
    }

    // Descenso recursivo, nivel átomo: número, paréntesis, variable x o llamada a función.
    private mutating func parsePrimary() -> FunctionExpr? {
        switch current {
        case .number(let value):
            advance()
            return .constant(value)
        case .lparen:
            advance()
            guard let inner = parseExpression() else { return nil }
            guard current == .rparen else { return nil }
            advance()
            return inner
        case .identifier(let name):
            advance()
            if name == "x" { return .variable }
            guard let function = FunctionExpr.Func(rawValue: name) else { return nil }
            return parseFunctionArgument(function)
        default:
            return nil
        }
    }

    private mutating func parseFunctionArgument(_ function: FunctionExpr.Func) -> FunctionExpr? {
        if current == .lparen {
            advance()
            guard let inner = parseExpression() else { return nil }
            guard current == .rparen else { return nil }
            advance()
            return .call(function, inner)
        }
        guard var argument = parsePrimary() else { return nil }
        while startsFactor {
            guard let next = parsePrimary() else { return nil }
            argument = .mul(argument, next)
        }
        return .call(function, argument)
    }

    private var startsFactor: Bool {
        switch current {
        case .number, .identifier, .lparen: return true
        default: return false
        }
    }
}
