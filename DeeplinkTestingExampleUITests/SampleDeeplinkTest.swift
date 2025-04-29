import XCTest

// Sample for pasting and testing opening of deeplink
final class SampleDeeplinkTest: XCTestCase {
    private let deeplinksHTML = """
    <html>
        <body>
            <h1>
                <a href='testdeeplink://showSettings'>Show settings</a>
                <a href='testdeeplink://showVersion'>Show version</a>
                <a href='https://josshad.glatop.com/app/showSettings'>Universal</a>
            </h1>
        </body>
    </html>
    """

    override class func setUp() {
        super.setUp()
        XCUIApplication().terminate()
        XCUIApplication().launch()
    }

    func testDeeplinks() {
        let app = XCUIApplication()
        let countText = app.staticTexts[TestIdentifier.ContentView.count]
        let urlText = app.staticTexts[TestIdentifier.ContentView.link]

        // Try to open first deeplink
        openDeeplink(with: "Show settings")

        XCTAssertTrue(countText.waitForExistence(timeout: 5))
        XCTAssertEqual(countText.label, "1")
        XCTAssertTrue(urlText.exists)
        XCTAssertEqual(urlText.label, "testdeeplink://showSettings")

        // Try to open second deeplink
        openDeeplink(with: "Show version")

        XCTAssertTrue(countText.waitForExistence(timeout: 5))
        XCTAssertEqual(countText.label, "2")
        XCTAssertTrue(urlText.exists)
        XCTAssertEqual(urlText.label, "testdeeplink://showVersion")
    }

    private func openDeeplink(with deeplinkName: String) {
        // 1. Create provider for html
        let fileName = "MyLinks"
        let provider = NSItemProvider()
        guard let htmlData = deeplinksHTML.data(using: .utf8) else { return }
        provider.registerDataRepresentation(forTypeIdentifier: "public.html", visibility: .all) { block in
            block(htmlData, nil)
            return nil
        }
        provider.suggestedName = "\(fileName).html"
        UIPasteboard.general.setItemProviders([provider], localOnly: true, expirationDate: nil)

        // 2. Open files app
        let files = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        files.terminate()
        files.launch()
        XCTAssertTrue(files.waitForExistence(timeout: 5))

        // 3. Close any document if it opened
        let doneButton = files.navigationBars.buttons["Done"].firstMatch
        let fileIsOpened = files.navigationBars[fileName].exists

        if doneButton.exists {
            if fileIsOpened {
                tapOnDeeplink(with: deeplinkName, in: files)
                return
            } else{
                doneButton.tap()
            }
        }

        // 4. Open "On my iPhone" folder
        let homeFolderName = "On My iPhone"
        if !files.navigationBars.staticTexts[homeFolderName].exists {
            files.tabBars.buttons[homeFolderName].doubleTap()
            files.cells.staticTexts[homeFolderName].tap()
            XCTAssertTrue(files.navigationBars.staticTexts[homeFolderName].waitForExistence(timeout: 5))
        }

        // 5. Create file if needed
        let fileElement = files.collectionViews.firstMatch.cells["\(fileName), html"].firstMatch
        if !fileElement.exists {
            files.collectionViews.firstMatch
                .press(forDuration: 1.3)
            let pasteButton = files.buttons["Paste"].firstMatch
            XCTAssertTrue(pasteButton.waitForExistence(timeout: 5))
            pasteButton.tap()

            // 6. Wait for file to appear in Files.app
            let fileElement = files.collectionViews.firstMatch.cells["\(fileName), html"].firstMatch
            XCTAssertTrue(fileElement.waitForExistence(timeout: 5))
        }

        // 7. Wait for file to open
        fileElement.tap()
        XCTAssertTrue(files.navigationBars[fileName].waitForExistence(timeout: 5))

        tapOnDeeplink(with: deeplinkName, in: files)
    }

    private func tapOnDeeplink(with deeplinkName: String, in files: XCUIApplication) {
        // 8. Find and tap on our deeplink from html
        let link = files.staticTexts[deeplinkName].firstMatch
        link.tap()

        // 9. Tap open on alert
        let alert = files.alerts.firstMatch
        XCTAssertTrue(files.waitForExistence(timeout: 5))
        alert.buttons["Open"].tap()

        // 10. Wait for our app to start
        let app = XCUIApplication() // Our application
        XCTAssertTrue(app.waitForExistence(timeout: 5))
    }
}
