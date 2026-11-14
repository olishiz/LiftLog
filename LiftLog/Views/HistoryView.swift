import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Workout> { $0.finishedAt != nil }, sort: \Workout.date, order: .reverse)
    private var workouts: [Workout]

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView(
                        "No Past Workouts",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Finished workouts show up here.")
                    )
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink(value: workout) {
                                HistoryRow(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkouts)
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(workouts[index])
            }
        }
    }
}

private struct HistoryRow: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.date, format: .dateTime.weekday(.wide).month().day().year())
                .font(.headline)
            Text("^[\(workout.exercises.count) exercise](inflect: true) · ^[\(workout.setCount) set](inflect: true)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(workout.totalVolume.kilogramsText)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Workout.self, inMemory: true)
}
