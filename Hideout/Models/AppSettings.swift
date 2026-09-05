import Foundation

public struct ExportSettings: Codable {
    public var darkTheme: Bool
    public var lang: String
    public var downloadTreeUri: String
    public var blacklist: [String]
    
    public init(darkTheme: Bool = true, lang: String = "ko", downloadTreeUri: String = "", blacklist: [String] = []) {
        self.darkTheme = darkTheme
        self.lang = lang
        self.downloadTreeUri = downloadTreeUri
        self.blacklist = blacklist
    }
}

public struct BackupWrapper: Codable {
    public let backup_data: String
}

public class AppSettings: ObservableObject {
    public static let shared = AppSettings()
    
    private let userDefaults = UserDefaults.standard
    
    private let keyDarkTheme = "hideout_is_dark_theme"
    private let keyLang = "hideout_app_language"
    private let keyNsfwEnabled = "hideout_is_nsfw_enabled"
    private let keyBlacklist = "hideout_blacklisted_tags"
    
    @Published public var isDarkTheme: Bool {
        didSet { userDefaults.set(isDarkTheme, forKey: keyDarkTheme) }
    }
    
    @Published public var appLanguage: String {
        didSet { userDefaults.set(appLanguage, forKey: keyLang) }
    }
    
    @Published public var isNsfwEnabled: Bool {
        didSet { userDefaults.set(isNsfwEnabled, forKey: keyNsfwEnabled) }
    }
    
    @Published public var blacklistedTags: Set<String> {
        didSet { userDefaults.set(Array(blacklistedTags), forKey: keyBlacklist) }
    }
    
    private init() {
        self.isDarkTheme = userDefaults.object(forKey: keyDarkTheme) as? Bool ?? true
        self.appLanguage = userDefaults.string(forKey: keyLang) ?? "ko"
        self.isNsfwEnabled = userDefaults.bool(forKey: keyNsfwEnabled)
        let savedBlacklist = userDefaults.stringArray(forKey: keyBlacklist) ?? []
        self.blacklistedTags = Set(savedBlacklist)
    }
    
    public var strings: AppStrings {
        return StringsManager.get(for: appLanguage)
    }
    
    public func addBlacklistTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty {
            blacklistedTags.insert(trimmed)
        }
    }
    
    public func removeBlacklistTag(_ tag: String) {
        blacklistedTags.remove(tag)
    }
    
    public func exportSettingsBase64() -> String? {
        let exportObj = ExportSettings(
            darkTheme: isDarkTheme,
            lang: appLanguage,
            downloadTreeUri: "",
            blacklist: Array(blacklistedTags)
        )
        guard let jsonData = try? JSONEncoder().encode(exportObj),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        let base64String = Data(jsonString.utf8).base64EncodedString()
        let wrapper = BackupWrapper(backup_data: base64String)
        guard let wrapperData = try? JSONEncoder().encode(wrapper) else {
            return nil
        }
        return String(data: wrapperData, encoding: .utf8)
    }
    
    public func importSettingsBase64(_ fileContent: String) -> Bool {
        guard let wrapperData = fileContent.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8),
              let wrapper = try? JSONDecoder().decode(BackupWrapper.self, from: wrapperData),
              let decodedData = Data(base64Encoded: wrapper.backup_data.trimmingCharacters(in: .whitespacesAndNewlines)),
              let exportObj = try? JSONDecoder().decode(ExportSettings.self, from: decodedData) else {
            return false
        }
        
        DispatchQueue.main.async {
            self.isDarkTheme = exportObj.darkTheme
            self.appLanguage = exportObj.lang
            self.blacklistedTags = Set(exportObj.blacklist)
        }
        return true
    }
}
