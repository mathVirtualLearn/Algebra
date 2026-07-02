import Testing
@testable import Algebra

struct ExpressionUIMapperImplTests {
    @Test
    func test_whenMap_thenCopyPrimitives() {

        let entity = ExpressionBuilder()
            .with(id: "e")
            .with(latex: "x^2")
            .with(title: "Cuadrado")
            .build()
        let sut = ExpressionUIMapperImpl()

        let row = sut.map(entity)

        #expect(row.id == "e")
        #expect(row.latex == "x^2")
        #expect(row.title == "Cuadrado")
        #expect(row.accessibilityLabel == "Cuadrado")
    }
}
