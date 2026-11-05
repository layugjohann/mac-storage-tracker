# 01: Executable Scaffold & Menu Bar Anchor

**What to build:** A lightweight native macOS accessory application that launches silently into the menu bar without appearing in the Dock or application switcher. The user sees a placeholder Status Item in the menu bar which, when clicked, provides a basic menu with a working "Quit" action to terminate the application. The project is fully testable and buildable from the command line.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] Swift package builds and runs cleanly via `swift run`
- [x] Application runs as an Accessory App (`LSUIElement = 1`) without displaying a Dock icon or main window
- [x] A Status Item appears in the macOS menu bar upon launch with a minimalist monochrome vector disk icon (matching SF Symbol `internaldrive` style validated in prototype Variant A)
- [x] Clicking the Status Item opens a menu containing a "Quit" option that terminates the process cleanly
- [x] Automated test suite runs and passes via `swift test`

## Prototype Finding
Validated via prototype ([`prototype-menu-icon.html`](file:///Users/antonlayug/Desktop/Mac%20storage%20tracker/.scratch/storage-tracker/prototype-menu-icon.html)): Status Item uses Apple-native minimalist vector drive icon (`internaldrive` style) beside the compact capacity readout.

## Resolution Notes
- Initialized SPM package structure (`Package.swift`, `Sources/StorageTrackerCore`, `Sources/StorageTrackerApp`, and `Tests/StorageTrackerTests`) targeting macOS 13+.
- Followed strict TDD workflow:
  - Phase 1 (RED): Created `StatusBarMenuControllerTests` testing activation policy configuration (`.accessory`), button image configuration (`internaldrive`, template mode, accessibility description), and dropdown menu with working "Quit" action. Confirmed tests failed as expected.
  - Phase 2 (GREEN): Implemented `AppConfiguration`, `StatusBarMenuController`, and `AppDelegate` in `StorageTrackerCore` with decoupled dependencies (`AppActivationPolicyConfigurable`, custom terminator).
  - Phase 3 (REFACTOR & VERIFY): Extended test coverage to lifecycle events in `AppDelegate`, validated 0 warnings on compilation with `-warnings-as-errors`, verified test suite passes via `swift test` (5/5 tests passing), and verified clean process execution and termination via `swift run storage-tracker`.
