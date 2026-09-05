import SwiftUI

public struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject public var appSettings = AppSettings.shared
    @ObservedObject public var downloadManager = DownloadManager.shared
    
    @State private var cacheSizeString: String = ""
    @State private var showImportAlert: Bool = false
    @State private var importInputText: String = ""
    @State private var toastMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일반 설정")) {
                    Toggle("다크 모드 (Dark Mode)", isOn: $appSettings.isDarkTheme)
                    
                    Picker("언어 (Language)", selection: $appSettings.appLanguage) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                    }
                }
                
                Section(header: Text("캐시 관리")) {
                    HStack {
                        Text("현재 저장된 캐시")
                        Spacer()
                        Text(cacheSizeString)
                            .foregroundColor(.portalGrey)
                    }
                    
                    Button(action: clearCache) {
                        HStack {
                            Text("캐시 비우기")
                                .foregroundColor(.red)
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("설정 백업 및 복원 (안드로이드 호환)")) {
                    Button(action: exportSettings) {
                        HStack {
                            Text("설정 내보내기 (JSON 복사)")
                                .foregroundColor(.neonOrange)
                            Spacer()
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.neonOrange)
                        }
                    }
                    
                    Button(action: { showImportAlert = true }) {
                        HStack {
                            Text("설정 불러오기 (JSON 붙여넣기)")
                                .foregroundColor(.neonOrange)
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.neonOrange)
                        }
                    }
                }
                
                Section(header: Text("네트워크 우회 안내")) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "network.badge.shield.half.filled")
                                .foregroundColor(.neonOrange)
                            Text("iOS 통신사 차단 우회 가이드")
                                .font(.system(size: 14, weight: .bold))
                        }
                        Text("iOS 환경에서는 Mullvad VPN, WireGuard, 1.1.1.1 등 기기에 설치된 공식 VPN 앱을 켜두시면 HIDEOUT 앱 내의 모든 탐색과 다운로드가 안전하게 동작합니다.")
                            .font(.system(size: 12))
                            .foregroundColor(.portalGrey)
                            .lineSpacing(3)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0 (iOS)")
                            .foregroundColor(.portalGrey)
                    }
                    
                    if let githubUrl = URL(string: "https://github.com/Canned-F0xy/HIDEOUT-e621_Android_Client") {
                        Link(destination: githubUrl) {
                            HStack {
                                Text("GitHub 원작자 리포지토리")
                                    .foregroundColor(.neonOrange)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .foregroundColor(.portalGrey)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
            }
            .navigationTitle("앱 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonOrange)
                }
            }
            .onAppear {
                updateCacheSize()
            }
            .alert("설정 복원", isPresented: $showImportAlert) {
                TextField("Base64 JSON 백업 데이터 붙여넣기", text: $importInputText)
                Button("복원", action: importSettings)
                Button("취소", role: .cancel) {}
            } message: {
                Text("안드로이드 또는 iOS HIDEOUT에서 내보낸 백업 코드를 붙여넣으세요.")
            }
        }
    }
    
    private func updateCacheSize() {
        cacheSizeString = downloadManager.getFormattedCacheSize()
    }
    
    private func clearCache() {
        downloadManager.clearCache()
        updateCacheSize()
    }
    
    private func exportSettings() {
        guard let backupStr = appSettings.exportSettingsBase64() else { return }
        UIPasteboard.general.string = backupStr
    }
    
    private func importSettings() {
        guard !importInputText.isEmpty else { return }
        _ = appSettings.importSettingsBase64(importInputText)
        importInputText = ""
    }
}
