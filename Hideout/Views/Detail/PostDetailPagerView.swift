import SwiftUI

public struct PostDetailPagerView: View {
    @ObservedObject public var viewModel: DetailViewModel
    public let onClose: () -> Void
    public let onSearchTag: (String) -> Void
    public let onDownload: (Post) -> Void
    
    @State private var showControls: Bool = true
    
    public init(
        viewModel: DetailViewModel,
        onClose: @escaping () -> Void,
        onSearchTag: @escaping (String) -> Void,
        onDownload: @escaping (Post) -> Void
    ) {
        self.viewModel = viewModel
        self.onClose = onClose
        self.onSearchTag = onSearchTag
        self.onDownload = onDownload
    }
    
    public var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            TabView(selection: $viewModel.currentIndex) {
                ForEach(Array(viewModel.posts.enumerated()), id: \.element.id) { index, post in
                    ZStack {
                        if post.isVideo, let videoUrl = post.bestMediaUrl {
                            VideoPlayerView(videoUrl: videoUrl)
                        } else if let imageUrl = post.bestMediaUrl {
                            ZoomableImageView(urlString: imageUrl)
                        }
                    }
                    .tag(index)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showControls.toggle()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            if showControls {
                VStack {
                    HStack {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("\(viewModel.currentIndex + 1) / \(viewModel.posts.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(14)
                        
                        Spacer()
                        
                        if let post = viewModel.currentPost,
                           let shareUrl = URL(string: "https://e621.net/posts/\(post.id)") {
                            ShareLink(item: shareUrl) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 48)
                    
                    Spacer()
                    
                    if let post = viewModel.currentPost {
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.toggleFavorite(post: post)
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: viewModel.isFavorited(post: post) ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isFavorited(post: post) ? .red : .white)
                                    Text("\(viewModel.getScore(post: post))")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.showCommentsSheet = true
                            }) {
                                Image(systemName: "bubble.left.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                viewModel.showInfoSheet = true
                            }) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.neonOrange)
                                    .padding(10)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                onDownload(post)
                            }) {
                                Image(systemName: "arrow.down.to.line")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.neonOrange)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 36)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showInfoSheet) {
            if let post = viewModel.currentPost {
                PostInfoSheetView(
                    post: post,
                    onSearchTag: { tag in
                        viewModel.showInfoSheet = false
                        onClose()
                        onSearchTag(tag)
                    },
                    onOpenRelatedQuery: { query in
                        viewModel.showInfoSheet = false
                        onClose()
                        onSearchTag(query)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showCommentsSheet) {
            if let post = viewModel.currentPost {
                CommentsSheetView(viewModel: viewModel, post: post)
            }
        }
    }
}
