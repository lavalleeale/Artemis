import SwiftUI
import AVKit

struct PostPreviewComponent: View {
    @ObservedObject var post: PostModel
    
    init(post: PostModel) {
        self.post = post
    }
    
    var body: some View {
        VStack {
            NavigationLink(destination: PostView(post: post)) {
                VStack {
                    HStack {
                        if (post.pollData != nil) {
                            Image(systemName: "chart.bar")
                        }
                        Text(post.title)
                            .bold()
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    if (post.is_self) {
                        HStack {
                            Text(post.selftext)
                                .lineLimit(5)
                            Spacer()
                        }
                    } else {
                        PostContentComponent(post: post)
                    }
                }
                .contentShape(Rectangle())
            }
            .accessibility(identifier: "post id: \(post.id)")
            PostActionsComponent(post: post)
        }
    }
}
