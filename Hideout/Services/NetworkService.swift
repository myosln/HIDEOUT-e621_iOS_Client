import Foundation

public class NetworkService: ObservableObject {
    public static let shared = NetworkService()
    
    private let baseUrl = "https://e621.net/"
    public static let defaultUserAgent = "HideoutApp/1.0 (by CannedF0xy on e621; iOS Client)"
    
    @Published public var username: String = ""
    @Published public var apiKey: String = ""
    @Published public var cfClearance: String = ""
    
    public var onCloudflareChallenge: (() -> Void)?
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        return URLSession(configuration: config)
    }()
    
    private init() {
        self.username = KeychainHelper.shared.read(key: .username) ?? ""
        self.apiKey = KeychainHelper.shared.read(key: .apiKey) ?? ""
        self.cfClearance = KeychainHelper.shared.read(key: .cfClearance) ?? ""
    }
    
    public func updateCredentials(user: String, key: String) {
        self.username = user
        self.apiKey = key
        KeychainHelper.shared.save(key: .username, value: user)
        KeychainHelper.shared.save(key: .apiKey, value: key)
    }
    
    public func updateCfClearance(_ cookie: String) {
        self.cfClearance = cookie
        KeychainHelper.shared.save(key: .cfClearance, value: cookie)
    }
    
    private func createRequest(path: String, method: String = "GET", queryItems: [URLQueryItem] = []) -> URLRequest? {
        guard var components = URLComponents(string: baseUrl + path) else { return nil }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(Self.defaultUserAgent, forHTTPHeaderField: "User-Agent")
        
        if !cfClearance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && cfClearance != "bypass" {
            request.setValue(cfClearance, forHTTPHeaderField: "Cookie")
        }
        
        if !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
           !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let authString = "\(username):\(apiKey)"
            if let authData = authString.data(using: .utf8) {
                let base64Auth = authData.base64EncodedString()
                request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    public func fetchPosts(
        query: String,
        page: Int,
        limit: Int = 20,
        isNsfwEnabled: Bool,
        blacklistedTags: Set<String>
    ) async throws -> [Post] {
        var finalTag = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if finalTag == "#HOT#" {
            finalTag = "date:>=7_days_ago order:score"
        }
        
        if !isNsfwEnabled && !finalTag.contains("rating:") {
            finalTag = finalTag.isEmpty ? "rating:safe" : "\(finalTag) rating:safe"
        }
        
        if !blacklistedTags.isEmpty {
            let negated = blacklistedTags.map { "-\($0)" }.joined(separator: " ")
            finalTag = finalTag.isEmpty ? negated : "\(finalTag) \(negated)"
        }
        
        let queryItems = [
            URLQueryItem(name: "tags", value: finalTag),
            URLQueryItem(name: "limit", value: "\(min(limit, 30))"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let request = createRequest(path: "posts.json", queryItems: queryItems) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 503 {
                DispatchQueue.main.async { self.onCloudflareChallenge?() }
                throw URLError(.userAuthenticationRequired)
            }
            if httpResponse.statusCode == 401 {
                throw URLError(.userAuthenticationRequired)
            }
        }
        
        let decoded = try JSONDecoder().decode(E621Response.self, from: data)
        return decoded.posts ?? []
    }
    
    public func fetchAutocomplete(query: String) async -> [AutocompleteTag] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        let queryItems = [
            URLQueryItem(name: "search[name_matches]", value: query.trimmingCharacters(in: .whitespacesAndNewlines))
        ]
        guard let request = createRequest(path: "tags/autocomplete.json", queryItems: queryItems) else { return [] }
        
        do {
            let (data, _) = try await session.data(for: request)
            return (try? JSONDecoder().decode([AutocompleteTag].self, from: data)) ?? []
        } catch {
            return []
        }
    }
    
    public func fetchComments(postId: Int) async -> [Comment] {
        let queryItems = [
            URLQueryItem(name: "search[post_id]", value: "\(postId)")
        ]
        guard let request = createRequest(path: "comments.json", queryItems: queryItems) else { return [] }
        
        do {
            let (data, _) = try await session.data(for: request)
            return (try? JSONDecoder().decode([Comment].self, from: data)) ?? []
        } catch {
            return []
        }
    }
    
    public func toggleFavorite(postId: Int, currentFav: Bool) async -> Bool {
        if currentFav {
            guard let request = createRequest(path: "favorites/\(postId).json", method: "DELETE") else { return false }
            do {
                let (_, response) = try await session.data(for: request)
                return (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 204
            } catch {
                return false
            }
        } else {
            guard var request = createRequest(path: "favorites.json", method: "POST") else { return false }
            let bodyString = "post_id=\(postId)"
            request.httpBody = bodyString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            do {
                let (_, response) = try await session.data(for: request)
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                return status >= 200 && status < 300
            } catch {
                return false
            }
        }
    }
}
