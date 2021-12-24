import XCTest
import Embassy
import EnvoyAmbassador

class BasicInteraction: UITestBase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    func testLaunch() throws {
        app.launch()
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "12.8K")).exists)
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "AskReddit")).exists)
        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "[Serious] [NSFW] What's something that a")).firstMatch.tap()
        app.buttons.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "Silent-Zebra")).tap()
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "10,800")).exists)
    }
}
