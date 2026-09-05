import SwiftUI

public struct PostGridView: View {
    @ObservedObject public var viewModel: FeedViewModel
    public let onSelectPost: (Post) -> Void
    
    public init(viewModel: FeedViewModel, onSelectPost: @escaping (Post) -> Void) {
        self.viewModel = viewModel
        self.onSelectPost = onSelectPost
    }
    
    private var leftColumnPosts: [Post] {
        viewModel.posts.enumerated().compactMap { index, post in
            index % 2 == 0 ? post : nil
        }
    }
    
    private var rightColumnPosts: [Post] {
        viewModel.posts.enumerated().compactMap { index, post in
            index % 2 != 0 ? post : nil
        }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        VStack(spacing: 10) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.darkCard)
                                    .frame(height: CGFloat.random(in: 160...240))
                                    .shimmerEffect()
                            }
                        }
                        VStack(spacing: 10) {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.darkCard)
                                    .frame(height: CGFloat.random(in: 160...240))
                                    .shimmerEffect()
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                } else if viewModel.posts.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 12) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.portalGrey)
                        Text("검색 결과가 없습니다.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.portalGrey)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        LazyVStack(spacing: 10) {
                            ForEach(leftColumnPosts) { post in
                                PostCardView(post: post) {
                                    onSelectPost(post)
                                }
                                .onAppear {
                                    viewModel.loadMorePostsIfNeeded(currentPost: post)
                                }
                            }
                        }
                        
                        LazyVStack(spacing: 10) {
                            ForEach(rightColumnPosts) { post in
                                PostCardView(post: post) {
                                    onSelectPost(post)
                                }
                                .onAppear {
                                    viewModel.loadMorePostsIfNeeded(currentPost: post)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    
                    if viewModel.isLoadingMore {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.neonOrange)
                            Text("불러오는 중...")
                                .font(.system(size: 13))
                                .foregroundColor(.portalGrey)
                        }
                        .padding(.vertical, 16)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .refreshable {
            viewModel.loadInitialPosts()
        }
    }
}
