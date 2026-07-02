@testable import Algebra

struct ExpressionBuilder {
    private var id = "1"
    private var latex = "a^2 + b^2 = c^2"
    private var title = "Test"
    private var topicId = "equations"

    func with(id: String) -> Self { var c = self; c.id = id; return c }
    func with(latex: String) -> Self { var c = self; c.latex = latex; return c }
    func with(title: String) -> Self { var c = self; c.title = title; return c }
    func with(topicId: String) -> Self { var c = self; c.topicId = topicId; return c }

    func build() -> Expression {
        Expression(id: id, latex: latex, title: title, topicId: topicId)
    }
}
