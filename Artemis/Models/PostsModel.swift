import Foundation
import Combine

class PostsModel: ObservableObject {
    @Published var posts = [PostModel]()
    @Published var sort = Sort.best
    @Published var time = Time.all
    @Published var error: PostsError?
    var pageStatus = PageStatus.ready(nextPage: "")
    var cancellable : Set<AnyCancellable> = Set()
    var accessToken: String?
    var path: String
    
    init(path: String, accessToken: String?) {
        self.accessToken = accessToken
        self.path = path;
        fetchPosts()
    }
    
    func shouldLoadMore(post: PostModel) -> Bool {
        return post.id == posts.last?.id
    }
    
    func reset(accessToken: String?) {
        cancellable.removeAll()
        pageStatus = PageStatus.ready(nextPage: "")
        self.accessToken = accessToken
        posts.removeAll()
        fetchPosts()
    }
    
    func changeSort(sort: Sort) {
        self.sort = sort
        cancellable.removeAll()
        pageStatus = PageStatus.ready(nextPage: "")
        posts.removeAll()
        fetchPosts()
    }
    func changeSortAndTime(sort: Sort, time: Time) {
        self.time = time
        changeSort(sort: sort)
    }
    
    func fetchPosts() {
        guard case let .ready(page) = pageStatus else {
            return
        }
        pageStatus = .loading(page: page)
        makeRequest(accessToken: accessToken, path: "\(path)\(sort)?after=\(page)&t=\(time)", responseType: Posts.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    //                    print("completed")
                    break
                case .failure(let error):
                    switch error {
                    case NetworkError.network:
                        print("handle network error")
                    case NetworkError.api(error: let error):
                        if(error.message == "Not Found") {
                            self.error = .subNotFound
                        } else if (error.reason == "private") {
                            self.error = .privateSub
                        }
                        print("handle \(error.message) in PostsModel with path \(self.path)")
                    case NetworkError.decoding(error: let error):
                        print("decoding error")
                        print(error.error)
                    }
                    
                }
            }) { posts in
                for post in posts.data.children {
                    self.posts.append(post.data)
                }
                self.pageStatus = (posts.data.after != nil) ? .ready(nextPage: posts.data.after!) : .done
            }
            .store(in: &cancellable)
    }
}

enum PageStatus {
    case ready (nextPage: String)
    case loading (page: String)
    case done
}

enum PostsError {
    case privateSub, subNotFound
}
