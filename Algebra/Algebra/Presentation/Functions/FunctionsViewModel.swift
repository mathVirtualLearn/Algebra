import Foundation
import Observation

@MainActor
@Observable
final class FunctionsViewModel {

    var expressionText: String = "x^2"

    private(set) var plot: FunctionPlotState?
    private(set) var inputError: String?

    private let parse: ParseFunctionUseCase
    private let sample: SampleFunctionUseCase
    private let mapper: FunctionUIMapper

    init(parse: ParseFunctionUseCase, sample: SampleFunctionUseCase, mapper: FunctionUIMapper) {
        self.parse = parse
        self.sample = sample
        self.mapper = mapper
    }

    func plotTapped() {
        guard let expression = parse.execute(expressionText) else {
            inputError = String(localized: "No entiendo la función. Usa x, + − * / ^, sin, cos, ln, sqrt… (p. ej. 2cos(3x))")
            plot = nil
            return
        }
        let domain = -10.0...10.0
        let samples = sample.execute(expression: expression, domain: domain, count: 200)
        plot = mapper.map(expression: expression, samples: samples, domain: domain)
        inputError = nil
    }
}
