import SwiftUI

struct AddSetSheet: View {
    let exercise: Exercise

    @Environment(\.dismiss) private var dismiss
    @State private var weightText: String
    @State private var reps: Int
    @FocusState private var isWeightFocused: Bool

    init(exercise: Exercise) {
        self.exercise = exercise
        let lastSet = exercise.orderedSets.last
        _weightText = State(initialValue: lastSet.map { $0.weight.formatted(.number.grouping(.never)) } ?? "")
        _reps = State(initialValue: lastSet?.reps ?? 8)
    }

    private var weight: Double? {
        WorkoutSet.parseWeight(weightText)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Weight") {
                        HStack {
                            TextField("0", text: $weightText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .focused($isWeightFocused)
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $reps, in: 1...100) {
                        LabeledContent("Reps") {
                            Text(reps, format: .number)
                                .monospacedDigit()
                        }
                    }
                } footer: {
                    if let weight {
                        Text("Volume: \((weight * Double(reps)).kilogramsText)")
                    }
                }
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let weight {
                            exercise.addSet(weight: weight, reps: reps)
                        }
                        dismiss()
                    }
                    .disabled(weight == nil)
                }
            }
            .onAppear { isWeightFocused = true }
        }
        .presentationDetents([.medium, .large])
    }
}
