import SwiftUI

struct UserView: View {
    @State var username: String
    @EnvironmentObject var authModel: AuthenticationModel
    @ObservedObject var userModel: UserModel
    
    init(username: String, authModel: AuthenticationModel) {
        self.username = username
        self.userModel = UserModel(accessToken: authModel.accessToken)
    }
    
    var body: some View {
        VStack {
            if (userModel.data != nil ) {
                VStack {
                    HStack {
                        VStack {
                            Text("\(userModel.data!.comment_karma)")
                                .bold()
                            Text("Comment Karma")
                                .fontWeight(.light)
                        }
                        VStack {
                            Text("\(userModel.data!.link_karma)")
                                .bold()
                            Text("Post Karma")
                                .fontWeight(.light)
                        }
                        VStack {
                            Text("\(userModel.age!)")
                                .bold()
                            Text("Account Age")
                                .fontWeight(.light)
                        }
                    }
                    Spacer()
                    PostsComponent(posts: PostsModel(path: "u/\(username)/submitted/", accessToken: authModel.accessToken))
                }
            }
        }
        .navigationBarTitle(username, displayMode: .inline)
        .onAppear {
            self.userModel.fetch(username: username)
        }
    }
}
