import SwiftUI

struct ScoreComponent<T: VotableModel>: View {
    @ObservedObject var votableModel: T
    @EnvironmentObject var authModel: AuthenticationModel
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.up")
                .scaleEffect(0.8)
                .padding(.trailing, -5)
            Text(votableModel.score_hidden ? "-" : votableModel.score < 1000 ? String(votableModel.score) : String("\(round((Double(votableModel.score) / 1000) * 10) / 10)K"))
        }
        .onTapGesture {
            votableModel.vote(accessToken: authModel.accessToken, direction: true)
        }
        .foregroundColor(votableModel.likes == true ? .orange : votableModel.likes == false ? .purple : .gray)
    }
}
