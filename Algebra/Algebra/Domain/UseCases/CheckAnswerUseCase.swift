import Foundation

protocol CheckEquationAnswerUseCase {
    func execute(answer: String, roots: [Fraction]) -> Bool
}

protocol CheckSystemAnswerUseCase {
    func execute(answers: [String], solution: [Fraction]) -> Bool
}

struct CheckEquationAnswerUseCaseImpl: CheckEquationAnswerUseCase {
    // Corrige la respuesta parseando cada token como fracción y comparando como conjunto con las raíces.
    func execute(answer: String, roots: [Fraction]) -> Bool {
        let tokens = answer
            .split(whereSeparator: { $0 == "," || $0 == " " })
            .map(String.init)
            .filter { !$0.isEmpty }
        guard !tokens.isEmpty else { return false }
        var values: Set<Fraction> = []
        for token in tokens {
            guard let value = Fraction(parsing: token) else { return false }
            values.insert(value)
        }
        return values == Set(roots)
    }
}

struct CheckSystemAnswerUseCaseImpl: CheckSystemAnswerUseCase {
    // Corrige el sistema parseando cada incógnita como fracción y comparando en orden con la solución.
    func execute(answers: [String], solution: [Fraction]) -> Bool {
        guard answers.count == solution.count else { return false }
        for index in solution.indices {
            guard let value = Fraction(parsing: answers[index]), value == solution[index] else { return false }
        }
        return true
    }
}
