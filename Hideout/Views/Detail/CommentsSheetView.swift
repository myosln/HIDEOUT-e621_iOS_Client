import SwiftUI

public struct CommentsSheetView: View {
    @ObservedObject public var viewModel: DetailViewModel
    public let post: Post
    
    public init(viewModel: DetailViewModel, post: Post) {
        self.viewModel = viewModel
        self.post = post
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.darkSurface.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoadingComments {
                    VStack {
                        ProgressView()
                            .tint(.neonOrange)
                        Text("댓글을 불러오는 중...")
                            .font(.system(size: 14))
                            .foregroundColor(.portalGrey)
                            .padding(.top, 8)
                    }
                } else if viewModel.comments.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.portalGrey)
                        Text("등록된 댓글이 없습니다.")
                            .font(.system(size: 15))
                            .foregroundColor(.portalGrey)
                    }
                } else {
                    List(viewModel.comments) { comment in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(comment.creator_name ?? "익명")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.neonOrange)
                                
                                Spacer()
                                
                                if let score = comment.score {
                                    HStack(spacing: 2) {
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 10))
                                        Text("\(score)")
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                    .foregroundColor(score >= 0 ? .portalGrey : .red)
                                }
                            }
                            
                            Text(comment.body ?? "")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .lineSpacing(3)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.darkCard)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("댓글 (\(viewModel.comments.count))")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadComments(for: post.id)
            }
        }
    }
}
