import Charts
import SwiftUI

struct FunctionsView: View {
    @State private var viewModel: FunctionsViewModel

    init(viewModel: FunctionsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                functionCard(viewModel: viewModel)
                PrimaryButton(title: "Representar") {
                    hideKeyboard()
                    viewModel.plotTapped()
                }
                if let message = viewModel.inputError {
                    errorCard(message)
                }
                if let plot = viewModel.plot {
                    plotCard(plot)
                }
            }
            .padding(Spacing.m)
        }
        .scrollContentBackground(.hidden)
        .background(AppColor.background.ignoresSafeArea())
        .navigationTitle("Funciones")
    }

    @ViewBuilder
    private func functionCard(viewModel: FunctionsViewModel) -> some View {
        @Bindable var viewModel = viewModel
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Función")
                    .font(.headline)
                    .foregroundStyle(AppColor.textPrimary)

                HStack(spacing: Spacing.xs) {
                    Text("y =")
                        .foregroundStyle(AppColor.textSecondary)
                    TextField("p. ej. 2cos(3x)", text: $viewModel.expressionText)
                        .foregroundStyle(AppColor.textPrimary)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .padding(Spacing.s)
                        .frame(maxWidth: .infinity)
                        .background(AppColor.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel(Text("Función f de x"))
                }

                Text("Usa x, + − * / ^, sin, cos, tan, ln, log, sqrt, abs, pi, e")
                    .font(.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    @ViewBuilder
    private func errorCard(_ message: String) -> some View {
        Card {
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private func plotCard(_ plot: FunctionPlotState) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Spacing.s) {
                MathView(
                    latex: plot.functionLatex,
                    fontSize: 22,
                    color: UIColor(AppColor.textPrimary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                Chart(plot.points) { point in
                    LineMark(
                        x: .value("x", point.x),
                        y: .value("y", point.y)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColor.accent)
                }
                .chartXScale(domain: plot.xMin...plot.xMax)
                .chartYScale(domain: plot.yMin...plot.yMax)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppColor.border)
                        AxisTick().foregroundStyle(AppColor.border)
                        AxisValueLabel().foregroundStyle(AppColor.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppColor.border)
                        AxisTick().foregroundStyle(AppColor.border)
                        AxisValueLabel().foregroundStyle(AppColor.textSecondary)
                    }
                }
                .frame(height: 260)
                .accessibilityLabel(Text("Gráfica de la función"))
            }
        }
    }
}

#Preview {
    NavigationStack {
        FunctionsView(
            viewModel: FunctionsViewModel(
                parse: ParseFunctionUseCaseImpl(),
                sample: SampleFunctionUseCaseImpl(),
                mapper: FunctionUIMapperImpl()
            )
        )
    }
}
