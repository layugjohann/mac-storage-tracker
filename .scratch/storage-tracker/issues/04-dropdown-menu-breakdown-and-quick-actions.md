# 04: Dropdown Menu Breakdown & Quick Actions

**What to build:** An informative dropdown menu that appears when the user clicks the Status Item. The menu shows a comprehensive breakdown of the Boot Volume: volume name, total size, a visual progress bar indicating used vs available capacity, and detailed line items for Available Storage, Raw Free Space, and Purgeable Space. It also provides immediate action items: "Refresh Now" to trigger an instant update, and "Open Storage Settings..." to jump directly to macOS System Settings.

**Blocked by:** 02 (Available Storage Engine & APFS Capacity Tracking)

**Status:** ready-for-agent

- [ ] Dropdown displays the Boot Volume name and total storage capacity
- [ ] Dropdown renders a visual capacity gauge/bar representing space distribution (Used, Purgeable, Free segments as validated in prototype Variant A)
- [ ] Dropdown presents an explicit breakdown distinguishing Raw Free Space from reclaimable Purgeable Space
- [ ] Dropdown uses monochrome vector icons (matching SF Symbols) for all line items and actions
- [ ] Selecting "Refresh Now" immediately queries volumes and updates all numbers
- [ ] Selecting "Open Storage Settings..." launches the macOS System Settings Storage panel

## Prototype Finding
Validated via prototype ([`prototype-menu-icon.html`](file:///Users/antonlayug/Desktop/Mac%20storage%20tracker/.scratch/storage-tracker/prototype-menu-icon.html)): Variant A layout selected with unified monochrome vector icons across all menu items.
