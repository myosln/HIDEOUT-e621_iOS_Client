import Foundation

public struct E621Response: Codable {
    public let posts: [Post]?
}

public struct Post: Identifiable, Codable, Hashable {
    public let id: Int
    public let file: FileData?
    public let preview: PreviewData?
    public let sample: SampleData?
    public let tags: TagsData?
    public let score: ScoreData?
    public let description: String?
    public let sources: [String]?
    public var is_favorited: Bool?
    public let relationships: RelationshipsData?
    public let duration: Double?
    public let pools: [Int]?
    
    public init(
        id: Int,
        file: FileData? = nil,
        preview: PreviewData? = nil,
        sample: SampleData? = nil,
        tags: TagsData? = nil,
        score: ScoreData? = nil,
        description: String? = nil,
        sources: [String]? = nil,
        is_favorited: Bool? = false,
        relationships: RelationshipsData? = nil,
        duration: Double? = nil,
        pools: [Int]? = nil
    ) {
        self.id = id
        self.file = file
        self.preview = preview
        self.sample = sample
        self.tags = tags
        self.score = score
        self.description = description
        self.sources = sources
        self.is_favorited = is_favorited
        self.relationships = relationships
        self.duration = duration
        self.pools = pools
    }
    
    public var bestMediaUrl: String? {
        return file?.url ?? sample?.url ?? preview?.url
    }
    
    public var isVideo: Bool {
        guard let ext = file?.ext?.lowercased() else { return (duration ?? 0) > 0 }
        return ext == "webm" || ext == "mp4" || (duration ?? 0) > 0
    }
    
    public var formattedDuration: String {
        guard let duration = duration, duration > 0 else { return "" }
        let totalSeconds = Int(duration)
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    public func getAllRelatedIdsQuery() -> String? {
        guard let rel = relationships else { return nil }
        var ids: [Int] = []
        if let parentId = rel.parent_id {
            ids.append(parentId)
        }
        if rel.has_children && !rel.children.isEmpty {
            ids.append(contentsOf: rel.children)
        }
        if rel.parent_id == nil && rel.has_children {
            ids.append(id)
        }
        guard !ids.isEmpty else { return nil }
        let uniqueIds = Array(Set(ids))
        return "id:" + uniqueIds.map { String($0) }.joined(separator: ",")
    }
}

public struct FileData: Codable, Hashable {
    public let url: String?
    public let ext: String?
    public let md5: String?
}

public struct PreviewData: Codable, Hashable {
    public let url: String?
}

public struct SampleData: Codable, Hashable {
    public let url: String?
}

public struct RelationshipsData: Codable, Hashable {
    public let parent_id: Int?
    public let has_children: Bool
    public let children: [Int]
    
    enum CodingKeys: String, CodingKey {
        case parent_id
        case has_children
        case children
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parent_id = try container.decodeIfPresent(Int.self, forKey: .parent_id)
        self.has_children = try container.decodeIfPresent(Bool.self, forKey: .has_children) ?? false
        self.children = try container.decodeIfPresent([Int].self, forKey: .children) ?? []
    }
}

public struct ScoreData: Codable, Hashable {
    public let total: Int?
}

public struct TagsData: Codable, Hashable {
    public let general: [String]?
    public let artist: [String]?
    public let character: [String]?
    public let copyright: [String]?
    public let species: [String]?
    public let meta: [String]?
    
    public init(
        general: [String]? = [],
        artist: [String]? = [],
        character: [String]? = [],
        copyright: [String]? = [],
        species: [String]? = [],
        meta: [String]? = []
    ) {
        self.general = general
        self.artist = artist
        self.character = character
        self.copyright = copyright
        self.species = species
        self.meta = meta
    }
}
