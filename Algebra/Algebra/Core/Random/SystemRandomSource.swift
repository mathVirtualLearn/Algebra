import Foundation

final class SystemRandomSource: RandomSource {
    func int(in range: ClosedRange<Int>) -> Int { Int.random(in: range) }
}
