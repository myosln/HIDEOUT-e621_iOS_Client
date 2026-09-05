import SwiftUI

@main
public struct HideoutApp: App {
    @StateObject private var appSettings = AppSettings.shared
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainContainerView()
                .preferredColorScheme(appSettings.isDarkTheme ? .dark : .light)
                .background(appSettings.isDarkTheme ? Color.deepBlack : Color.lightBg)
        }
    }
}
