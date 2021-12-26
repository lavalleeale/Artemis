import Foundation
import Combine

let userExpression = try! NSRegularExpression(pattern: #"/u/(?<username>.+)"#, options: [])
let postsExpression = try! NSRegularExpression(pattern: #"/r/(?<subreddit>.+)"#, options: [])
let singleCommentExpression = try! NSRegularExpression(pattern: #"/comment/(?<comment>.+)"#, options: [])

class LoadingModel: ObservableObject {
    @Published var postModel: PostModel?
    @Published var postsModel: PostsModel?
    @Published var singleComment: String?
    @Published var userModel: UserModel?
    let type: ThingType
    
    var cancellable = Set<AnyCancellable>()
    
    init(path: String, accessToken: String?) {
        let range = NSRange(location: 0, length: path.utf16.count)
        if (path[String.Index(utf16Offset: 1, in: path)] == "u") {
            type = .user
            let match = userExpression.firstMatch(in: path, options: [], range: range)!
            let username = String(path[Range(match.range(withName: "username"), in: path)!])
            self.userModel = UserModel(username: username)
            self.userModel!.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }.store(in: &cancellable)
        } else if (path.contains("comments")) {
            type = .comments
            if (path.contains("/comment/")) {
                let match = singleCommentExpression.firstMatch(in: path, options: [], range: range)!
                self.singleComment = String(path[Range(match.range(withName: "comment"), in: path)!])
            }
            let permaLink = String(path.dropFirst())
            getPost(accessToken: accessToken, permaLink: permaLink)
        } else {
            type = .posts
            self.postsModel = PostsModel(path: String(path.dropFirst()), accessToken: accessToken)
            self.postsModel!.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }.store(in: &cancellable)
        }
    }
    func getPost(accessToken: String?, permaLink: String) {
        makeRequest(accessToken: accessToken, path: "\(permaLink)?context=2", responseType: PostWithComments.self).receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
//                                        print("completed")
                    break
                case .failure(let error):
                    switch error {
                    case NetworkError.network:
                        print("handle network error")
                    case NetworkError.api(error: let error):
                        print("handle \(error.message) in PostModel")
                    case NetworkError.decoding(error: let error):
                        print("handle decoding error: \(error.error)")
                    }
                    
                }
            }) { data in
                self.postModel = data.post.data
                self.postModel!.comments = data.children
                self.postModel!.objectWillChange.sink { [weak self] (_) in
                    self?.objectWillChange.send()
                }.store(in: &self.cancellable)
            }.store(in: &cancellable)
    }
}
