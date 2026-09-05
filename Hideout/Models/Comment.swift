import Foundation

public struct Comment: Identifiable, Codable, Hashable {
    public let id: Int?
    public let post_id: Int?
    public let creator_name: String?
    public let body: String?
    public let score: Int?
    public let created_at: String?
    
    public init(
        id: Int? = nil,
        post_id: Int? = nil,
        creator_name: String? = nil,
        body: String? = nil,
        score: Int? = 0,
        created_at: String? = nil
    ) {
        self.id = id
        self.post_id = post_id
        self.creator_name = creator_name
        self.body = body
        self.score = score
        self.created_at = created_at
    }
}
