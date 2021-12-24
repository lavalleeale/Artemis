import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authModel: AuthenticationModel
    
    var body: some View {
        ZStack {
            if authModel.accessToken == nil {
                Button("Sign In") {
                    authModel.signIn()
                }.foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                List {
                    ForEach(authModel.accounts, id: \.username) { item in
                        NavigationLink(item.username) {
                            UserView(username: item.username, authModel: authModel)
                        }
                        .accessibility(identifier: "\(item.username) user button")
                    }.onDelete(perform: authModel.signOut)
                }
            }
        }
        .navigationBarTitle("Accounts", displayMode: .inline)
    }
}
