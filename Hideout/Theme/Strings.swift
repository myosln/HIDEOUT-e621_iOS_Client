import Foundation

public protocol AppStrings {
    var hideoutTitle: String { get }
    var accountLogin: String { get }
    var apiKeyInfo: String { get }
    var usernameHint: String { get }
    var apiKeyHint: String { get }
    var save: String { get }
    var logout: String { get }
    var cancel: String { get }
    var loginSuccess: String { get }
    var loginFailed: String { get }
    var authFailed: String { get }
    var error403: String { get }
    var errorTooManyTags: String { get }
    var error451: String { get }
    func networkError(_ msg: String) -> String
    var networkErrorOccurred: String { get }
    var blacklistManagement: String { get }
    var blacklistInfo: String { get }
    var tagInputHint: String { get }
    var appSettings: String { get }
    var useDarkTheme: String { get }
    var appLanguage: String { get }
    var cacheManagement: String { get }
    var currentCacheSize: String { get }
    var clearCache: String { get }
    var cacheCleared: String { get }
    var exportSettings: String { get }
    var importSettings: String { get }
    var backupSuccess: String { get }
    var backupFailed: String { get }
    var restoreSuccess: String { get }
    var restoreFailed: String { get }
    var downloadStarting: String { get }
    func downloadFailed(_ msg: String) -> String
    var downloadComplete: String { get }
    var savedToPhotos: String { get }
    var r18FilterOn: String { get }
    var r18FilterOff: String { get }
    var hotPosts: String { get }
    var comments: String { get }
    var noComments: String { get }
    var pools: String { get }
    var relatedPosts: String { get }
    var copyLink: String { get }
    var share: String { get }
    var vpnNoticeTitle: String { get }
    var vpnNoticeBody: String { get }
}

public struct KoStrings: AppStrings {
    public init() {}
    public let hideoutTitle = "HIDEOUT"
    public let accountLogin = "계정 로그인"
    public let apiKeyInfo = "e621.net -> 계정 관리 -> API Access에서 발급받은 API 키를 입력하세요."
    public let usernameHint = "e621 사용자명"
    public let apiKeyHint = "API Key"
    public let save = "저장"
    public let logout = "로그아웃"
    public let cancel = "취소"
    public let loginSuccess = "로그인되었습니다."
    public let loginFailed = "로그인 정보 저장 실패"
    public let authFailed = "인증 실패: 사용자명과 API 키를 확인해주세요."
    public let error403 = "Cloudflare 차단 감지 (403). 캡차를 통과하세요."
    public let errorTooManyTags = "태그 검색 한도 초과 (최대 4개)"
    public let error451 = "국가 또는 저작권 사유로 차단된 콘텐츠입니다 (451)"
    public func networkError(_ msg: String) -> String { "네트워크 오류: \(msg)" }
    public let networkErrorOccurred = "네트워크 통신 중 오류가 발생했습니다."
    public let blacklistManagement = "블랙리스트 관리"
    public let blacklistInfo = "숨기고 싶은 태그를 입력하고 엔터를 누르세요."
    public let tagInputHint = "태그 입력 (예: gore, feral)"
    public let appSettings = "앱 설정"
    public let useDarkTheme = "다크 모드 사용"
    public let appLanguage = "언어 (Language)"
    public let cacheManagement = "캐시 관리"
    public let currentCacheSize = "현재 캐시 용량"
    public let clearCache = "캐시 비우기"
    public let cacheCleared = "캐시가 삭제되었습니다."
    public let exportSettings = "설정 내보내기 (JSON 백업)"
    public let importSettings = "설정 불러오기 (JSON 복원)"
    public let backupSuccess = "설정이 클립보드 및 파일로 백업되었습니다."
    public let backupFailed = "설정 백업 생성 실패"
    public let restoreSuccess = "설정을 성공적으로 복원했습니다."
    public let restoreFailed = "설정 복원 실패: 잘못된 포맷입니다."
    public let downloadStarting = "미디어 다운로드를 시작합니다..."
    public func downloadFailed(_ msg: String) -> String { "다운로드 실패: \(msg)" }
    public let downloadComplete = "다운로드 완료 (보안 보관소에 저장됨)"
    public let savedToPhotos = "사진첩에 저장되었습니다."
    public let r18FilterOn = "R-18 모드 ON"
    public let r18FilterOff = "Safe 모드 ON"
    public let hotPosts = "인기 포스트 (#HOT#)"
    public let comments = "댓글"
    public let noComments = "등록된 댓글이 없습니다."
    public let pools = "앨범 (Pools)"
    public let relatedPosts = "연관 포스트 묶어보기"
    public let copyLink = "링크 복사"
    public let share = "공유"
    public let vpnNoticeTitle = "iOS 네트워크 우회 안내"
    public let vpnNoticeBody = "국내 ISP 차단을 우회하려면 기기에 설치된 Mullvad VPN, WireGuard, 1.1.1.1 등 공식 VPN 앱을 연결한 후 사용하세요."
}

public struct EnStrings: AppStrings {
    public init() {}
    public let hideoutTitle = "HIDEOUT"
    public let accountLogin = "Account Login"
    public let apiKeyInfo = "Enter your API Key obtained from e621.net -> Manage Account -> API Access."
    public let usernameHint = "e621 Username"
    public let apiKeyHint = "API Key"
    public let save = "Save"
    public let logout = "Logout"
    public let cancel = "Cancel"
    public let loginSuccess = "Logged in successfully."
    public let loginFailed = "Failed to save login credentials"
    public let authFailed = "Authentication failed: Please check your username and API key."
    public let error403 = "Cloudflare Challenge Detected (403). Please solve captcha."
    public let errorTooManyTags = "Tag limit exceeded (Max 4 tags)"
    public let error451 = "Content blocked due to legal/regional reason (451)"
    public func networkError(_ msg: String) -> String { "Network error: \(msg)" }
    public let networkErrorOccurred = "An error occurred during network communication."
    public let blacklistManagement = "Blacklist Management"
    public let blacklistInfo = "Enter tags you want to hide and press enter."
    public let tagInputHint = "Enter tag (e.g. gore, feral)"
    public let appSettings = "Settings"
    public let useDarkTheme = "Dark Mode"
    public let appLanguage = "Language"
    public let cacheManagement = "Cache Management"
    public let currentCacheSize = "Current Cache Size"
    public let clearCache = "Clear Cache"
    public let cacheCleared = "Cache cleared."
    public let exportSettings = "Export Settings (JSON Backup)"
    public let importSettings = "Import Settings (JSON Restore)"
    public let backupSuccess = "Settings backed up to clipboard and file."
    public let backupFailed = "Failed to create backup"
    public let restoreSuccess = "Settings restored successfully."
    public let restoreFailed = "Restore failed: Invalid format."
    public let downloadStarting = "Starting media download..."
    public func downloadFailed(_ msg: String) -> String { "Download failed: \(msg)" }
    public let downloadComplete = "Download completed (Saved in secure storage)"
    public let savedToPhotos = "Saved to Photos."
    public let r18FilterOn = "R-18 Mode ON"
    public let r18FilterOff = "Safe Mode ON"
    public let hotPosts = "Hot Posts (#HOT#)"
    public let comments = "Comments"
    public let noComments = "No comments available."
    public let pools = "Pools"
    public let relatedPosts = "Related Posts"
    public let copyLink = "Copy Link"
    public let share = "Share"
    public let vpnNoticeTitle = "iOS Network Bypass Guide"
    public let vpnNoticeBody = "To bypass regional ISP blocks, please activate an external VPN app (Mullvad, WireGuard, or 1.1.1.1) on your device."
}

public enum StringsManager {
    public static func get(for lang: String) -> AppStrings {
        if lang.lowercased().starts(with: "ko") {
            return KoStrings()
        } else {
            return EnStrings()
        }
    }
}
