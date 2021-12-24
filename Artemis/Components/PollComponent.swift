import SwiftUI

struct PollComponent: View {
    @ObservedObject var pollModel: PollModel
    var body: some View {
        VStack {
            ForEach(pollModel.options, id: \.id) { option in
                Button(option.text) {
                    
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.primary)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.secondary.opacity(0.4)))
            }
            Text("\(pollModel.total_vote_count) \(pollModel.total_vote_count == 1 ? "vote" : "votes")")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.4)))
    }
}
