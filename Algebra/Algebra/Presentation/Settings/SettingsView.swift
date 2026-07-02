import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            List {
                Section("Aplicación") {
                    LabeledContent("Nombre", value: viewModel.appName)
                    LabeledContent("Versión", value: viewModel.version)
                }
                Section("Preferencias") {
                    Picker("Tamaño de fórmulas", selection: $viewModel.formulaSize) {
                        Text("Pequeño").tag(FormulaSize.small)
                        Text("Mediano").tag(FormulaSize.medium)
                        Text("Grande").tag(FormulaSize.large)
                    }
                    .pickerStyle(.segmented)

                    MathView(
                        latex: "x = \\displaystyle\\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}",
                        fontSize: 22
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel("Vista previa del tamaño de fórmulas")

                    Toggle("Mostrar pasos detallados", isOn: $viewModel.showDetailedSteps)
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
