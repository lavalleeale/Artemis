import SwiftUI

struct PostActionsComponent: View {
    @ObservedObject var post: PostModel
    @EnvironmentObject var authModel: AuthenticationModel
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(String(post.subreddit_name_prefixed.dropFirst(2)))
                    Spacer()
                }
                HStack {
                    ScoreComponent(votableModel: post)
                    HStack {
                        Image(systemName: "text.bubble")
                            .scaleEffect(0.8)
                            .padding(.trailing, -5)
                        Text(post.num_comments < 1000 ? String(post.num_comments) : String("\(round((Double(post.num_comments) / 1000) * 10) / 10)K"))
                    }
                    Spacer()
                }
            }
            Spacer()
            Image(systemName: "arrow.up")
                .foregroundColor(post.likes == true ? Color.orange : Color.primary)
                .onTapGesture {
                    post.vote(accessToken: authModel.accessToken, direction: true)
                }
            Image(systemName: "arrow.down")
                .foregroundColor(post.likes == false ? Color.purple : Color.primary)
                .onTapGesture {
                    post.vote(accessToken: authModel.accessToken, direction: false)
                }
        }
        .padding(10)
        .border(Color.secondary, width: 0.5)
    }
}
