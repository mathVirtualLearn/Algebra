import Testing
@testable import Algebra

struct TheoryUIMapperImplTests {
    private let sut = TheoryUIMapperImpl()

    @Test
    func test_whenMapList_thenCopiesIdentityFields() {
        let articles = [
            TheoryArticle(id: "a", title: "TA", summary: "SA", blocks: []),
            TheoryArticle(id: "b", title: "TB", summary: "SB", blocks: [])
        ]

        let items = sut.mapList(articles)

        #expect(items == [
            TheoryListItemState(id: "a", title: "TA", summary: "SA"),
            TheoryListItemState(id: "b", title: "TB", summary: "SB")
        ])
    }

    @Test
    func test_whenMapArticle_thenBlocksGetSequentialIds() {
        let article = TheoryArticle(
            id: "x",
            title: "Título",
            summary: "S",
            blocks: [.heading("H"), .paragraph("P"), .formula("ax+b"), .bullet(["u1", "u2"])]
        )

        let state = sut.mapArticle(article)

        #expect(state.title == "Título")
        #expect(state.blocks == [
            .heading(id: 0, "H"),
            .paragraph(id: 1, "P"),
            .formula(id: 2, "ax+b"),
            .bullet(id: 3, ["u1", "u2"])
        ])
        #expect(state.blocks.map(\.id) == [0, 1, 2, 3])
    }
}
