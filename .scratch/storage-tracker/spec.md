# Spec: Mac Storage Tracker

Status: ready-for-agent

## Problem Statement

MacBook users often struggle to maintain awareness of their remaining disk space until macOS suddenly warns them that disk space is critically full. While macOS provides a detailed storage breakdown deep within System Settings, accessing it requires multiple clicks, and Finder's status reporting can be inconsistent with actual purgeable cache behavior. Users lack a persistent, lightweight, at-a-glance indicator in their menu bar that accurately reports usable storage capacity without consuming meaningful system resources or cluttering the macOS Dock.

## Solution

A native, lightweight macOS **Accessory App** that lives in the macOS menu bar as a **Status Item**. It continuously displays real-time **Available Storage** for the primary **Boot Volume**, factoring in **Purgeable Space** to match Finder and System Settings. Clicking the **Status Item** reveals a structured dropdown with a visual capacity gauge, detailed breakdowns (raw unallocated vs purgeable space), mounted **Physical Volumes** (such as external SSDs or USB drives), and quick access to system storage tools and launch-at-login settings.

## User Stories

1. As a MacBook user, I want to see remaining Available Storage directly in my menu bar, so that I always know how much usable space is left at a glance without opening System Settings.
2. As a MacBook user with a camera notch, I want the Status Item to have a compact footprint, so that it does not crowd out other essential menu bar items.
3. As a MacBook user, I want the displayed capacity to reflect APFS purgeable space as available, so that the number matches macOS Finder and System Settings rather than underreporting usable disk space.
4. As a MacBook user, I want to click the Status Item to open a detailed breakdown, so that I can see the distinction between raw unallocated disk space and reclaimable Purgeable Space.
5. As a MacBook user, I want to view a visual capacity progress bar in the dropdown, so that I can intuitively gauge the proportion of used versus available capacity on my Boot Volume.
6. As a MacBook user with external SSDs or USB drives attached, I want to see those Physical Volumes listed in the dropdown with their available storage, so that I can monitor external drives from the same interface.
7. As a MacBook user, I want virtual disk images (.dmg), recovery volumes, and APFS snapshot mounts automatically filtered out of the dropdown, so that my volume list remains clean and free of system noise.
8. As a MacBook user, I want the Status Item to visually shift to a warning state when my Available Storage drops below the Warning Threshold (15% or 10 GB), so that I am alerted before running out of space without intrusive notification popups.
9. As a MacBook user, I want to toggle the menu bar display format between available capacity (e.g. `142 GB`), percent free (`28% Free`), and percent used (`72% Used`), so that I can view the metric that best suits my mental model.
10. As a MacBook user, I want storage statistics to update automatically when the system wakes from sleep or when volumes are mounted or unmounted, so that the display remains accurate across system transitions.
11. As a MacBook user, I want a "Refresh Now" action in the dropdown, so that I can immediately force a fresh volume query after deleting large files.
12. As a MacBook user, I want a direct shortcut to "Open Storage Settings..." in the dropdown, so that I can jump straight to macOS System Settings to manage or optimize storage.
13. As a MacBook user, I want a "Launch at Login" toggle in the dropdown, so that the application automatically starts when I reboot without manual configuration.
14. As a MacBook user, I want the application to run as an Accessory App without a Dock icon, so that it operates unobtrusively in the background without polluting the Command-Tab application switcher.
15. As a MacBook user, I want a clean "Quit" action in the dropdown, so that I can exit the application whenever desired.
16. As a battery-conscious laptop user, I want background polling to run at a low frequency (60 seconds) without polling while the machine sleeps, so that energy consumption is negligible.

## Implementation Decisions

- **Application Architecture**: Built as a native Swift executable package running an AppKit application lifecycle configured with `LSUIElement = 1` (Accessory App).
- **Core Presentation & Domain Engine (`StorageMonitorEngine`)**:
  - Encapsulates all domain calculations, volume filtering, warning threshold evaluations, and formatting options behind an injectable `VolumeProvider` interface.
  - Maintains state for current active display format (Available GB, Percent Free, Percent Used).
  - Evaluates whether the primary Boot Volume is below the Warning Threshold (less than 15% available ratio or less than 10 GB available bytes).
- **Storage Querying & Volume Provider**:
  - In production, queries volume resources via `URLResourceValues` on the root URL (`/`) and mounted URLs from `FileManager.mountedVolumeURLs(includingResourceValuesForKeys:options:)`.
  - Conforms to ADR 0001: specifically requests `volumeAvailableCapacityForImportantUsageKey` to retrieve Available Storage inclusive of purgeable assets, alongside `volumeTotalCapacityKey` and `volumeAvailableCapacityKey` (to derive Purgeable Space).
  - Classifies volumes into Physical Volumes vs Virtual Mounts by checking filesystem type, read-only attributes, and internal device properties, excluding `.dmg` attachments and APFS container snapshots.
- **Event-Driven Update Cycle**:
  - Subscribes to `NSWorkspace.didWakeNotification` and `NSWorkspace.didMountNotification` / `didUnmountNotification` for instant reactive updates.
  - Schedules a non-repeating or low-frequency (60-second) timer on `RunLoop.main` while active, pausing during system sleep.
  - Triggers an immediate volume refresh whenever the user clicks the Status Item menu.
- **Menu Bar Presentation Layer**:
  - Uses `NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)`.
  - Updates `button.title` and `button.image` with SF Symbols (e.g. `internaldrive`, `exclamationmark.triangle`).
  - Sets warning tint/state when the engine indicates Warning Threshold is breached.
- **Dropdown Menu Structure**:
  - Header: Boot Volume name, total size, visual ASCII/text or custom view progress bar.
  - Capacity detail: Available Storage with subtitle showing Raw Free + Purgeable Space.
  - External Physical Volumes: Listed with name, total capacity, and available storage.
  - Formatting submenu: Radio items to toggle between Available Size, Percent Free, and Percent Used.
  - Utility items: "Refresh Now", "Open Storage Settings...", "Launch at Login" (bound to `SMAppService.mainApp`), separator, and "Quit".

## Testing Decisions

- **Good Test Criteria**: Tests must verify external behavior through public engine interfaces—asserting accurate calculations, proper filtering of virtual mounts, threshold state transitions, and formatted strings—never internal implementation details or private properties.
- **Primary Testing Seam**: All business logic will be exercised through `StorageMonitorEngine` by providing a mock `VolumeProvider`.
- **Targeted Test Scenarios**:
  - Correct calculation of Available Storage, raw free, and purgeable bytes across typical volume snapshots.
  - Boundary checks for the Warning Threshold (e.g. exactly at 15%, 15.01%, 14.99%, under 10 GB).
  - Correct filtering logic verifying that physical external SSDs are included while `.dmg` mounts and snapshot volumes are excluded.
  - String formatting validation across various capacities (megabytes, gigabytes, terabytes, percentages).
  - State management for display format toggle preferences.
- **Prior Art / Test Stack**: Standard Swift Package Manager `swift-testing` / `XCTest` suite run via `swift test`.

## Out of Scope

- Active disk cleaning, temporary file deletion, or cache purging (read-only monitoring only).
- Deep filesystem directory tree scanning to identify large files or calculate folder sizes.
- Native macOS push notifications / notification banner alerts on low disk space (restricted to status item visual indicator in V1).
- Cloud storage quota monitoring (iCloud Drive, Google Drive, Dropbox quotas).
- Multiple persistent Status Items for secondary drives (external drives live exclusively in the dropdown).

## Further Notes

- Target deployment: macOS 13.0+ (Ventura or later) to leverage modern `SMAppService` and APFS capacity resource keys.
- Project should build and run cleanly via command line: `swift build` and `swift test`.
