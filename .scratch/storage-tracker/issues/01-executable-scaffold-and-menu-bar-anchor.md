# 01: Executable Scaffold & Menu Bar Anchor

**What to build:** A lightweight native macOS accessory application that launches silently into the menu bar without appearing in the Dock or application switcher. The user sees a placeholder Status Item in the menu bar which, when clicked, provides a basic menu with a working "Quit" action to terminate the application. The project is fully testable and buildable from the command line.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Swift package builds and runs cleanly via `swift run`
- [ ] Application runs as an Accessory App (`LSUIElement = 1`) without displaying a Dock icon or main window
- [ ] A Status Item appears in the macOS menu bar upon launch with a minimalist monochrome vector disk icon (matching SF Symbol `internaldrive` style validated in prototype Variant A)
- [ ] Clicking the Status Item opens a menu containing a "Quit" option that terminates the process cleanly
- [ ] Automated test suite runs and passes via `swift test`

## Prototype Finding
Validated via prototype ([`prototype-menu-icon.html`](file:///Users/antonlayug/Desktop/Mac%20storage%20tracker/.scratch/storage-tracker/prototype-menu-icon.html)): Status Item uses Apple-native minimalist vector drive icon (`internaldrive` style) beside the compact capacity readout.
