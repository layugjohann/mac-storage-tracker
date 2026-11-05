import AppKit

public protocol AppActivationPolicyConfigurable: AnyObject {
    @discardableResult
    func setActivationPolicy(_ policy: NSApplication.ActivationPolicy) -> Bool
}

extension NSApplication: AppActivationPolicyConfigurable {}

public enum AppConfiguration {
    public static func applyActivationPolicy(to app: AppActivationPolicyConfigurable = NSApplication.shared) {
        app.setActivationPolicy(.accessory)
    }
}

public class StatusBarMenuController: NSObject {
    public let menu: NSMenu
    public private(set) var statusItem: NSStatusItem?
    private let terminator: () -> Void

    public init(terminator: @escaping () -> Void = { NSApplication.shared.terminate(nil) }) {
        self.terminator = terminator
        self.menu = NSMenu(title: "Storage Tracker")
        super.init()
        setupMenu()
    }

    private func setupMenu() {
        let quitItem = NSMenuItem(
            title: "Quit Storage Tracker",
            action: #selector(quitAction(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    public func configureButton(_ button: NSStatusBarButton) {
        let image = NSImage(systemSymbolName: "internaldrive", accessibilityDescription: "Storage Tracker")
        image?.isTemplate = true
        button.image = image
    }

    @discardableResult
    public func attach(to statusBar: NSStatusBar = .system) -> NSStatusItem {
        let item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            configureButton(button)
        }
        item.menu = menu
        self.statusItem = item
        return item
    }

    @objc public func quitAction(_ sender: Any?) {
        terminator()
    }
}
