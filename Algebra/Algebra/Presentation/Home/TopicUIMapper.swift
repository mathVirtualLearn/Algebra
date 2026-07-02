protocol TopicUIMapper: Sendable {
    func map(_ topic: Topic) -> TopicCardState
}

struct TopicUIMapperImpl: TopicUIMapper {
    func map(_ topic: Topic) -> TopicCardState {
        TopicCardState(
            id: topic.id,
            title: topic.title,
            subtitle: topic.subtitle,
            systemImage: topic.systemImage
        )
    }
}
