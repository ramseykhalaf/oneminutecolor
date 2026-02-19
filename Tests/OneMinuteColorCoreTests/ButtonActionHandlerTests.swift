import XCTest
@testable import OneMinuteColorCore

final class ButtonActionHandlerTests: XCTestCase {
    func testInstallShortcutButtonTapOpensInstallURL() {
        let handler = ButtonActionHandler(configuration: .appDefault)
        var openedURL: URL?

        let returnedURL = handler.installShortcutButtonTapped { url in
            openedURL = url
        }

        XCTAssertEqual(returnedURL?.absoluteString, ShortcutConfiguration.appDefault.shortcutInstallURLString)
        XCTAssertEqual(openedURL?.absoluteString, ShortcutConfiguration.appDefault.shortcutInstallURLString)
    }

    func testInstallShortcutButtonTapDoesNotOpenWhenInstallURLIsInvalid() {
        let handler = ButtonActionHandler(
            configuration: ShortcutConfiguration(
                shortcutName: "One Minute Color",
                shortcutInstallURLString: "shortcuts://run-shortcut?name=One%20Minute%20Color"
            )
        )
        var openCallCount = 0

        let returnedURL = handler.installShortcutButtonTapped { _ in
            openCallCount += 1
        }

        XCTAssertNil(returnedURL)
        XCTAssertEqual(openCallCount, 0)
    }

    func testStartOneMinuteColorButtonTapOpensRunShortcutURL() {
        let handler = ButtonActionHandler(configuration: .appDefault)
        var openedURL: URL?

        let returnedURL = handler.startOneMinuteColorButtonTapped { url in
            openedURL = url
        }

        XCTAssertEqual(returnedURL?.absoluteString, "shortcuts://run-shortcut?name=One%20Minute%20Color")
        XCTAssertEqual(openedURL?.absoluteString, "shortcuts://run-shortcut?name=One%20Minute%20Color")
    }

    func testStartOneMinuteColorButtonTapDoesNotOpenWhenShortcutNameIsInvalid() {
        let handler = ButtonActionHandler(
            configuration: ShortcutConfiguration(
                shortcutName: "   ",
                shortcutInstallURLString: ShortcutConfiguration.appDefault.shortcutInstallURLString
            )
        )
        var openCallCount = 0

        let returnedURL = handler.startOneMinuteColorButtonTapped { _ in
            openCallCount += 1
        }

        XCTAssertNil(returnedURL)
        XCTAssertEqual(openCallCount, 0)
    }
}
