import XCTest
import AppKit
@testable import StorageTrackerCore

final class StatusBarMenuControllerTests: XCTestCase {
    func testStatusBarButtonConfigurationUsesInternalDriveSymbolAndTemplateMode() {
        let button = NSStatusBarButton(frame: .zero)
        button.configureStorageTrackerIcon()
        
        XCTAssertNotNil(button.image, "Status bar button must have an image configured")
        XCTAssertEqual(button.image?.isTemplate, true, "Image must be in template mode for monochrome rendering")
        XCTAssertEqual(button.image?.accessibilityDescription, "Storage Tracker")
    }

    func testMenuContainsWorkingQuitOption() {
        var quitCalled = false
        let controller = StatusBarMenuController(terminator: {
            quitCalled = true
        })
        
        let menu = controller.menu
        let quitItem = menu.items.first { $0.title == "Quit" }
        
        XCTAssertNotNil(quitItem, "Menu must contain a Quit item")
        XCTAssertEqual(quitItem?.title, "Quit")
        XCTAssertEqual(quitItem?.keyEquivalent, "", "Quit item should not have a key equivalent in status menu")
        XCTAssertEqual(quitItem?.target as? StatusBarMenuController, controller, "Quit item target must be the controller")
        XCTAssertEqual(quitItem?.action, #selector(StatusBarMenuController.quitAction(_:)), "Quit item action must point to quitAction")
        
        // Trigger the quit action directly
        controller.quitAction(quitItem)
        XCTAssertTrue(quitCalled, "Invoking quit action must terminate cleanly via the terminator closure")
    }

    func testAttachCreatesStatusItemWithMenuAndConfiguredButton() {
        let controller = StatusBarMenuController()
        let item = controller.attach(to: .system)
        defer {
            NSStatusBar.system.removeStatusItem(item)
        }

        XCTAssertNotNil(controller.statusItem)
        XCTAssertEqual(controller.statusItem?.menu, controller.menu)
        if let button = controller.statusItem?.button {
            XCTAssertNotNil(button.image)
            XCTAssertEqual(button.image?.isTemplate, true)
            XCTAssertEqual(button.image?.accessibilityDescription, "Storage Tracker")
        }
    }

    func testAppDelegateAttachesMenuControllerOnLaunch() {
        var quitInvoked = false
        let delegate = AppDelegate(
            statusBar: .system,
            terminator: { quitInvoked = true }
        )

        let notification = Notification(name: NSApplication.didFinishLaunchingNotification)
        delegate.applicationDidFinishLaunching(notification)
        defer {
            if let item = delegate.menuController?.statusItem {
                NSStatusBar.system.removeStatusItem(item)
            }
        }

        XCTAssertNotNil(delegate.menuController)
        XCTAssertNotNil(delegate.menuController?.statusItem)
        XCTAssertEqual(delegate.menuController?.statusItem?.menu, delegate.menuController?.menu)

        // Verify quit action from the attached menu
        let quitItem = delegate.menuController?.menu.items.first { $0.title == "Quit" }
        XCTAssertNotNil(quitItem)
        delegate.menuController?.quitAction(quitItem)
        XCTAssertTrue(quitInvoked)
    }

    func testInfoPlistConfiguresAccessoryApp() throws {
        let currentFile = URL(fileURLWithPath: #filePath)
        let packageRoot = currentFile
            .deletingLastPathComponent() // StorageTrackerTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // Root
        let infoPlistURL = packageRoot.appendingPathComponent("Sources/StorageTrackerApp/Info.plist")
        
        let data = try Data(contentsOf: infoPlistURL)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        
        XCTAssertNotNil(plist, "Info.plist must be valid property list")
        XCTAssertEqual(plist?["LSUIElement"] as? Bool, true, "LSUIElement must be true (Accessory App)")
    }
}
