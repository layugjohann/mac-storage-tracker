import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    public private(set) var menuController: StatusBarMenuController?
    private let statusBar: NSStatusBar
    private let terminator: () -> Void

    public init(
        statusBar: NSStatusBar = .system,
        terminator: @escaping () -> Void = StatusBarMenuController.defaultTerminator
    ) {
        self.statusBar = statusBar
        self.terminator = terminator
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = StatusBarMenuController(terminator: terminator)
        controller.attach(to: statusBar)
        self.menuController = controller
    }
}
