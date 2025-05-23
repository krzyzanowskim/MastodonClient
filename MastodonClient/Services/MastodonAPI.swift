import Foundation
import Combine

class MastodonAPI: ObservableObject {
    static let shared = MastodonAPI()
    
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    var baseURL: String = ""
    var accessToken: String = ""
    
    private init() {}
    
    // MARK: - Authentication
    func createApp(instance: String) -> AnyPublisher<Application, Error> {
        guard let url = URL(string: "https://\(instance)/api/v1/apps") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "client_name": "MastodonClient",
            "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
            "scopes": "read write follow push"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        request.httpBody = httpBody
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Debug print the response
                if let httpResponse = response as? HTTPURLResponse {
                    print("App registration response status: \(httpResponse.statusCode)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("App registration response: \(jsonString)")
                }
                return data
            }
            .decode(type: Application.self, decoder: JSONDecoder())
            .mapError { error in
                print("App registration error: \(error)")
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func getAuthorizationURL(instance: String, clientId: String) -> URL? {
        let urlString = "https://\(instance)/oauth/authorize?client_id=\(clientId)&scope=read+write+follow+push&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code"
        return URL(string: urlString)
    }
    
    func getAccessToken(instance: String, clientId: String, clientSecret: String, code: String) -> AnyPublisher<Token, Error> {
        guard let url = URL(string: "https://\(instance)/oauth/token") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "authorization_code",
            "code": code,
            "scope": "read write follow push"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        request.httpBody = httpBody
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Debug print the response
                if let httpResponse = response as? HTTPURLResponse {
                    print("Token exchange response status: \(httpResponse.statusCode)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Token exchange response: \(jsonString)")
                }
                return data
            }
            .decode(type: Token.self, decoder: JSONDecoder())
            .mapError { error in
                print("Token exchange error: \(error)")
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func verifyCredentials() -> AnyPublisher<Account, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/accounts/verify_credentials") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Account.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Timeline
    func getTimeline(type: TimelineType = .home, maxId: String? = nil, limit: Int = 20) -> AnyPublisher<[Status], Error> {
        let endpoint: String
        switch type {
        case .home:
            endpoint = "/api/v1/timelines/home"
        case .local:
            endpoint = "/api/v1/timelines/public?local=true"
        case .federated:
            endpoint = "/api/v1/timelines/public"
        }
        
        var urlComponents = URLComponents(string: "\(baseURL)\(endpoint)")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let maxId = maxId {
            queryItems.append(URLQueryItem(name: "max_id", value: maxId))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Status].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Status Actions
    func postStatus(content: String, visibility: String = "public", replyToId: String? = nil) -> AnyPublisher<Status, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/statuses") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var parameters: [String: Any] = [
            "status": content,
            "visibility": visibility
        ]
        
        if let replyToId = replyToId {
            parameters["in_reply_to_id"] = replyToId
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Status.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func favouriteStatus(id: String) -> AnyPublisher<Status, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/statuses/\(id)/favourite") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Status.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func unfavouriteStatus(id: String) -> AnyPublisher<Status, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/statuses/\(id)/unfavourite") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Status.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func reblogStatus(id: String) -> AnyPublisher<Status, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/statuses/\(id)/reblog") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Status.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func unreblogStatus(id: String) -> AnyPublisher<Status, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/statuses/\(id)/unreblog") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Status.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Search
    func search(query: String, type: SearchType? = nil) -> AnyPublisher<SearchResults, Error> {
        var urlComponents = URLComponents(string: "\(baseURL)/api/v2/search")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query)
        ]
        
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SearchResults.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Notifications
    func getNotifications(maxId: String? = nil, limit: Int = 20) -> AnyPublisher<[MastodonNotification], Error> {
        var urlComponents = URLComponents(string: "\(baseURL)/api/v1/notifications")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let maxId = maxId {
            queryItems.append(URLQueryItem(name: "max_id", value: maxId))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [MastodonNotification].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Account
    func getAccount(id: String) -> AnyPublisher<Account, Error> {
        guard let url = URL(string: "\(baseURL)/api/v1/accounts/\(id)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Account.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getAccountStatuses(id: String, maxId: String? = nil, limit: Int = 20) -> AnyPublisher<[Status], Error> {
        var urlComponents = URLComponents(string: "\(baseURL)/api/v1/accounts/\(id)/statuses")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let maxId = maxId {
            queryItems.append(URLQueryItem(name: "max_id", value: maxId))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Status].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// MARK: - Enums
enum TimelineType {
    case home
    case local
    case federated
}

enum SearchType: String {
    case accounts
    case hashtags
    case statuses
}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}