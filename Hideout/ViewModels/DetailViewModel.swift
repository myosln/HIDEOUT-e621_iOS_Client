import SwiftUI

@MainActor
public class DetailViewModel: ObservableObject {
    @Published public var posts: [Post]
    @Published public var currentIndex: Int
    @Published public var comments: [Comment] = []
    @Published public var isLoadingComments: Bool = false
    @Published public var showInfoSheet: Bool = false
    @Published public var showCommentsSheet: Bool = false
    
    @Published public var favoriteStates: [Int: Bool] = [:]
    @Published public var scoreStates: [Int: Int] = [:]
    
    private let networkService = NetworkService.shared
    
    public init(posts: [Post], initialPost: Post) {
        self.posts = posts
        let idx = posts.firstIndex(where: { $0.id == initialPost.id }) ?? 0
        self.currentIndex = idx
    }
    
    public var currentPost: Post? {
        guard currentIndex >= 0 && currentIndex < posts.count else { return nil }
        return posts[currentIndex]
    }
    
    public func isFavorited(post: Post) -> Bool {
        return favoriteStates[post.id] ?? (post.is_favorited ?? false)
    }
    
    public func getScore(post: Post) -> Int {
        return scoreStates[post.id] ?? (post.score?.total ?? 0)
    }
    
    public func toggleFavorite(post: Post) {
        let currentFav = isFavorited(post: post)
        let currentScore = getScore(post: post)
        let newFav = !currentFav
        let newScore = currentScore + (newFav ? 1 : -1)
        
        favoriteStates[post.id] = newFav
        scoreStates[post.id] = newScore
        
        Task {
            let success = await networkService.toggleFavorite(postId: post.id, currentFav: currentFav)
            if !success {
                self.favoriteStates[post.id] = currentFav
                self.scoreStates[post.id] = currentScore
            }
        }
    }
    
    public func loadComments(for postId: Int) {
        isLoadingComments = true
        comments = []
        Task {
            let fetched = await networkService.fetchComments(postId: postId)
            self.comments = fetched
            self.isLoadingComments = false
        }
    }
}
