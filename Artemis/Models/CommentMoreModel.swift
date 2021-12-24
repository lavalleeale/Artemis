import Foundation
import Combine

class CommentMoreModel: ObservableObject, Decodable {
    
    enum CodingKeys: CodingKey {
        case count, children, depth, id, parent_id
    }
    
    @Published var finishedChildren = [CommentModel]()
    @Published var thread: CommentModel?
    let count: Int
    let depth: Int
    let id: String
    let parent_id: String
    let waitingChildren: [String]
    
    var cancellable : AnyCancellable?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decode(Int.self, forKey: .count)
        depth = try container.decode(Int.self, forKey: .depth)
        waitingChildren = try container.decode([String].self, forKey: .children)
        parent_id = try container.decode(String.self, forKey: .parent_id)
        let id = try container.decode(String.self, forKey: .id)
        self.id = (id == "_" ? "more_\(parent_id)" : id)
    }
    
    func getComments(accessToken: String?, parent: PostModel) {
        if (count != 0) {
            let childrenString = waitingChildren.joined(separator: ",")
            cancellable = makeRequest(accessToken: accessToken, path: "api/morechildren", responseType: MoreChildren.self, body: "api_type=json&link_id=t3_\(parent.id)&children=\(childrenString)").receive(on: DispatchQueue.main)
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
                            print("handle \(error.message) in CommentMoreModel")
                        case NetworkError.decoding(error: let error):
                            print("handle decoding error: \(error.error)")
                        }
                        
                    }
                }) { data in
                    for child in data.json.data.things {
                        if (child.parent_id == self.parent_id) {
                            self.finishedChildren.append(child)
                        } else {
                            self.finishedChildren.append(child)
                        }
                    }
                }
        } else {
            let path = "\(parent.permalink.dropFirst().dropLast())?comment=\(self.parent_id.dropFirst(3))"
            let baseUrl = (accessToken != nil) ? ProcessInfo.processInfo.environment["REDDIT_OAUTHURL"]! : ProcessInfo.processInfo.environment["REDDIT_BASEURL"]!
            print(URL(string: "\(baseUrl)/\(path)")!.appendingPathExtension("json"))
            cancellable = makeRequest(accessToken: accessToken, path: path, responseType: PostWithComments.self).receive(on: DispatchQueue.main)
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
                            print("handle \(error.message) in CommentMoreModel")
                        case NetworkError.decoding(error: let error):
                            print("handle decoding error: \(error.error)")
                        }
                        
                    }
                }) { data in
                    let postData = data.post.data
                    parent.selftext = postData.selftext
                    parent.selftext_html = postData.selftext_html
                    if (parent.suggested_sort != postData.suggested_sort) {
                        parent.sort = postData.suggested_sort
                        parent.suggested_sort = postData.suggested_sort
                    }
                    parent.upvote_ratio = postData.upvote_ratio
                    parent.score = postData.score
                    parent.num_comments = postData.num_comments
                    self.thread = data.children[0]
                    parent.pollData = postData.pollData
                }
        }
    }
}
