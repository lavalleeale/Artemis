import SwiftUI

struct UserView: View {
    @EnvironmentObject var authModel: AuthenticationModel
    @ObservedObject var userModel: UserModel
    
    init(username: String) {
        userModel = UserModel(username: username)
    }
    init (userModel: UserModel) {
        self.userModel = userModel
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
                    PostsComponent(posts: PostsModel(path: "u/\(userModel.username)/submitted/", accessToken: authModel.accessToken))
                }
            }
        }
        .navigationBarTitle(userModel.username, displayMode: .inline)
        .onAppear {
            self.userModel.fetch(accessToken: authModel.accessToken)
        }
    }
}
