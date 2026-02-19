import XCTest
@testable import OneMinuteColorCore

final class ShortcutLinkBuilderTests: XCTestCase {
    func testRunShortcutURLBuildsExpectedSchemeAndPath() {
        let url = ShortcutLinkBuilder.runShortcutURL(shortcutName: "One Minute Color")
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }

        XCTAssertEqual(url?.scheme, "shortcuts")
        XCTAssertEqual(url?.host, "run-shortcut")
        XCTAssertEqual(components?.queryItems?.first?.name, "name")
        XCTAssertEqual(components?.queryItems?.first?.value, "One Minute Color")
    }

    func testRunShortcutURLReturnsNilForEmptyName() {
        XCTAssertNil(ShortcutLinkBuilder.runShortcutURL(shortcutName: ""))
        XCTAssertNil(ShortcutLinkBuilder.runShortcutURL(shortcutName: "   \n"))
    }

    func testRunShortcutURLEncodesSpecialCharacters() {
        let url = ShortcutLinkBuilder.runShortcutURL(shortcutName: "Color & Focus")
        XCTAssertEqual(url?.absoluteString, "shortcuts://run-shortcut?name=Color%20%26%20Focus")
    }

    func testRunShortcutCallbackURLBuildsCallbackParameters() {
        let url = ShortcutLinkBuilder.runShortcutCallbackURL(
            shortcutName: "One Minute Color",
            callbackURLScheme: "oneminutecolor"
        )
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        let items = components?.queryItems ?? []

        XCTAssertEqual(url?.scheme, "shortcuts")
        XCTAssertEqual(url?.host, "x-callback-url")
        XCTAssertEqual(components?.path, "/run-shortcut")
        XCTAssertEqual(items.first(where: { $0.name == "name" })?.value, "One Minute Color")
        XCTAssertEqual(items.first(where: { $0.name == "x-success" })?.value, "oneminutecolor://shortcut/success")
        XCTAssertEqual(items.first(where: { $0.name == "x-cancel" })?.value, "oneminutecolor://shortcut/cancel")
        XCTAssertEqual(items.first(where: { $0.name == "x-error" })?.value, "oneminutecolor://shortcut/error")
    }

    func testRunShortcutCallbackURLRejectsInvalidCallbackScheme() {
        XCTAssertNil(
            ShortcutLinkBuilder.runShortcutCallbackURL(
                shortcutName: "One Minute Color",
                callbackURLScheme: "not a scheme"
            )
        )
    }

    func testInstallShortcutURLAcceptsHTTPAndHTTPS() {
        let httpsURL = ShortcutLinkBuilder.installShortcutURL(from: "https://www.icloud.com/shortcuts/abc")
        let httpURL = ShortcutLinkBuilder.installShortcutURL(from: "http://example.com/shortcuts/abc")

        XCTAssertEqual(httpsURL?.absoluteString, "https://www.icloud.com/shortcuts/abc")
        XCTAssertEqual(httpURL?.absoluteString, "http://example.com/shortcuts/abc")
    }

    func testInstallShortcutURLRejectsInvalidValues() {
        XCTAssertNil(ShortcutLinkBuilder.installShortcutURL(from: "shortcuts://run-shortcut?name=One%20Minute%20Color"))
        XCTAssertNil(ShortcutLinkBuilder.installShortcutURL(from: "not-a-url"))
        XCTAssertNil(ShortcutLinkBuilder.installShortcutURL(from: "https:///missing-host"))
    }
}
