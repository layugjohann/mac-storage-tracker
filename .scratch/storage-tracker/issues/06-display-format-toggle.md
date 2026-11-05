# 06: Display Format Toggle

**What to build:** An in-menu display format selector allowing the user to customize how storage is presented in the macOS menu bar. The user can choose between Remaining Available Space (e.g., `142 GB`), Percentage Free (e.g., `28% Free`), or Percentage Used (e.g., `72% Used`). Selecting an option updates the Status Item readout immediately and saves the preference.

**Blocked by:** 04 (Dropdown Menu Breakdown & Quick Actions)

**Status:** ready-for-agent

- [ ] Dropdown menu includes format options (Available Size, Percentage Free, Percentage Used) with a checkmark indicating the active format
- [ ] Selecting a format instantly updates the Status Item title in the menu bar
- [ ] User's format selection is persisted across application launches
- [ ] Format state switching and text rendering are verified with unit tests
