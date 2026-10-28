import SwiftUI

struct SetRow: View {
    let number: Int
    let set: WorkoutSet

    var body: some View {
        HStack {
            Text("Set \(number)")
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(set.weight.kilogramsText) × \(set.reps)")
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Set \(number), \(set.weight.kilogramsText), \(set.reps) reps")
    }
}
