import SwiftUI

struct PostsView: View {
    @ObservedObject var posts: PostsModel
    @State var newPath: String = ""
    @State var showingNew = false
    @EnvironmentObject var authModel: AuthenticationModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(postsModel: PostsModel) {
        self.posts = postsModel
        self.newPath = postsModel.path
    }
    
    var body: some View {
        ZStack {
            if (newPath != "") {
                NavigationLink(destination: PostsView(postsModel: PostsModel(path: "r/\(newPath)/", accessToken: authModel.accessToken)), isActive: $showingNew) {
                    EmptyView()
                }
                .hidden()
            }
            PostsComponent(posts: posts)
        }
        .navigationBarTitle((posts.path != "") ? posts.path : "Home", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField((posts.path == "") ? "Home" : posts.path, text: $newPath, onCommit:  {
                    showingNew = true
                })
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 100, maxWidth: 100)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                SortSelectorComponent(function: { posts.changeSortAndTime(sort: $0, time: $1) }, currentSort: $posts.sort, currentTime: $posts.time, type: .posts)
            }
        }
    }
}
