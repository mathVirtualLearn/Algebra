import SwiftUI

struct RuffiniTableView: View {
    let tableau: RuffiniTableauState

    private enum ViewTraits {
        static let lineWidth: CGFloat = 1
        static let cellMinWidth: CGFloat = 22
    }

    var body: some View {
        Grid(alignment: .trailing, horizontalSpacing: 0, verticalSpacing: 0) {

            GridRow {
                rootColumnCell(emptyRootText)
                ForEach(Array(tableau.header.enumerated()), id: \.offset) { _, value in
                    valueCell(value, color: AppColor.textPrimary)
                }
            }

            ForEach(Array(tableau.divisions.enumerated()), id: \.offset) { _, division in

                GridRow {
                    rootColumnCell(rootText(division.root))
                    ForEach(Array(division.products.enumerated()), id: \.offset) { _, value in
                        valueCell(value, color: AppColor.textSecondary)
                    }
                }

                GridRow {
                    rootColumnLineCell
                    horizontalLine
                        .gridCellColumns(tableau.header.count)
                }

                GridRow {
                    rootColumnCell(emptyRootText)
                    ForEach(Array(division.results.enumerated()), id: \.offset) { index, value in
                        valueCell(value, color: AppColor.textPrimary)
                            .overlay(alignment: .leading) {
                                if index == division.results.count - 1 {
                                    remainderSeparator
                                }
                            }
                    }
                }
            }
        }
        .padding(Spacing.xs)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("División de Ruffini"))
    }

    private func valueCell(_ value: String, color: Color) -> some View {
        Text(value)
            .font(.system(.body, design: .monospaced))
            .foregroundStyle(color)
            .frame(minWidth: ViewTraits.cellMinWidth, alignment: .trailing)
            .padding(.vertical, Spacing.xxs)
            .padding(.horizontal, Spacing.xs)
    }

    private func rootText(_ value: String) -> Text {
        Text(value)
            .font(.system(.body, design: .monospaced))
    }

    private var emptyRootText: Text {
        rootText(placeholderRoot).foregroundColor(.clear)
    }

    private func rootColumnCell(_ text: Text) -> some View {
        text
            .foregroundStyle(AppColor.mint)
            .frame(minWidth: ViewTraits.cellMinWidth, alignment: .trailing)
            .padding(.vertical, Spacing.xxs)
            .padding(.horizontal, Spacing.xs)
            .overlay(alignment: .trailing) { verticalLine }
    }

    private var rootColumnLineCell: some View {
        rootText(placeholderRoot)
            .foregroundColor(.clear)
            .frame(minWidth: ViewTraits.cellMinWidth, alignment: .trailing)
            .padding(.horizontal, Spacing.xs)
            .frame(height: ViewTraits.lineWidth)
            .overlay(alignment: .trailing) { verticalLine }
    }

    private var placeholderRoot: String {
        tableau.divisions.first?.root ?? "0"
    }

    private var verticalLine: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(width: ViewTraits.lineWidth)
            .frame(maxHeight: .infinity)
    }

    private var horizontalLine: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(height: ViewTraits.lineWidth)
            .frame(maxWidth: .infinity)
    }

    private var remainderSeparator: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(width: ViewTraits.lineWidth)
            .frame(maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        Card {
            RuffiniTableView(
                tableau: RuffiniTableauState(
                    header: ["1", "-6", "11", "-6"],
                    divisions: [
                        RuffiniTableauState.Division(
                            root: "1",
                            products: ["", "1", "-5", "6"],
                            results: ["1", "-5", "6", "0"]
                        )
                    ]
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}
