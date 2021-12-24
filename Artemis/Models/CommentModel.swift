import Foundation
import Combine

class CommentModel: Decodable, ObservableObject {
    enum CodingKeys: CodingKey {
        case data, kind
    }
    let kind: CommentType
    @Published var data: CommentDataModel?
    @Published var more: CommentMoreModel?
    @Published var thread: CommentMoreModel?
    let id: String
    let depth: Int
    let parent_id: String
    var anyCancellable: AnyCancellable? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(CommentType.self, forKey: .kind)
        if (kind == .t1) {
            let data = try container.decode(CommentDataModel.self, forKey: .data)
            self.data = data
            id = data.id
            depth = data.depth
            parent_id = data.parent_id
            anyCancellable = self.data!.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }
        } else if (kind == .more) {
            let more = try container.decode(CommentMoreModel.self, forKey: .data)
            self.more = more
            id = more.id
            depth = more.depth
            parent_id = more.parent_id
            anyCancellable = self.more!.objectWillChange.sink { [weak self] (_) in
                self?.objectWillChange.send()
            }
        } else {
            throw "Wrong Type Of Comment"
        }
    }
}
