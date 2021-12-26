import Combine

/// Type returned from https://www.reddit.com/best.json
struct Posts: Decodable {
    var data: PostsData
}


struct PostsData: Decodable {
    var after: String?
    var children: [Post]
}


struct Post: Decodable {
    var data: PostModel
}

struct Comments: Decodable {
    var data: CommentsData
}

struct CommentsData: Decodable {
    var children: [CommentModel]
}


enum CommentType: String, Decodable {
    case t1, more
}

/// Type returned from https:///www.reddit.com/[subreddit]/comments/[postId].json
struct PostWithComments: Decodable {
    var post: Post
    var children: [CommentModel]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        self.post = try container.decode(Posts.self).data.children[0]
        self.children = []
        
        let children = try container.decode(Comments.self).data.children
        
        self.children.append(contentsOf: children)
    }
}

/// Type returned from https:///www.reddit.com/u/[user].json
struct User: Decodable {
    var data: UserData
}

struct UserData: Decodable {
    var comment_karma: Int
    var total_karma: Int
    var link_karma: Int
    var created_utc: Double
}

/// Type returned when reddit API returns an error
struct APIErrorResponse: Decodable {
    var reason: String?
    var message: String
    var error: Int
}

struct Media: Decodable {
    var reddit_video: RedditVideo?
}

struct RedditVideo: Decodable {
    var fallback_url: String
}

struct CommentMore: Decodable {
    var data: CommentMoreModel
}
enum PostType: String, Decodable {
    case image
    case link
    case hostedVideo = "hosted:video"
    case richVideo = "rich:video"
    case selfType = "self"
    case poll
    case cross
}

struct EmptyResponse: Decodable {}

/// Type returned from https://www.reddit.com/api/morechildren.json
struct MoreChildren: Decodable {
    var json: MoreChildrenJson
}

struct MoreChildrenJson: Decodable {
    var data: MoreChildrenData
}

struct MoreChildrenData: Decodable {
    var things: [CommentModel]
}

struct PollOption: Decodable {
    var text: String
    var vote_count: Int?
    var id: String
}

// Allow throwing srings as errors
extension String: Error {}
