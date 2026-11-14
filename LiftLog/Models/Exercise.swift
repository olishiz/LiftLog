import Foundation
import SwiftData

@Model
final class Exercise {
    var name: String
    var position: Int
    var workout: Workout?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet] = []

    init(name: String, position: Int) {
        self.name = name
        self.position = position
    }

    var orderedSets: [WorkoutSet] {
        sets.sorted { $0.position < $1.position }
    }

    var volume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }

    /// Logs a set. Returns `nil` unless the weight is a finite, non-negative
    /// number and reps is at least one.
    @discardableResult
    func addSet(weight: Double, reps: Int) -> WorkoutSet? {
        guard weight.isFinite, weight >= 0, reps > 0 else { return nil }
        let nextPosition = (sets.map(\.position).max() ?? -1) + 1
        let set = WorkoutSet(weight: weight, reps: reps, position: nextPosition)
        sets.append(set)
        return set
    }

    func removeSet(_ set: WorkoutSet) {
        sets.removeAll { $0.persistentModelID == set.persistentModelID }
        modelContext?.delete(set)
    }
}
