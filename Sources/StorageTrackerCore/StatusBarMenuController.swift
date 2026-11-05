import AppKit

public extension NSStatusBarButton {
    func configureStorageTrackerIcon() {
        let image = NSImage(systemSymbolName: "internaldrive", accessibilityDescription: "Storage Tracker")
        image?.isTemplate = true
        self.image = image
    }
}

public class StatusBarMenuController: NSObject {
    public static let defaultTerminator: () -> Void = { NSApplication.shared.terminate(nil) }

    public let menu: NSMenu
    public private(set) var statusItem: NSStatusItem?
    private let terminator: () -> Void

    public init(terminator: @escaping () -> Void = StatusBarMenuController.defaultTerminator) {
        self.terminator = terminator
        self.menu = NSMenu(title: "Storage Tracker")
        super.init()
        setupMenu()
    }

    private func setupMenu() {
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitAction(_:)),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @discardableResult
    public func attach(to statusBar: NSStatusBar = .system) -> NSStatusItem {
        let item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.configureStorageTrackerIcon()
        item.menu = menu
        self.statusItem = item
        return item
    }

    @objc public func quitAction(_ sender: Any?) {
        terminator()
    }
}
