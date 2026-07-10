import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.s),
        GridItem(.flexible(), spacing: Spacing.s),
    ]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Aprende")
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.load()
                    }
                }
                .navigationDestination(for: TopicRoute.self) { route in
                    switch route.id {
                    case "equations":
                        EquationsFactory.make()
                    case "identities":
                        IdentitiesFactory.make()
                    case "systems":
                        SystemsFactory.make()
                    case "functions":
                        FunctionsFactory.make()
                    case "practice":
                        PracticeFactory.make()
                    case "worksheet":
                        WorksheetFactory.make()
                    default:
                        ExpressionsFactory.make(topicId: route.id, title: route.title)
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .loaded(let cards):
            ScrollView {
                LazyVGrid(columns: columns, spacing: Spacing.s) {
                    ForEach(cards) { card in
                        NavigationLink(value: TopicRoute(id: card.id, title: card.title)) {
                            TopicCard(
                                title: card.title,
                                subtitle: card.subtitle,
                                systemImage: card.systemImage
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Spacing.s)
            }
        case .empty:
            ContentUnavailableView("No hay temas", systemImage: "tray")
        case .error(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        }
    }
}

private struct TopicCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    private enum ViewTraits {
        static let minHeight: CGFloat = 120
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: ViewTraits.minHeight, alignment: .leading)
        .padding(Spacing.s)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Radius.m))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(subtitle))
    }
}
