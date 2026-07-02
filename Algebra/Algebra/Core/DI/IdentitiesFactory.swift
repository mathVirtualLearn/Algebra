@MainActor
enum IdentitiesFactory {
    static func make() -> IdentitiesView {
        let viewModel = IdentitiesViewModel(
            expand: ExpandIdentityUseCaseImpl(),
            mapper: IdentityUIMapperImpl()
        )
        return IdentitiesView(viewModel: viewModel)
    }
}
