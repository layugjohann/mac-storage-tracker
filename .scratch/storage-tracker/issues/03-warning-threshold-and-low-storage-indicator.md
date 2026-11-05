# 03: Warning Threshold & Low Storage State Indicator

**What to build:** Visual alerting on the Status Item when Available Storage reaches critically low levels. When remaining capacity falls below the Warning Threshold (less than 15% available ratio or less than 10 GB remaining), the Status Item visually transitions to a warning state (e.g., warning symbol or color accent), alerting the user non-intrusively without modal popups or banner notifications.

**Blocked by:** 02 (Available Storage Engine & APFS Capacity Tracking)

**Status:** ready-for-agent

- [ ] Engine accurately detects when storage is below the Warning Threshold (< 15% available or < 10 GB available)
- [ ] Status Item displays a warning indicator (e.g. warning icon/tint) when the threshold is breached
- [ ] Status Item reverts to normal appearance when storage rises back above the threshold
- [ ] Boundary conditions (e.g. exactly 15%, 14.9%, 15.1%, < 10 GB) are thoroughly validated via unit tests
