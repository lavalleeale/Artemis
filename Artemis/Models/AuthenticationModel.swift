import Foundation
import AuthenticationServices
import Combine
import SwiftKeychainWrapper

struct TokenResponse: Codable {
    var access_token: String
    var token_type: String
    var expires_in: Int
    var scope: String
    var refresh_token: String
}

struct Account {
    var accessToken: String
    var username: String
}
struct AccountResponse: Codable {
    var name: String
}

let scopes = ["read", "identity", "vote", "submit"]

class AuthenticationModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var accessToken: String? = nil
    @Published var accounts: [Account] = []
    private var refreshTokens: [String] = []
    
    private let redirectUri = "com.axlav.artemis%3A%2F%2Foauth2redirect"
    private let baseUrl = "https://www.reddit.com/api/v1"
    
    private var cancellable : Set<AnyCancellable> = Set()
    
    override internal init() {
        super.init()
        refreshTokens = KeychainWrapper.standard.object(forKey: "RefreshTokens") as? [String] ?? []
        for token in refreshTokens {
            print("Refresh Token: " + token)
            getToken(token: token)
        }
    }
    
    /// Revoke and remove reddit refresh tokens
    /// - Parameter offsets: offsets of ``accounts`` to be revoked and removed
    func signOut(at offsets: IndexSet) {
        for offset in offsets {
            makeAuthRequest(body: "token=\(refreshTokens[offset])", path: "revoke_token")
                .receive(on: DispatchQueue.main).sink(receiveCompletion: {completion in
                    if case .finished = completion {
                        if self.accounts[offset].accessToken == self.accessToken {
                            self.accessToken = nil
                        }
                        self.accounts.remove(at: offset)
                        self.refreshTokens.remove(at: offset)
                        KeychainWrapper.standard.set(self.refreshTokens as NSCoding, forKey: "RefreshTokens")
                    }
                }) {test in}.store(in: &cancellable)
        }
    }
    
    /// Get access token from refresh token or get refresh token from authorization code
    /// - Parameters:
    ///   - token: The refresh token or authorization code to be sent to reddit's API
    ///   - refresh: Weather to obtain access token or refresh token
    func getToken(token: String, refresh: Bool = true) {
        decodeAuthResponse(body: "grant_type=\(refresh ? "refresh_token&refresh_token" : "authorization_code&code")=\(token)&redirect_uri=\(self.redirectUri)", path: "access_token", responseType: TokenResponse.self)
            .receive(on: DispatchQueue.main)
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
                        if (error.message == "Bad Request") {
                            self.refreshTokens.removeAll(where: {$0 == token})
                            KeychainWrapper.standard.set(self.refreshTokens as NSCoding, forKey: "RefreshTokens")
                        } else {
                            print("handle \(error.message) in AuthModel")
                        }
                    case NetworkError.decoding:
                        print("handle decoding error")
                    }
                }
            }) { response in
                self.accessToken = response.access_token
                makeRequest(accessToken: response.access_token, path: "api/v1/me", responseType: AccountResponse.self).receive(on: DispatchQueue.main).sink(receiveCompletion: { completion in
                }) { account in
                    self.accounts.append(Account(accessToken: response.access_token, username: account.name))
                    self.accessToken = response.access_token
                }.store(in: &self.cancellable)
                if !refresh {
                    self.refreshTokens.append(response.refresh_token)
                    KeychainWrapper.standard.set(self.refreshTokens as NSCoding, forKey: "RefreshTokens")
                }
            }
            .store(in: &cancellable)
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    /// Show Popup and use in-app safari to sign into reddit account
    func signIn() {
        let authUrl = URL(string: "\(self.baseUrl)/authorize.compact?client_id=7t2ZnJbYjFbkAWHfJDg7bQ&response_type=code&state=test&redirect_uri=\(self.redirectUri)&duration=permanent&scope=\(scopes.joined(separator: ","))")!
        
        let authSession = ASWebAuthenticationSession(
            url: authUrl, callbackURLScheme:
                "com.axlav.artemis") { (url, error) in
                    if let error = error {
                        print(error)
                    } else if let url = url {
                        self.processResponseURL(url: url)
                    }
                }
        
        authSession.presentationContextProvider = self
        authSession.start()
    }
    
    /// Obtain authorization code from oauth response URL
    func processResponseURL(url: URL) {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let code = urlComponents.queryItems!.first(where: { $0.name == "code" })!.value!
        getToken(token: code, refresh: false)
    }
}
