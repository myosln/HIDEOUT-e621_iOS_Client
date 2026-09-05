import SwiftUI

public struct BlacklistSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject public var appSettings = AppSettings.shared
    
    @State private var inputTag: String = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    TextField("차단할 태그 입력 (예: gore, feral)...", text: $inputTag)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.darkCard)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onSubmit {
                            addTag()
                        }
                    
                    Button(action: addTag) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.neonOrange)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Text("블랙리스트에 등록된 태그는 검색 결과에서 자동으로 제외됩니다.")
                    .font(.system(size: 12))
                    .foregroundColor(.portalGrey)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(appSettings.blacklistedTags).sorted(), id: \.self) { tag in
                            HStack(spacing: 6) {
                                Text(tag)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    appSettings.removeBlacklistTag(tag)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.darkCard)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Color.darkSurface.edgesIgnoringSafeArea(.all))
            .navigationTitle("블랙리스트 관리 (\(appSettings.blacklistedTags.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.neonOrange)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = inputTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmed.isEmpty {
            appSettings.addBlacklistTag(trimmed)
            inputTag = ""
        }
    }
}
