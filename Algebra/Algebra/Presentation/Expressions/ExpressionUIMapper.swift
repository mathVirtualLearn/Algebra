protocol ExpressionUIMapper: Sendable {
    func map(_ expression: Expression) -> ExpressionRowState
}

struct ExpressionUIMapperImpl: ExpressionUIMapper {
    func map(_ expression: Expression) -> ExpressionRowState {
        ExpressionRowState(
            id: expression.id,
            title: expression.title,
            latex: expression.latex,
            accessibilityLabel: expression.title
        )
    }
}
