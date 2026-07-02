import SwiftUI

struct TheoryListView: View {
    @State private var viewModel: TheoryListViewModel

    init(viewModel: TheoryListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Teoría")
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.load()
                    }
                }
                .navigationDestination(for: String.self) { id in
                    TheoryFactory.makeArticle(id: id)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let items):
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    ForEach(items) { item in
                        NavigationLink(value: item.id) {
                            articleRow(item)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Spacing.m)
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background.ignoresSafeArea())
        case .empty:
            ContentUnavailableView("No hay teoría", systemImage: "book")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }

    @ViewBuilder
    private func articleRow(_ item: TheoryListItemState) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text(item.summary)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
