# 05: External Physical Volume Detection

**What to build:** Detection and presentation of connected external storage drives (external SSDs, hard drives, USB thumb drives) in the dropdown menu. External Physical Volumes are listed with their names, total capacity, and available space. The volume scanner explicitly filters out Virtual Mounts (such as attached `.dmg` disk images, recovery partitions, and internal APFS snapshot mounts) to keep the list clean and actionable.

**Blocked by:** 04 (Dropdown Menu Breakdown & Quick Actions)

**Status:** ready-for-agent

- [ ] Mounted external Physical Volumes are detected and enumerated in a designated section of the dropdown menu
- [ ] Each external volume displays its name, total capacity, and available storage
- [ ] Virtual Mounts (`.dmg` files, snapshot partitions, virtual disk devices) are excluded from the volume list
- [ ] Volume enumeration and filtering logic is validated against mock mount sets in unit tests
