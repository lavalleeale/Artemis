import Foundation

protocol VotableModel: ObservableObject {
    var id: String { get }
    var likes: Bool? {get set}
    var score: Int {get set}
    var score_hidden: Bool { get }
    func vote(accessToken: String?, direction: Bool)
}
