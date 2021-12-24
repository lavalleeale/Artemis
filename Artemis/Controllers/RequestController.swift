import Foundation
import Combine

func makeRequest<T: Decodable>(accessToken: String?, path: String, responseType: T.Type, body: String? = nil) -> AnyPublisher<T, NetworkError> {
    let baseUrl = (accessToken != nil) ? ProcessInfo.processInfo.environment["REDDIT_OAUTHURL"]! : ProcessInfo.processInfo.environment["REDDIT_BASEURL"]!
    var request =  URLRequest(url: URL(string: "\(baseUrl)/\(path)")!.appendingPathExtension("json"))
    if (accessToken != nil) {
        request.setValue("bearer \(accessToken!)", forHTTPHeaderField: "authorization")
    }
    request.setValue("ios:com.axlav.artemis:v1.0.0 (by /u/mrlavallee)", forHTTPHeaderField: "User-Agent")
    if ((body) != nil) {
        request.httpBody = body!.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    return URLSession.shared.dataTaskPublisher(for: request)
    // #1 URLRequest fails, throw APIError.network
        .mapError {
            NetworkError.network(code: $0.code.rawValue, description: $0.localizedDescription)
        }
        .flatMap { v in
            Just(v.data)
            
            // #2 try to decode data as a `Response`
                .decode(type: T.self, decoder: JSONDecoder())
            
                .mapError { NetworkError.decoding(message: String(data: v.data, encoding: .utf8) ?? "", error: $0) }
            
            // #3 if decoding fails,
                .tryCatch { decodingError in
                    Just(v.data)
                    // #3.1 ... decode as an `ErrorResponse`
                        .decode(type: APIErrorResponse.self, decoder: JSONDecoder())
                    
                    // #4 if both fail, throw APIError.decoding
                        .mapError { _ in decodingError }
                    
                    // #3.2 ... and throw `APIError.api
                        .tryMap { throw NetworkError.api(error: $0) }
                }
            
            // force unwrap is not terrible here, since you know
            // that `tryCatch` only ever throws APIError
                .mapError { $0 as! NetworkError }
        }
        .eraseToAnyPublisher()
}

func makeAuthRequest(body: String, path: String) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError> {
    let baseUrl = "https://www.reddit.com/api/v1"
    var request =  URLRequest(url: URL(string: "\(baseUrl)/\(path)")!)
    request.setValue("Basic N3QyWm5KYllqRmJrQVdIZkpEZzdiUTo=", forHTTPHeaderField: "authorization")
    request.httpBody = body.data(using: .utf8)
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    return URLSession.shared.dataTaskPublisher(for: request)
    // #1 URLRequest fails, throw APIError.network
        .mapError {
            NetworkError.network(code: $0.code.rawValue, description: $0.localizedDescription)
        }
        .eraseToAnyPublisher()
}
func decodeAuthResponse<T: Decodable>(body: String, path: String, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
    return makeAuthRequest(body: body, path: path)
        .flatMap { v in
            Just(v.data)
            
            // #2 try to decode data as a `Response`
                .decode(type: T.self, decoder: JSONDecoder())
            
            // #3 if decoding fails,
                .tryCatch { _ in
                    Just(v.data)
                    // #3.1 ... decode as an `ErrorResponse`
                        .decode(type: APIErrorResponse.self, decoder: JSONDecoder())
                    
                    // #4 if both fail, throw APIError.decoding
                        .mapError { NetworkError.decoding(message: String(data: v.data, encoding: .utf8) ?? "", error: $0) }
                    
                    // #3.2 ... and throw `APIError.api
                        .tryMap { throw NetworkError.api(error: $0) }
                }
            
            // force unwrap is not terrible here, since you know
            // that `tryCatch` only ever throws APIError
                .mapError { $0 as! NetworkError }
        }
        .eraseToAnyPublisher()
}

func vote(accessToken: String?, fullname: String, direction: Int) -> AnyPublisher<EmptyResponse, NetworkError> {
    return makeRequest(accessToken: accessToken, path: "api/vote", responseType: EmptyResponse.self, body: "id=\(fullname)&dir=\(direction)")
}

enum NetworkError: Error {
    case network(code: Int, description: String)
    case decoding(message: String, error: Error)
    case api(error: APIErrorResponse)
}

enum Time: String, CaseIterable {
    case hour, day, week, month, year, all
}

enum Sort: String, CaseIterable {
    case best, confidence, hot, top, new, rising, controversial, qa, random
    
    var image: String {
        switch (self) {
        case .best: return "rosette"
        case .confidence: return "rosette"
        case .controversial: return "flag.2.crossed"
        case .hot: return "flame"
        case .new: return "clock"
        case .rising: return "chart.line.uptrend.xyaxis"
        case .top: return "text.insert"
        case .qa: return "hand.raised"
        case .random: return "dice"
        }
    }
    
    var posts: Bool {
        switch self {
        case .confidence, .qa, .random: return false
        default: return true
        }
    }
    var comments: Bool {
        switch self {
        case .best: return false
        default: return true
        }
    }
    
    var hasTime: Bool {
        switch self {
        case .top, .controversial: return true
        default: return false
        }
    }
}
