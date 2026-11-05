# Mac Storage Tracker

A lightweight, native macOS menu bar utility that monitors and displays system storage capacity and availability in real time.

## Language

**Available Storage**:
Total storage space that can be allocated for new data, comprising raw unallocated capacity plus APFS purgeable space.
_Avoid_: Free space, unallocated space

**Purgeable Space**:
Storage space occupied by temporary caches, system assets, and APFS snapshots that macOS automatically reclaims when additional disk space is required.
_Avoid_: Junk, temporary files, trash

**Status Item**:
The persistent visual indicator resident in the macOS menu bar displaying real-time storage metrics and the detail dropdown.
_Avoid_: System tray icon, widget, dock icon

**Boot Volume**:
The primary startup volume containing the operating system and user home directories, designated as the default target for the menu bar display.
_Avoid_: System disk, hard drive, main drive

**External Volume**:
Any mounted non-boot storage device (such as external SSDs or USB flash drives) listed in the detail dropdown.
_Avoid_: Secondary disk, thumb drive

**Warning Threshold**:
A predefined limit (15% capacity or 10 GB available) that triggers a visual state change in the status item.
_Avoid_: Low disk alert, red zone

**Physical Volume**:
A genuine internal or external storage drive mounted on the system, distinct from synthetic or virtual disk images.
_Avoid_: Mount, drive, disk image

**Virtual Mount**:
A filesystem mount originating from a disk image (`.dmg`), container snapshot, or recovery partition, excluded from user-facing volume lists.
_Avoid_: DMG, snapshot partition, loop device

**Accessory App**:
A macOS application configured with `LSUIElement = true` that runs without a Dock icon or application switcher presence.
_Avoid_: Background process, daemon, agent
