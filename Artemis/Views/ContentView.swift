import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authModel: AuthenticationModel
    
    var body: some View {
        TabView {
            NavigationView {
                PostsView(postsModel: PostsModel(path: "r/axlavtesting/", accessToken: authModel.accessToken))
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "note")
                Text("Posts")
            }
            NavigationView {
                AuthView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Accounts")
            }
        }
    }
}
