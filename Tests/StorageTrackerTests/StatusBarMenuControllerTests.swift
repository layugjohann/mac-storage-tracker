import XCTest
import AppKit
@testable import StorageTrackerCore

final class StatusBarMenuControllerTests: XCTestCase {
    func testStatusBarButtonConfigurationUsesInternalDriveSymbolAndTemplateMode() {
        let controller = StatusBarMenuController()
        let button = NSStatusBarButton(frame: .zero)
        
        controller.configureButton(button)
        
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
        let quitItem = menu.items.first { $0.title.contains("Quit") }
        
        XCTAssertNotNil(quitItem, "Menu must contain a Quit item")
        XCTAssertEqual(quitItem?.title, "Quit Storage Tracker")
        XCTAssertEqual(quitItem?.keyEquivalent, "q", "Quit item should use standard 'q' key equivalent")
        XCTAssertEqual(quitItem?.target as? StatusBarMenuController, controller, "Quit item target must be the controller")
        XCTAssertEqual(quitItem?.action, #selector(StatusBarMenuController.quitAction(_:)), "Quit item action must point to quitAction")
        
        // Trigger the quit action directly
        controller.quitAction(quitItem)
        XCTAssertTrue(quitCalled, "Invoking quit action must terminate cleanly via the terminator closure")
    }
    
    func testAppConfiguresAccessoryPolicy() {
        let recorder = MockActivationPolicyRecorder()
        AppConfiguration.applyActivationPolicy(to: recorder)
        
        XCTAssertEqual(recorder.recordedPolicy, .accessory, "App must configure activation policy as .accessory to hide dock icon")
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

    func testAppDelegateConfiguresActivationPolicyAndCreatesMenuController() {
        let recorder = MockActivationPolicyRecorder()
        var quitInvoked = false
        let delegate = AppDelegate(
            activationConfigurable: recorder,
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

        XCTAssertEqual(recorder.recordedPolicy, .accessory)
        XCTAssertNotNil(delegate.menuController)
        XCTAssertNotNil(delegate.menuController?.statusItem)
        XCTAssertEqual(delegate.menuController?.statusItem?.menu, delegate.menuController?.menu)

        // Verify quit action from the attached menu
        let quitItem = delegate.menuController?.menu.items.first { $0.title.contains("Quit") }
        XCTAssertNotNil(quitItem)
        delegate.menuController?.quitAction(quitItem)
        XCTAssertTrue(quitInvoked)
    }
}

final class MockActivationPolicyRecorder: AppActivationPolicyConfigurable {
    var recordedPolicy: NSApplication.ActivationPolicy?
    
    func setActivationPolicy(_ policy: NSApplication.ActivationPolicy) -> Bool {
        self.recordedPolicy = policy
        return true
    }
}
