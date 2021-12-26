import SwiftUI
import WebKit
import AVKit

struct PostView: View {
    @ObservedObject var post: PostModel
    @EnvironmentObject var authModel: AuthenticationModel
    @State var collapsed: Bool = false
    @State var parentContent: String? = nil
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if post.is_self {
                    VStack {
                        HStack {
                            VStack {
                                Text(post.title)
                                    .bold()
                                Text(post.selftext)
                                    .lineLimit(collapsed ? 1 : .max)
                            }
                            Spacer()
                        }
                        .accessibility(addTraits: .isButton)
                        .accessibility(identifier: "Collapse Post")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                collapsed.toggle()
                            }
                        }
                        if (!collapsed && post.post_hint == .poll) {
                            PollComponent(pollModel: post.pollData!)
                        }
                    }
                } else {
                    VStack {
                        if (!collapsed) {
                            PostContentComponent(post: post)
                        }
                        Text(post.title)
                            .bold()
                            .lineLimit(collapsed ? 1 : .max)
                    }
                }
                Spacer()
                HStack {
                    Text("In")
                    NavigationLink(String(post.subreddit_name_prefixed.dropFirst(2))) {
                        PostsView(postsModel: PostsModel(path: "\(post.subreddit_name_prefixed)/", accessToken: authModel.accessToken))
                    }
                    .foregroundColor(.primary)
                    Text("by")
                    NavigationLink(post.author) {
                        UserView(username: post.author)
                    }
                    .accessibility(identifier: "\(post.author) user button")
                    .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        collapsed.toggle()
                    }
                }
            }
            .padding()
            PostActionsComponent(post: post)
            Divider()
                .onAppear {
                    if (self.post.comments.count == 0) {
                        self.post.getComments(accessToken: authModel.accessToken, parentContent: parentContent)
                    }
                }
            ForEach(post.comments, id: \.id) { comment in
                CommentComponent(comment: comment, authModel: authModel, parentComment: parentContent)
                    .environmentObject(post)
            }
        }
        .navigationBarTitle(post.title, displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                SortSelectorComponent(function: { sort, _ in post.changeSort(sort: sort, accessToken: authModel.accessToken) }, currentSort: $post.sort, currentTime: .constant(Time.all), type: .comments)
            }
            ToolbarItem(placement: .bottomBar) {
                if (self.parentContent != nil) {
                    Text("Single Comment Thread")
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 2)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.blue))
                } else {
                    EmptyView()
                }
            }
        }
    }
}
