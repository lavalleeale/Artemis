import SwiftUI

@main
struct ArtemisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthenticationModel())
        }
    }
}
