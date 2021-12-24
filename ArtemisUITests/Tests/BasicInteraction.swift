import XCTest
import Embassy
import EnvoyAmbassador

class BasicInteraction: UITestBase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    func testLaunch() throws {
        app.launch()
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "What movie do you have to")).exists)
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "15.6K")).exists)
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "AskReddit")).exists)
        app.buttons["post id: myq82u"].firstMatch.tap()
        app.buttons["Collapse Post"].firstMatch.tap()
        app.buttons["Mrlavallee user button"].tap()
        XCTAssert(app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", "440")).exists)
    }
}
