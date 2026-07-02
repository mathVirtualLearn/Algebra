import SwiftUI

struct ExpressionsListView: View {
    @State private var viewModel: ExpressionsViewModel
    private let title: String

    init(viewModel: ExpressionsViewModel, title: String) {
        _viewModel = State(initialValue: viewModel)
        self.title = title
    }

    var body: some View {
        content
            .navigationTitle(title)
            .task {
                if case .idle = viewModel.state {
                    await viewModel.load()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let rows):
            List(rows) { row in
                ExpressionRow(
                    title: row.title,
                    latex: row.latex,
                    accessibilityLabel: row.accessibilityLabel
                )
            }
        case .empty:
            ContentUnavailableView("Aún no hay fórmulas en este tema", systemImage: "function")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}

private struct ExpressionRow: View {
    let title: String
    let latex: String
    let accessibilityLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.headline)
            MathView(latex: latex, fontSize: 22, accessibilityLabelText: accessibilityLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Spacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}
