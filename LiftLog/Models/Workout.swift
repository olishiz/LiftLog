import Foundation
import SwiftData

@Model
final class Workout {
    var date: Date
    var finishedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \Exercise.workout)
    var exercises: [Exercise] = []

    init(date: Date = .now) {
        self.date = date
    }

    var isFinished: Bool { finishedAt != nil }

    var orderedExercises: [Exercise] {
        exercises.sorted { $0.position < $1.position }
    }

    var setCount: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }

    /// Sum of weight × reps across every set, in kilograms.
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.volume }
    }

    /// Adds an exercise with a trimmed name. Returns `nil` for blank names.
    @discardableResult
    func addExercise(named name: String) -> Exercise? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let nextPosition = (exercises.map(\.position).max() ?? -1) + 1
        let exercise = Exercise(name: trimmed, position: nextPosition)
        exercises.append(exercise)
        return exercise
    }

    func removeExercise(_ exercise: Exercise) {
        exercises.removeAll { $0.persistentModelID == exercise.persistentModelID }
        modelContext?.delete(exercise)
    }

    func finish(at date: Date = .now) {
        finishedAt = date
    }
}
