# 07: Lifecycle Events & Launch at Login

**What to build:** Background lifecycle management and automatic startup. The application automatically triggers a storage refresh whenever the system wakes from sleep or when storage devices are mounted/unmounted, and maintains a gentle 60-second polling timer while awake. Additionally, the dropdown menu provides a "Launch at Login" toggle item that manages automatic startup via macOS `SMAppService.mainApp`.

**Blocked by:** 04 (Dropdown Menu Breakdown & Quick Actions)

**Status:** ready-for-agent

- [ ] Storage is refreshed automatically upon system wake (`NSWorkspace.didWakeNotification`)
- [ ] Storage is refreshed automatically when volumes are mounted or unmounted
- [ ] Low-frequency timer (60s) runs while the system is active without waking sleeping threads
- [ ] Dropdown includes a "Launch at Login" toggle that controls startup registration via `SMAppService`
- [ ] The toggle accurately reflects the current `SMAppService.mainApp.status`
