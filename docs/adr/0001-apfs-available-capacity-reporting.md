# APFS Available Capacity Reporting

We use `URLResourceKey.volumeAvailableCapacityForImportantUsageKey` rather than POSIX `statvfs` or `volumeAvailableCapacityKey` to calculate available disk space. On modern macOS APFS filesystems, purgeable assets (APFS snapshots, system caches, evictable cloud data) are treated as available space by Finder and System Settings. Querying raw unallocated blocks underreports usable capacity significantly, creating user confusion and false alerts.
