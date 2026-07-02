protocol TheoryUIMapper: Sendable {
    func mapList(_ articles: [TheoryArticle]) -> [TheoryListItemState]
    func mapArticle(_ article: TheoryArticle) -> TheoryArticleState
}

struct TheoryUIMapperImpl: TheoryUIMapper {
    func mapList(_ articles: [TheoryArticle]) -> [TheoryListItemState] {
        articles.map { article in
            TheoryListItemState(
                id: article.id,
                title: article.title,
                summary: article.summary
            )
        }
    }

    func mapArticle(_ article: TheoryArticle) -> TheoryArticleState {
        let blocks = article.blocks.enumerated().map { index, block in
            mapBlock(block, id: index)
        }
        return TheoryArticleState(title: article.title, blocks: blocks)
    }

    private func mapBlock(_ block: TheoryBlock, id: Int) -> TheoryBlockState {
        switch block {
        case let .heading(text):
            return .heading(id: id, text)
        case let .paragraph(text):
            return .paragraph(id: id, text)
        case let .formula(latex):
            return .formula(id: id, latex)
        case let .bullet(items):
            return .bullet(id: id, items)
        }
    }
}
