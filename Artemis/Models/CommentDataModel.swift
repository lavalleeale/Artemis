import Foundation
import Combine

class CommentDataModel: VotableModel, ObservableObject, Decodable {
    
    enum CodingKeys: CodingKey {
        case body, author, id, replies, score, distinguished, stickied, locked, is_submitter, score_hidden, collapsed_reason_code, depth, parent_id, name, likes
    }
    
    @Published var body: String
    @Published var score: Int
    @Published var likes: Bool?
    @Published var stickied: Bool
    @Published var locked: Bool
    @Published var collapsed_reason_code: String?
    @Published var more: CommentMoreModel?
    let depth: Int
    let is_submitter: Bool
    let distinguished: String?
    let author: String
    let id: String
    let name: String
    let parent_id: String
    let score_hidden: Bool
    var comments = [CommentModel]()
    
    var cancelable: AnyCancellable?
    
    func vote(accessToken: String?, direction: Bool) {
        cancelable = Artemis.vote(accessToken: accessToken, fullname: self.name, direction: ((self.likes == direction) ? 0 : direction == true ? 1: -1)).receive(on: DispatchQueue.main)
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
                        print("handle \(error.message) in PostModel")
                    case NetworkError.decoding(error: let error):
                        print("handle decoding error: \(error.error)")
                    }
                    
                }
            }) { data in
                if (self.likes == direction) {
                    self.likes = nil
                } else {
                    self.likes = direction
                }
            }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try container.decode(String.self, forKey: .body)
        score = try container.decode(Int.self, forKey: .score)
        author = try container.decode(String.self, forKey: .author)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        parent_id = try container.decode(String.self, forKey: .parent_id)
        distinguished = try container.decode(String?.self, forKey: .distinguished)
        stickied = try container.decode(Bool.self, forKey: .stickied)
        locked = try container.decode(Bool.self, forKey: .locked)
        is_submitter = try container.decode(Bool.self, forKey: .is_submitter)
        score_hidden = try container.decode(Bool.self, forKey: .score_hidden)
        depth = try container.decode(Int.self, forKey: .depth)
        collapsed_reason_code = try container.decodeIfPresent(String.self, forKey: .collapsed_reason_code)
        likes = try container.decode(Bool?.self, forKey: .likes)
        do {
            let comments = try container.decode(Comments.self, forKey: .replies)
            for comment in comments.data.children {
                self.comments.append(comment)
            }
        } catch {
            do {
                more = try container.decode(CommentMoreModel.self, forKey: .replies)
            } catch {}
        }
    }
}
