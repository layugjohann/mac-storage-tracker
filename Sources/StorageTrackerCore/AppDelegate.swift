import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public private(set) var menuController: StatusBarMenuController?
    private let activationConfigurable: AppActivationPolicyConfigurable
    private let statusBar: NSStatusBar
    private let terminator: () -> Void

    public init(
        activationConfigurable: AppActivationPolicyConfigurable = NSApplication.shared,
        statusBar: NSStatusBar = .system,
        terminator: @escaping () -> Void = { NSApplication.shared.terminate(nil) }
    ) {
        self.activationConfigurable = activationConfigurable
        self.statusBar = statusBar
        self.terminator = terminator
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        AppConfiguration.applyActivationPolicy(to: activationConfigurable)
        let controller = StatusBarMenuController(terminator: terminator)
        controller.attach(to: statusBar)
        self.menuController = controller
    }
}
