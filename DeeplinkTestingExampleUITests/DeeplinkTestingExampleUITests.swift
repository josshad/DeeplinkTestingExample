//
//  DeeplinkTestingUITests.swift
//  DeeplinkTestingUITests
//
//  Created by Danila Gusev on 14.04.2025.
//

import XCTest
import DeeplinkTestHelper

final class DeeplinkTestHelperTests: XCTestCase {
    private enum Const {
        static let htmlFileName = "MyDeeplinks"
        static let htmlFolderName = "_Deeplinks_"

        static let urlFileName = "URLDeeplinks"
        static let urlFolderName = "_URLDeeplinks_"
    }

    private let deeplinksHTML = """
    <html>
    <body>
        <br/>
        <h1>
            \(
                [TestLink.universalSettings, .universalPremium, .schemeSettings, .schemePremium]
                    .map(\.htmlLink)
                    .joined(separator: "</br>")
             )
        </h1>
        <br/>
    </body>
    </html>
    """

    override func setUp() {
        super.setUp()

        XCUIApplication().terminate()
        XCUIApplication().launch()
    }

    // MARK: - HTML string
    // !!!: Scheme
    func testHTMLString_WorksWithSchemeLinks_WithoutFolder() {
        configureWithHTMLAndOpen([.schemeSettings, .schemePremium], folder: false)
    }

    func testHTMLString_WorksWithSchemeLinks_WithFolder() {
        configureWithHTMLAndOpen([.schemeSettings, .schemePremium], folder: true)
    }

    // !!!: Universal
    func testHTMLString_WorksWithUniversalLinks_WithoutFolder() {
        configureWithHTMLAndOpen([.universalPremium, .universalSettings], folder: false)
    }

    func testHTMLString_WorksWithUniversalLinks_WithFolder() {
        configureWithHTMLAndOpen([.universalPremium, .universalSettings], folder: true)
    }

    // MARK: - Bundle HTML file
    // !!!: Scheme
    func testFile_WorksWithSchemeLinks_WithFolder() {
        configureWithFileAndOpen([.schemeSettings, .schemePremium], folder: true)
    }
    func testFile_WorksWithSchemeLinks_WithoutFolder() {
        configureWithFileAndOpen([.schemeSettings, .schemePremium], folder: false)
    }

    // !!!: Universal
    func testFile_WorksWithUniversalLinks_WithFolder() {
        configureWithFileAndOpen([.universalPremium, .universalSettings], folder: true)
    }

    func testFile_WorksWithUniversalLinks_WithoutFolder() {
        configureWithFileAndOpen([.universalPremium, .universalSettings], folder: false)
    }
}

private extension DeeplinkTestHelperTests {
    func configureWithFileAndOpen(_ links: [TestLink], folder: Bool) {
        // Step 0.
        // Configure app
        let app = XCUIApplication()

        // Step 1.
        // Initialize helper with file url
        guard
            let url = Bundle(for: type(of: self)).url(forResource: "testDeeplinks", withExtension: "html"),
            let helper = DeeplinkTestHelper(
                fileURL: url,
                fileName: Const.urlFileName,
                folderName: folder ? Const.urlFolderName : nil
            )
        else {
            return XCTFail("Can't initialize helper")
        }

        // Step 1.1
        // Uncomment for cleanup if you change file/html content
        // cleanup(using: helper)

        // Step 1.2
        // Open links list one by one
        open(links: links, in: app, helper: helper)
    }

    func configureWithHTMLAndOpen(_ links: [TestLink], folder: Bool) {
        // Step 0.
        // Configure app
        let app = XCUIApplication()

        // Step 1.
        // Initialize helper with html text
        let helper = DeeplinkTestHelper(
            deeplinksHTML: deeplinksHTML,
            fileName: Const.htmlFileName,
            folderName: folder ? Const.htmlFolderName : nil
        )

        // Step 1.1
        // Uncomment for cleanup if you change file/html content
        // cleanup(using: helper)

        // Step 1.2
        // Open links list one by one
        open(links: links, in: app, helper: helper)
    }
}

private extension DeeplinkTestHelperTests {
    func open(links: [TestLink], in app: XCUIApplication, helper: DeeplinkTestHelper) {
        for (index, link) in links.enumerated() {
            // Step 2.
            // Try to open deeplink link
            helper.openDeeplink(withName: link.name)

            // Step 3.
            // Wait for app main screen to appear
            waitFor(app: app)

            // Step 4.
            // Check counter and link url
            let countText = app.staticTexts[TestIdentifier.ContentView.count]
            XCTAssertTrue(countText.exists)
            XCTAssertEqual(countText.label, "\(index + 1)")

            let urlText = app.staticTexts[TestIdentifier.ContentView.link]
            XCTAssertTrue(urlText.exists)
            XCTAssertEqual(urlText.label, link.url)
        }
    }

    func waitFor(app: XCUIApplication) {
        guard app.waitForExistence(timeout: 5) else {
            return XCTFail("Failed to open app by deeplink")
        }
    }

    func cleanup(using helper: DeeplinkTestHelper) {
        helper.removeElement(name: Const.htmlFileName, isFolder: false)
        helper.removeElement(name: Const.htmlFolderName, isFolder: true)
        helper.removeElement(name: Const.urlFileName, isFolder: false)
        helper.removeElement(name: Const.urlFolderName, isFolder: true)
    }
}

private struct TestLink {
    let name: String
    let url: String

    var htmlLink: String {
        "<a href=\"\(url)\">\(name)</a>"
    }

    static let universalSettings = TestLink(name: "Show settings universal", url: "https://josshad.glatop.com/app/showSettings")
    static let universalPremium = TestLink(name: "Activate premium", url: "https://josshad.glatop.com/app/activatePremium")
    static let schemeSettings = TestLink(name: "Show settings by scheme", url: "testdeeplink://showSettings")
    static let schemePremium = TestLink(name: "Activate premium by scheme", url: "testdeeplink://premium")
}

