import SwiftUI

public struct AccountLoginSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject public var networkService = NetworkService.shared
    
    @State private var username: String = ""
    @State private var apiKey: String = ""
    @State private var showApiKey: Bool = false
    @State private var toastMessage: String? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("e621 API 자격증명")) {
                    Text("e621.net -> 계정 관리 -> API Access에서 발급받은 API 키를 입력하세요.")
                        .font(.system(size: 13))
                        .foregroundColor(.portalGrey)
                    
                    TextField("사용자명 (Username)", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    HStack {
                        if showApiKey {
                            TextField("API Key", text: $apiKey)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            SecureField("API Key", text: $apiKey)
                        }
                        
                        Button(action: { showApiKey.toggle() }) {
                            Image(systemName: showApiKey ? "eye.slash" : "eye")
                                .foregroundColor(.portalGrey)
                        }
                    }
                }
                
                Section {
                    Button(action: saveCredentials) {
                        HStack {
                            Spacer()
                            Text("저장하기")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.neonOrange)
                    
                    if !networkService.username.isEmpty {
                        Button(action: logout) {
                            HStack {
                                Spacer()
                                Text("로그아웃")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("계정 로그인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonOrange)
                }
            }
            .onAppear {
                self.username = networkService.username
                self.apiKey = networkService.apiKey
            }
        }
    }
    
    private func saveCredentials() {
        let trimmedUser = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        networkService.updateCredentials(user: trimmedUser, key: trimmedKey)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func logout() {
        networkService.updateCredentials(user: "", key: "")
        self.username = ""
        self.apiKey = ""
        presentationMode.wrappedValue.dismiss()
    }
}
