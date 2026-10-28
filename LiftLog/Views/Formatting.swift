import Foundation

extension Double {
    /// A kilogram amount such as "62.5 kg" or "4,250 kg".
    var kilogramsText: String {
        "\(formatted(.number.precision(.fractionLength(0...2)))) kg"
    }
}
