import SwiftUI

let colors = [Color.green, Color.red, Color.orange, Color.yellow]

struct CommentComponent: View {
    @ObservedObject var comment: CommentModel
    @State var collapsed = false
    @State var showingThread = false
    @ObservedObject var authModel: AuthenticationModel
    @EnvironmentObject var post: PostModel
    @State var parentComment: String? = nil
    
    var body: some View {
        VStack {
            ZStack {
                if (comment.kind == .t1) {
                    VStack(alignment: .leading) {
                        HStack {
                            NavigationLink(comment.data!.author) {
                                UserView(username: comment.data!.author, authModel: authModel)
                            }
                            .accessibility(identifier: "\(comment.data!.author) user button")
                            .foregroundColor(comment.data!.distinguished != nil ? Color.green : comment.data!.is_submitter ? Color.blue : Color.primary)
                            ScoreComponent(votableModel: comment.data!)
                            if (comment.data!.locked) {
                                Image(systemName: "lock.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                            }
                            if (comment.data!.stickied) {
                                Image(systemName: "pin.fill")
                                    .renderingMode(.template)
                                    .foregroundColor(.green)
                                    .rotationEffect(Angle(degrees: 45))
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        if (!collapsed) {
                            Text(.init(comment.data!.body))
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxHeight: .infinity, alignment: .top)
                        }
                        Divider()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.linear(duration: 0.2)) {
                            collapsed.toggle()
                        }
                    }
                } else if (comment.more!.finishedChildren.count == 0) {
                    ZStack {
                        if (comment.more!.count != 0) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Button("Load \(comment.more!.count) more comments") {
                                        comment.more!.getComments(accessToken: authModel.accessToken, parent: post)
                                    }
                                    .accessibility(identifier: "Load MoreComments with id \(comment.id)")
                                }
                                Divider()
                            }
                        } else if (comment.more!.thread != nil) {
                            HStack {
                                NavigationLink("Continue Thread", isActive: $showingThread) {
                                    ScrollView(.vertical) {
                                        CommentComponent(comment: comment.more!.thread!, authModel: authModel)
                                    }
                                }
                                Spacer()
                            }
                        } else {
                            HStack {
                                Button("Continue Thread") {
                                    comment.more!.getComments(accessToken: authModel.accessToken, parent: post)
                                }
                                Spacer()
                            }
                        }
                    }
                    .onChange(of: comment.more?.thread?.id) { _ in
                        showingThread = true
                    }
                }
            }
            .padding(.leading, 5)
            .overlay(Rectangle()
                        .frame(width: CGFloat(comment.depth.signum()), height: nil, alignment: .leading)
                        .foregroundColor(colors[comment.depth % colors.count]), alignment: .leading)
            .padding(.leading, 10 * CGFloat(comment.depth))
            .frame(idealWidth: UIScreen.main.bounds.width - CGFloat(10 * comment.depth), alignment: .leading)
            .padding(self.parentComment == comment.id ? 10 : 0)
            .background(Rectangle().foregroundColor(Color.secondary.opacity(self.parentComment == comment.id ? 0.3 : 0)))
            if (!collapsed) {
                ForEach(comment.kind == .t1 ? comment.data!.comments : comment.more!.finishedChildren, id: \.id) { comment in
                    CommentComponent(comment: comment, authModel: authModel, parentComment: parentComment)
                }
            }
        }
    }
}
