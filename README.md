# LiftLog

A tiny SwiftUI workout logger: add exercises, log sets, see past sessions.

- **Today** shows your current workout. Add exercises by name, then log sets (weight in kg + reps) under each one. Swipe a set to delete it; remove an exercise from its section's **⋯** menu. Tap **Finish** when you're done.
- **History** lists finished workouts by date with exercise and set counts and total volume (weight × reps). Tap one to see every set; swipe to delete.
- Everything is stored on-device with SwiftData. No network, no accounts, no third-party dependencies.

Requirements: Xcode 15 or newer, iOS 17.0+.

## Run in the Simulator (Mac)

1. `git clone <this repo>` and `cd` into it.
2. Open `LiftLog.xcodeproj` in Xcode.
3. Choose the **LiftLog** scheme and any iPhone simulator (e.g. iPhone 15) in the toolbar.
4. Press **Cmd+R** to run. **Cmd+U** runs the unit tests.

From the command line:

```sh
xcodebuild -scheme LiftLog -destination 'platform=iOS Simulator,name=iPhone 15' build test
```

## Run on your iPhone

1. Select the **LiftLog** project in Xcode, then the **LiftLog** target > **Signing & Capabilities**.
2. Under **Team**, pick your **Personal Team** (sign in with your Apple ID under Xcode > Settings > Accounts if needed). Signing is automatic.
3. If Xcode reports the bundle identifier is unavailable, change `com.olishiz.liftlog` to something unique, e.g. `com.yourname.liftlog`.
4. Plug in your iPhone, unlock it, tap **Trust** if asked, and select it as the run destination.
5. Press **Cmd+R**.
6. The first time, iOS blocks the app: open **Settings > General > VPN & Device Management**, tap your developer certificate, and choose **Trust**.
7. If prompted, enable **Developer Mode** (Settings > Privacy & Security > Developer Mode) and restart the phone.

Apps signed with a free Personal Team expire after **7 days**; just run from Xcode again to reinstall. Your data survives the reinstall.

## Regenerating the Xcode project (optional)

`LiftLog.xcodeproj` is committed, so you don't need XcodeGen. If you change `project.yml`:

```sh
brew install xcodegen
xcodegen generate
```

## Project layout

```
LiftLog/
  LiftLogApp.swift        App entry point and SwiftData container
  Models/                 Workout, Exercise, WorkoutSet (SwiftData models + logic)
  Views/                  Today, History, workout detail, add-set sheet
  Assets.xcassets         App icon and accent color
LiftLogTests/             XCTest unit tests for the model logic
project.yml               XcodeGen spec
```
