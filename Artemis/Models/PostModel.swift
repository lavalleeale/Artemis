import Foundation
import Combine
import SwiftUI
import AVKit

class PostModel: VotableModel, Decodable, Identifiable {
    enum CodingKeys: CodingKey {
        case title, id, selftext, is_self, url, post_hint, subreddit_name_prefixed, author, score, thumbnail, upvote_ratio, media, suggested_sort, poll_data, selftext_html, crosspost_parent_list, likes, num_comments, name, permalink
    }
    
    @Published var player: AVPlayer?
    @Published var image: UIImage?
    @Published var imageLoader: ImageLoader = ImageLoader()
    
    @Published var comments: [CommentModel] = []
    @Published var selftext: String
    @Published var selftext_html: String?
    @Published var upvote_ratio: Float
    @Published var score: Int
    @Published var sort: Sort
    @Published var pollData: PollModel?
    @Published var parent: PostModel?
    @Published var likes: Bool?
    @Published var num_comments: Int
    
    let name: String
    let permalink: String
    let subreddit_name_prefixed: String
    let title: String
    let author: String
    let id: String
    let is_self: Bool
    let url: String
    let post_hint: PostType?
    let thumbnail: String
    let media: Media?
    let score_hidden = false
    var suggested_sort: Sort
    
    var cancellable : Set<AnyCancellable> = Set()
    
    func changeSort(sort: Sort, accessToken: String?) {
        self.sort = sort
        cancellable.removeAll()
        comments.removeAll()
        getComments(accessToken: accessToken)
    }
    
    func onAppear() {
        if self.post_hint == .image && self.image == nil {
            self.imageLoader.load(urlString: self.url) { data in
                DispatchQueue.main.async {
                    guard let data = data else {
                        return
                    }
                    self.image = UIImage(data: data)
                }
            }
        }
        if (self.post_hint == .link && self.image == nil) {
            self.imageLoader.load(urlString: self.thumbnail) { data in
                DispatchQueue.main.async {
                    guard let data = data else {
                        return
                    }
                    self.image = UIImage(data: data)
                }
            }
        }
        if (self.post_hint == .hostedVideo && self.player == nil) {
            self.player = AVPlayer(url: URL(string: self.media!.reddit_video!.fallback_url)!)
        }
    }
    
    func vote(accessToken: String?, direction: Bool) {
        Artemis.vote(accessToken: accessToken, fullname: self.name, direction: ((self.likes == direction) ? 0 : direction == true ? 1: -1)).receive(on: DispatchQueue.main)
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
            .store(in: &cancellable)
    }
    
    func getComments(accessToken: String?, parentContent: String? = nil) {
        makeRequest(accessToken: accessToken, path: "\(self.permalink.dropFirst().dropLast())?sort=\(sort)\(parentContent == nil ? "" : "&comment=\(parentContent!)&context=2")", responseType: PostWithComments.self).receive(on: DispatchQueue.main)
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
                let postData = data.post.data
                self.selftext = postData.selftext
                self.selftext_html = postData.selftext_html
                if (self.suggested_sort != postData.suggested_sort) {
                    self.sort = postData.suggested_sort
                    self.suggested_sort = postData.suggested_sort
                }
                self.upvote_ratio = postData.upvote_ratio
                self.score = postData.score
                self.num_comments = postData.num_comments
                self.comments.append(contentsOf: data.children)
                self.pollData = postData.pollData
            }
            .store(in: &cancellable)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        id = try container.decode(String.self, forKey: .id)
        is_self = try container.decode(Bool.self, forKey: .is_self)
        selftext = try container.decode(String.self, forKey: .selftext)
        selftext_html = try container.decodeIfPresent(String.self, forKey: .selftext_html)
        url = try container.decode(String.self, forKey: .url)
        author = try container.decode(String.self, forKey: .author)
        subreddit_name_prefixed = try container.decode(String.self, forKey: .subreddit_name_prefixed)
        score = try container.decode(Int.self, forKey: .score)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        upvote_ratio = try container.decode(Float.self, forKey: .upvote_ratio)
        likes = try container.decode(Bool?.self, forKey: .likes)
        num_comments = try container.decode(Int.self, forKey: .num_comments)
        name = try container.decode(String.self, forKey: .name)
        permalink = try container.decode(String.self, forKey: .permalink)
        suggested_sort = Sort.init(rawValue: try container.decodeIfPresent(String.self, forKey: .suggested_sort) ?? "top")!
        sort = suggested_sort
        media = try container.decodeIfPresent(Media.self, forKey: .media)
        let parent = try container.decodeIfPresent([PostModel].self, forKey: .crosspost_parent_list)?[0]
        self.parent = parent
        let pollData = try container.decodeIfPresent(PollModel.self, forKey: .poll_data)
        self.pollData = pollData
        if (pollData != nil) {
            post_hint = .poll
        } else if (parent != nil) {
            post_hint = .cross
        } else {
            post_hint = try container.decodeIfPresent(PostType.self, forKey: .post_hint)
        }
    }
}
