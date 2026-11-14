import SwiftData
import XCTest
@testable import LiftLog

final class WorkoutTests: XCTestCase {
    private lazy var container: ModelContainer = {
        do {
            return try ModelContainer(
                for: Workout.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Could not create in-memory container: \(error)")
        }
    }()

    private lazy var context = ModelContext(container)

    private func makeWorkout() -> Workout {
        let workout = Workout()
        context.insert(workout)
        return workout
    }

    func testSetVolumeIsWeightTimesReps() {
        XCTAssertEqual(WorkoutSet(weight: 62.5, reps: 8, position: 0).volume, 500)
        XCTAssertEqual(WorkoutSet(weight: 0, reps: 12, position: 0).volume, 0)
    }

    func testTotalVolumeSumsAllSetsAcrossExercises() throws {
        let workout = makeWorkout()
        let bench = try XCTUnwrap(workout.addExercise(named: "Bench Press"))
        bench.addSet(weight: 60, reps: 10)
        bench.addSet(weight: 70, reps: 8)
        let squat = try XCTUnwrap(workout.addExercise(named: "Squat"))
        squat.addSet(weight: 100, reps: 5)

        XCTAssertEqual(bench.volume, 1_160)
        XCTAssertEqual(squat.volume, 500)
        XCTAssertEqual(workout.totalVolume, 1_660)
        XCTAssertEqual(workout.setCount, 3)
    }

    func testEmptyWorkoutHasZeroVolume() {
        let workout = makeWorkout()
        XCTAssertEqual(workout.totalVolume, 0)
        XCTAssertEqual(workout.setCount, 0)
    }

    func testAddExerciseTrimsNameAndRejectsBlank() {
        let workout = makeWorkout()

        XCTAssertEqual(workout.addExercise(named: "  Deadlift \n")?.name, "Deadlift")
        XCTAssertNil(workout.addExercise(named: "   "))
        XCTAssertEqual(workout.exercises.count, 1)
    }

    func testAddSetRejectsInvalidInput() throws {
        let exercise = try XCTUnwrap(makeWorkout().addExercise(named: "Row"))

        XCTAssertNil(exercise.addSet(weight: -5, reps: 5))
        XCTAssertNil(exercise.addSet(weight: 50, reps: 0))
        XCTAssertNil(exercise.addSet(weight: .infinity, reps: 5))
        XCTAssertNotNil(exercise.addSet(weight: 0, reps: 15))
        XCTAssertEqual(exercise.sets.count, 1)
    }

    func testSetsKeepInsertionOrder() throws {
        let exercise = try XCTUnwrap(makeWorkout().addExercise(named: "Press"))
        exercise.addSet(weight: 40, reps: 10)
        exercise.addSet(weight: 45, reps: 8)
        exercise.addSet(weight: 50, reps: 6)

        XCTAssertEqual(exercise.orderedSets.map(\.weight), [40, 45, 50])
    }

    func testRemoveSetUpdatesVolumeAndKeepsOrder() throws {
        let workout = makeWorkout()
        let exercise = try XCTUnwrap(workout.addExercise(named: "Curl"))
        exercise.addSet(weight: 10, reps: 10)
        let middle = try XCTUnwrap(exercise.addSet(weight: 12, reps: 10))
        exercise.addSet(weight: 14, reps: 10)

        exercise.removeSet(middle)
        try context.save()

        XCTAssertEqual(exercise.orderedSets.map(\.weight), [10, 14])
        XCTAssertEqual(workout.totalVolume, 240)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<WorkoutSet>()), 2)
    }

    func testNewSetAfterRemovalIsAppendedLast() throws {
        let exercise = try XCTUnwrap(makeWorkout().addExercise(named: "Dip"))
        let first = try XCTUnwrap(exercise.addSet(weight: 0, reps: 12))
        exercise.addSet(weight: 10, reps: 10)
        exercise.removeSet(first)
        exercise.addSet(weight: 20, reps: 8)

        XCTAssertEqual(exercise.orderedSets.map(\.weight), [10, 20])
    }

    func testRemoveExerciseDeletesItsSets() throws {
        let workout = makeWorkout()
        let bench = try XCTUnwrap(workout.addExercise(named: "Bench Press"))
        bench.addSet(weight: 60, reps: 10)
        bench.addSet(weight: 60, reps: 10)
        let squat = try XCTUnwrap(workout.addExercise(named: "Squat"))
        squat.addSet(weight: 100, reps: 5)
        try context.save()

        workout.removeExercise(bench)
        try context.save()

        XCTAssertEqual(workout.orderedExercises.map(\.name), ["Squat"])
        XCTAssertEqual(workout.totalVolume, 500)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Exercise>()), 1)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<WorkoutSet>()), 1)
    }

    func testFinishMovesWorkoutOutOfActiveQuery() throws {
        let workout = makeWorkout()
        let active = FetchDescriptor<Workout>(predicate: #Predicate<Workout> { $0.finishedAt == nil })
        XCTAssertFalse(workout.isFinished)
        XCTAssertEqual(try context.fetchCount(active), 1)

        workout.finish()
        try context.save()

        XCTAssertTrue(workout.isFinished)
        XCTAssertEqual(try context.fetchCount(active), 0)
    }

    func testParseWeightRespectsLocale() {
        XCTAssertEqual(WorkoutSet.parseWeight("62.5", locale: Locale(identifier: "en_US")), 62.5)
        XCTAssertEqual(WorkoutSet.parseWeight("62,5", locale: Locale(identifier: "de_DE")), 62.5)
        XCTAssertEqual(WorkoutSet.parseWeight(" 80 ", locale: Locale(identifier: "en_US")), 80)
        XCTAssertNil(WorkoutSet.parseWeight("", locale: Locale(identifier: "en_US")))
        XCTAssertNil(WorkoutSet.parseWeight("-5", locale: Locale(identifier: "en_US")))
        XCTAssertNil(WorkoutSet.parseWeight("heavy", locale: Locale(identifier: "en_US")))
    }
}
