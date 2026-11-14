import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        List {
            Section {
                LabeledContent("Total Volume", value: workout.totalVolume.kilogramsText)
                LabeledContent("Exercises", value: workout.exercises.count, format: .number)
                LabeledContent("Sets", value: workout.setCount, format: .number)
            }
            ForEach(workout.orderedExercises) { exercise in
                Section {
                    if exercise.sets.isEmpty {
                        Text("No sets logged")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(exercise.orderedSets.enumerated()), id: \.element.id) { index, set in
                        SetRow(number: index + 1, set: set)
                    }
                } header: {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                } footer: {
                    if !exercise.sets.isEmpty {
                        Text("Volume: \(exercise.volume.kilogramsText)")
                    }
                }
            }
        }
        .navigationTitle(workout.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }
}
