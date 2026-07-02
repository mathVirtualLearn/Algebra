import Testing
@testable import Algebra

struct TopicUIMapperImplTests {
    @Test
    func test_whenMap_thenCopyPrimitives() {

        let entity = TopicBuilder()
            .with(id: "g")
            .with(title: "Geometría")
            .with(subtitle: "Teoremas")
            .with(systemImage: "triangle")
            .build()
        let sut = TopicUIMapperImpl()

        let card = sut.map(entity)

        #expect(card.id == "g")
        #expect(card.title == "Geometría")
        #expect(card.subtitle == "Teoremas")
        #expect(card.systemImage == "triangle")
    }
}
