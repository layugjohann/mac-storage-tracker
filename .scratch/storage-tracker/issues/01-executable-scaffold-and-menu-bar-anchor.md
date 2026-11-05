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

## Answer
- Initialized SPM package structure (`Package.swift`, `Sources/StorageTrackerCore`, `Sources/StorageTrackerApp`, and `Tests/StorageTrackerTests`) targeting macOS 13+.
- Configured native macOS Accessory App specification with `Info.plist` containing `LSUIElement = true` embedded into Mach-O `__TEXT,__info_plist` and runtime policy `.accessory` set prior to `app.run()`.
- Implemented menu bar anchor via `StatusBarMenuController` and `NSStatusBarButton.configureStorageTrackerIcon` using SF Symbol `internaldrive` in template mode with accessibility description.
- Configured dropdown menu with canonical "Quit" action cleanly terminating process via shared terminator closure (`StatusBarMenuController.defaultTerminator`).
- Verified zero build warnings, strict TDD coverage, and clean process execution and termination via `swift test` and `swift run storage-tracker`.
