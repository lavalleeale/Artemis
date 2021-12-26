import SwiftUI

struct LoadingComponent: View {
    @ObservedObject var loadingModel: LoadingModel
    
    init(path: String, accessToken: String?) {
        self.loadingModel = LoadingModel(path: path, accessToken: accessToken)
    }
    
    var body: some View {
        ZStack {
            switch loadingModel.type {
            case .user:
                UserView(userModel: loadingModel.userModel!)
            case .comments:
                if (loadingModel.postModel != nil) {
                    PostView(post: loadingModel.postModel!, parentContent: loadingModel.singleComment)
                }
            case .posts:
                PostsView(postsModel: loadingModel.postsModel!)
            }
        }
    }
}
