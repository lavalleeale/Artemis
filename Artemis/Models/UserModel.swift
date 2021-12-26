import Foundation
import Combine

class UserModel: ObservableObject {
    @Published var data: UserData?
    @Published var age: String?
    let username: String
    var cancellable : Set<AnyCancellable> = Set()
    
    init(username: String) {
        self.username = username
    }
    
    func fetch (accessToken: String?) {
        makeRequest(accessToken: accessToken, path: "user/\(username)/about", responseType: User.self).receive(on: DispatchQueue.main)
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
                        print("handle \(error.message) in UserModel")
                    case NetworkError.decoding:
                        print("handle decoding error")
                    }                }
            }) { data in
                self.data = data.data
                let date = Date(timeIntervalSince1970: data.data.created_utc)
                
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                self.age = String(formatter.localizedString(for: date, relativeTo: Date()).dropLast(5))
            }
            .store(in: &cancellable)
    }
}
