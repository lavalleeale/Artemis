import Foundation

class PollModel: ObservableObject, Decodable {
    enum CodingKeys: CodingKey {
        case options, voting_end_timestamp, total_vote_count
    }
    
    var options: [PollOption]
    var voting_end_timestamp: Int
    var total_vote_count: Int
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        options = try container.decode([PollOption].self, forKey: .options)
        voting_end_timestamp = try container.decode(Int.self, forKey: .voting_end_timestamp)
        total_vote_count = try container.decode(Int.self, forKey: .total_vote_count)
    }
}
