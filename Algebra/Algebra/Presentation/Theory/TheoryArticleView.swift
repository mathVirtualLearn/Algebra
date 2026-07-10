import SwiftUI

struct TheoryArticleView: View {
    @State private var viewModel: TheoryArticleViewModel

    init(viewModel: TheoryArticleViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(navigationTitleText)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
            }
    }

    private var navigationTitleText: String {
        if case .loaded(let article) = viewModel.state {
            return article.title
        }
        return String(localized: "Teoría")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let article):
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    ForEach(article.blocks) { block in
                        blockView(block)
                    }
                }
                .padding(Spacing.m)
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
        case .notFound:
            ContentUnavailableView("Artículo no encontrado", systemImage: "book")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    @ViewBuilder
    private func blockView(_ block: TheoryBlockState) -> some View {
        switch block {
        case .heading(_, let text):
            Text(text)
                .font(.title3)
                .bold()
                .foregroundStyle(AppColor.textPrimary)
                .padding(.top, Spacing.xs)
        case .paragraph(_, let text):
            Text(text)
                .font(.body)
                .foregroundStyle(AppColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        case .formula(_, let latex):
            MathView(
                latex: latex,
                fontSize: 20,
                color: UIColor(AppColor.textPrimary)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        case .bullet(_, let items):
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: Spacing.xs) {
                        Text("•")
                            .foregroundStyle(AppColor.textSecondary)
                        Text(item)
                            .font(.body)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        case .ruffini(_, let tableau):
            RuffiniTableView(tableau: tableau)
                .fitToWidth()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
