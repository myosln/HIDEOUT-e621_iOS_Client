import SwiftUI

public struct MainContainerView: View {
    @StateObject private var feedViewModel = FeedViewModel()
    @StateObject private var appSettings = AppSettings.shared
    @StateObject private var downloadManager = DownloadManager.shared
    
    @State private var isDrawerOpen: Bool = false
    @State private var selectedPost: Post? = nil
    @State private var showLoginSheet: Bool = false
    @State private var showBlacklistSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.deepBlack.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                SearchBarView(viewModel: feedViewModel) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isDrawerOpen = true
                    }
                }
                .padding(.top, 8)
                .background(Color.deepBlack)
                
                PostGridView(viewModel: feedViewModel) { post in
                    selectedPost = post
                }
            }
            
            SidebarDrawerView(
                isOpen: $isDrawerOpen,
                onOpenLogin: { showLoginSheet = true },
                onOpenBlacklist: { showBlacklistSheet = true },
                onOpenSettings: { showSettingsSheet = true }
            )
            
            if let toast = downloadManager.toastMessage {
                VStack {
                    Spacer()
                    Text(toast)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.neonOrange.opacity(0.6), lineWidth: 1)
                        )
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            downloadManager.toastMessage = nil
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedPost) { post in
            let detailVM = DetailViewModel(posts: feedViewModel.posts, initialPost: post)
            PostDetailPagerView(
                viewModel: detailVM,
                onClose: { selectedPost = nil },
                onSearchTag: { tag in
                    feedViewModel.searchQuery = tag
                    feedViewModel.loadInitialPosts()
                },
                onDownload: { downloadPost in
                    downloadManager.downloadPostMedia(post: downloadPost)
                }
            )
        }
        .sheet(isPresented: $showLoginSheet) {
            AccountLoginSheet()
        }
        .sheet(isPresented: $showBlacklistSheet) {
            BlacklistSheet()
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
        }
        .sheet(isPresented: $feedViewModel.showCloudflareChallenge) {
            CloudflareModalView {
                feedViewModel.loadInitialPosts()
            }
        }
        .onAppear {
            feedViewModel.loadInitialPosts()
        }
    }
}
