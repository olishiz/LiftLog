import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Workout> { $0.finishedAt == nil }, sort: \Workout.date, order: .reverse)
    private var activeWorkouts: [Workout]

    var body: some View {
        NavigationStack {
            if let workout = activeWorkouts.first {
                WorkoutEditor(workout: workout)
            } else {
                ContentUnavailableView {
                    Label("Ready to Lift?", systemImage: "dumbbell")
                } description: {
                    Text("Start a workout to log your exercises and sets.")
                } actions: {
                    Button("Start Workout") {
                        modelContext.insert(Workout())
                    }
                    .buttonStyle(.borderedProminent)
                }
                .navigationTitle("Today")
            }
        }
    }
}

private struct WorkoutEditor: View {
    let workout: Workout

    @State private var isAddingExercise = false
    @State private var newExerciseName = ""
    @State private var isConfirmingFinish = false
    @State private var exerciseForNewSet: Exercise?

    var body: some View {
        content
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Finish") { isConfirmingFinish = true }
                        .disabled(workout.setCount == 0)
                }
            }
            .confirmationDialog("Finish this workout?", isPresented: $isConfirmingFinish, titleVisibility: .visible) {
                Button("Finish Workout") { workout.finish() }
            } message: {
                Text("It will move to History and you can start a fresh one.")
            }
            .alert("New Exercise", isPresented: $isAddingExercise) {
                TextField("e.g. Bench Press", text: $newExerciseName)
                    .textInputAutocapitalization(.words)
                Button("Add") {
                    withAnimation { _ = workout.addExercise(named: newExerciseName) }
                    newExerciseName = ""
                }
                Button("Cancel", role: .cancel) { newExerciseName = "" }
            }
            .sheet(item: $exerciseForNewSet) { exercise in
                AddSetSheet(exercise: exercise)
            }
    }

    @ViewBuilder
    private var content: some View {
        if workout.exercises.isEmpty {
            ContentUnavailableView {
                Label("No Exercises Yet", systemImage: "list.bullet.clipboard")
            } description: {
                Text("Add your first exercise, then log each set as you go.")
            } actions: {
                Button("Add Exercise") { isAddingExercise = true }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            List {
                if workout.setCount > 0 {
                    Section {
                        LabeledContent("Total Volume", value: workout.totalVolume.kilogramsText)
                        LabeledContent("Sets", value: workout.setCount, format: .number)
                    }
                }
                ForEach(workout.orderedExercises) { exercise in
                    ExerciseSection(
                        exercise: exercise,
                        onAddSet: { exerciseForNewSet = exercise },
                        onRemove: { withAnimation { workout.removeExercise(exercise) } }
                    )
                }
                Section {
                    Button { isAddingExercise = true } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
        }
    }

    private var title: String {
        if Calendar.current.isDateInToday(workout.date) {
            return String(localized: "Today")
        }
        return workout.date.formatted(.dateTime.weekday(.abbreviated).month().day())
    }
}

private struct ExerciseSection: View {
    let exercise: Exercise
    let onAddSet: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Section {
            ForEach(Array(exercise.orderedSets.enumerated()), id: \.element.id) { index, set in
                SetRow(number: index + 1, set: set)
            }
            .onDelete(perform: deleteSets)
            Button(action: onAddSet) {
                Label("Add Set", systemImage: "plus.circle.fill")
            }
        } header: {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Menu {
                    Button("Remove Exercise", systemImage: "trash", role: .destructive, action: onRemove)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
                .accessibilityLabel("Options for \(exercise.name)")
            }
            .textCase(nil)
        } footer: {
            if !exercise.sets.isEmpty {
                Text("Volume: \(exercise.volume.kilogramsText)")
            }
        }
    }

    private func deleteSets(at offsets: IndexSet) {
        let sets = exercise.orderedSets
        withAnimation {
            for index in offsets {
                exercise.removeSet(sets[index])
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Workout.self, inMemory: true)
}
