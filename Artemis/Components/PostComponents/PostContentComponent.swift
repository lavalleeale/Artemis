import SwiftUI
import AVKit

struct PostContentComponent: View {
    @ObservedObject var post: PostModel
    @State var showParent = false
    
    var body: some View {
        ZStack {
            switch post.post_hint {
            case .image:
                if (post.image != nil) {
                    Image(uiImage: post.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            case .link:
                URLComponent(image: $post.image, url: post.url)
            case .hostedVideo:
                if (post.player != nil) {
                    VideoPlayer(player: post.player)
                        .frame(height: 400)
                }
            case .cross:
                ZStack {
                    PostPreviewComponent(post: post.parent!)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.secondary).opacity(0.1))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showParent = true
                        }
                    NavigationLink(destination: PostView(post: post.parent!), isActive: $showParent) {
                        EmptyView()
                    }
                    .hidden()
                }
            default:
                Text("Unknown")
            }
        }
        .onAppear(perform: post.onAppear)
    }
}
