import SwiftUI

public struct AutocompleteTag: Identifiable, Codable, Hashable {
    public let id: Int
    public let name: String
    public let post_count: Int
    public let category: Int
    
    public init(id: Int, name: String, post_count: Int, category: Int) {
        self.id = id
        self.name = name
        self.post_count = post_count
        self.category = category
    }
    
    public var categoryColor: Color {
        switch category {
        case 1: return .tagArtist
        case 3: return .tagCopyright
        case 4: return .tagCharacter
        case 5: return .tagSpecies
        case 7: return .tagMeta
        default: return .tagGeneral
        }
    }
    
    public var categoryName: String {
        switch category {
        case 1: return "Artist"
        case 3: return "Copyright"
        case 4: return "Character"
        case 5: return "Species"
        case 7: return "Meta"
        default: return "General"
        }
    }
}
