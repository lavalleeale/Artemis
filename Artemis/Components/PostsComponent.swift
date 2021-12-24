import SwiftUI

struct PostsComponent: View {
    @ObservedObject var posts: PostsModel
    @EnvironmentObject var authModel: AuthenticationModel
    
    var body: some View {
        ZStack {
            if (posts.error != nil) {
                switch posts.error! {
                case .privateSub:
                    Text("Subreddit Private")
                case .subNotFound:
                    Text("Subreddit Not Found")
                }
            } else {
                List {
                    ForEach($posts.posts) { $post in
                        PostPreviewComponent(post: post)
                            .onAppear {
                                if posts.posts.count > 0 && post.id == posts.posts.last?.id {
                                    posts.fetchPosts()
                                }
                            }
                    }
                }
                .onChange(of: authModel.accessToken) { newValue in
                    posts.reset(accessToken: newValue)
                }
            }
        }
    }
}
