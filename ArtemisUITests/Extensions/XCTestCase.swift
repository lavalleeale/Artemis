import Foundation
import XCTest

import Embassy
import EnvoyAmbassador

class UITestBase: XCTestCase {
    let port = 8080
    var router: Router!
    var eventLoop: EventLoop!
    var server: HTTPServer!
    var app: XCUIApplication!
    
    var eventLoopThreadCondition: NSCondition!
    var eventLoopThread: Thread!
    
    override func setUp() {
        super.setUp()
        setupWebApp()
        setupApp()
        
        router["/best.json"] = DataResponse(handler: { _ in
            let bundle = Bundle(for: type(of: self))
            
            // Ask Bundle for URL of Stub
            let url = bundle.url(forResource: "axlavtesting", withExtension: ".json")
            
            // Use URL to Create Data Object
            return try! Data(contentsOf: url!)
        })
        router["/r/axlavtesting.json"] = DataResponse(handler: { _ in
            let bundle = Bundle(for: type(of: self))
            
            // Ask Bundle for URL of Stub
            let url = bundle.url(forResource: "axlavtesting", withExtension: ".json")
            
            // Use URL to Create Data Object
            return try! Data(contentsOf: url!)
        })
        router["/user/Mrlavallee/about.json"] = DataResponse(handler: { _ in
            let bundle = Bundle(for: type(of: self))
            
            // Ask Bundle for URL of Stub
            let url = bundle.url(forResource: "about", withExtension: ".json")
            
            // Use URL to Create Data Object
            return try! Data(contentsOf: url!)
        })
        router["/r/axlavtesting/comments/myq82u/long.json"] = DataResponse(handler: { _ in
            let bundle = Bundle(for: type(of: self))
            
            // Ask Bundle for URL of Stub
            let url = bundle.url(forResource: "long", withExtension: ".json")
            
            // Use URL to Create Data Object
            return try! Data(contentsOf: url!)
        })
    }
    
    // setup the Embassy web server for testing
    private func setupWebApp() {
        eventLoop = try! SelectorEventLoop(selector: try! KqueueSelector())
        router = Router()
        server = DefaultHTTPServer(eventLoop: eventLoop, port: port, app: router.app)
        
        // Start HTTP server to listen on the port
        try! server.start()
        
        eventLoopThreadCondition = NSCondition()
        eventLoopThread = Thread(target: self, selector: #selector(runEventLoop), object: nil)
        eventLoopThread.start()
    }
    
    // set up XCUIApplication
    private func setupApp() {
        app = XCUIApplication()
        app.launchEnvironment["REDDIT_BASEURL"] = "http://localhost:\(port)"
        app.launchEnvironment["REDDIT_OAUTHURL"] = "http://localhost:\(port)"
    }
    
    override func tearDown() {
        super.tearDown()
        app.terminate()
        server.stopAndWait()
        eventLoopThreadCondition.lock()
        eventLoop.stop()
        while eventLoop.running {
            if !eventLoopThreadCondition.wait(until: NSDate().addingTimeInterval(10) as Date) {
                fatalError("Join eventLoopThread timeout")
            }
        }
    }
    
    @objc private func runEventLoop() {
        eventLoop.runForever()
        eventLoopThreadCondition.lock()
        eventLoopThreadCondition.signal()
        eventLoopThreadCondition.unlock()
    }
}
