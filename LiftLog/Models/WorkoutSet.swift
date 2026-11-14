import Foundation
import SwiftData

@Model
final class WorkoutSet {
    /// Weight in kilograms.
    var weight: Double
    var reps: Int
    var position: Int
    var exercise: Exercise?

    init(weight: Double, reps: Int, position: Int) {
        self.weight = weight
        self.reps = reps
        self.position = position
    }

    var volume: Double {
        weight * Double(reps)
    }

    /// Parses user-entered weight using the locale's decimal separator.
    static func parseWeight(_ text: String, locale: Locale = .current) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let strategy = FloatingPointFormatStyle<Double>(locale: locale).parseStrategy
        guard let value = try? strategy.parse(trimmed), value.isFinite, value >= 0 else {
            return nil
        }
        return value
    }
}
