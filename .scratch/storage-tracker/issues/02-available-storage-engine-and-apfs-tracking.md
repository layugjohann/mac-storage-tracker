# 02: Available Storage Engine & APFS Capacity Tracking

**What to build:** The core storage monitoring engine that queries the primary Boot Volume and computes real-time Available Storage inclusive of APFS Purgeable Space, conforming to ADR 0001. The Status Item in the menu bar displays the actual formatted available capacity (e.g., `142 GB`). The engine is decoupled from AppKit via an injectable volume provider interface to allow 100% deterministic test coverage.

**Blocked by:** 01 (Executable Scaffold & Menu Bar Anchor)

**Status:** ready-for-agent

- [ ] Storage engine queries volume capacity using `volumeAvailableCapacityForImportantUsageKey` to capture Available Storage matching Finder and System Settings
- [ ] Purgeable Space is derived and tracked alongside raw unallocated disk capacity
- [ ] Status Item in the menu bar reflects the computed Available Storage formatted with appropriate units (GB/TB)
- [ ] Core calculation and formatting logic is covered by unit tests using a mock volume provider
