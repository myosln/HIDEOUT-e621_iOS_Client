import SwiftUI

public struct SidebarDrawerView: View {
    @Binding public var isOpen: Bool
    public let onOpenLogin: () -> Void
    public let onOpenBlacklist: () -> Void
    public let onOpenSettings: () -> Void
    
    public init(
        isOpen: Binding<Bool>,
        onOpenLogin: @escaping () -> Void,
        onOpenBlacklist: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self._isOpen = isOpen
        self.onOpenLogin = onOpenLogin
        self.onOpenBlacklist = onOpenBlacklist
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if isOpen {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }
            }
            
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Text("🦊")
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("HIDEOUT")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.neonOrange)
                                Text("e621 iOS Client")
                                    .font(.system(size: 12))
                                    .foregroundColor(.portalGrey)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 24)
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(spacing: 6) {
                        drawerItem(icon: "person.crop.circle.fill", title: "계정 로그인") {
                            isOpen = false
                            onOpenLogin()
                        }
                        
                        drawerItem(icon: "eye.slash.fill", title: "블랙리스트 관리") {
                            isOpen = false
                            onOpenBlacklist()
                        }
                        
                        drawerItem(icon: "gearshape.fill", title: "앱 설정") {
                            isOpen = false
                            onOpenSettings()
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("v1.0.0 (iOS Edition)")
                            .font(.system(size: 11))
                            .foregroundColor(.portalGrey)
                        Text("Based on HIDEOUT by CannedF0xy")
                            .font(.system(size: 11))
                            .foregroundColor(.portalGrey.opacity(0.7))
                    }
                    .padding(20)
                }
                .frame(width: 280)
                .background(Color.darkSurface.edgesIgnoringSafeArea(.all))
                .offset(x: isOpen ? 0 : -280)
                .animation(.easeInOut(duration: 0.25), value: isOpen)
                
                Spacer()
            }
        }
    }
    
    private func drawerItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.neonOrange)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
    }
}
