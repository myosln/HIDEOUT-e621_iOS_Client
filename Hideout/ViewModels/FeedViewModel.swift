import SwiftUI
import Combine

@MainActor
public class FeedViewModel: ObservableObject {
    @Published public var posts: [Post] = []
    @Published public var isLoading: Bool = false
    @Published public var isLoadingMore: Bool = false
    @Published public var errorMessage: String? = nil
    
    @Published public var searchQuery: String = ""
    @Published public var tagSuggestions: [AutocompleteTag] = []
    @Published public var showCloudflareChallenge: Bool = false
    
    private var currentPage: Int = 1
    private var canLoadMore: Bool = true
    private var autocompleteTask: Task<Void, Never>? = nil
    
    private let networkService = NetworkService.shared
    private let appSettings = AppSettings.shared
    
    public init() {
        networkService.onCloudflareChallenge = { [weak self] in
            DispatchQueue.main.async {
                self?.showCloudflareChallenge = true
            }
        }
    }
    
    public func loadInitialPosts(query: String? = nil) {
        if let query = query {
            self.searchQuery = query
        }
        currentPage = 1
        canLoadMore = true
        posts = []
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedPosts = try await networkService.fetchPosts(
                    query: searchQuery,
                    page: 1,
                    limit: 20,
                    isNsfwEnabled: appSettings.isNsfwEnabled,
                    blacklistedTags: appSettings.blacklistedTags
                )
                self.posts = fetchedPosts
                self.canLoadMore = fetchedPosts.count >= 10
                self.currentPage = 2
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    public func loadMorePostsIfNeeded(currentPost: Post) {
        guard canLoadMore, !isLoading, !isLoadingMore else { return }
        
        guard let index = posts.firstIndex(where: { $0.id == currentPost.id }),
              index >= posts.count - 4 else { return }
        
        isLoadingMore = true
        Task {
            do {
                let nextPagePosts = try await networkService.fetchPosts(
                    query: searchQuery,
                    page: currentPage,
                    limit: 20,
                    isNsfwEnabled: appSettings.isNsfwEnabled,
                    blacklistedTags: appSettings.blacklistedTags
                )
                if nextPagePosts.isEmpty {
                    self.canLoadMore = false
                } else {
                    let existingIds = Set(self.posts.map { $0.id })
                    let newPosts = nextPagePosts.filter { !existingIds.contains($0.id) }
                    self.posts.append(contentsOf: newPosts)
                    self.currentPage += 1
                    self.canLoadMore = nextPagePosts.count >= 10
                }
            } catch {
            }
            self.isLoadingMore = false
        }
    }
    
    public func updateAutocomplete(for query: String) {
        autocompleteTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            tagSuggestions = []
            return
        }
        
        let lastWord = trimmed.components(separatedBy: .whitespaces).last ?? trimmed
        guard !lastWord.isEmpty, !lastWord.starts(with: "-"), !lastWord.starts(with: "#") else {
            tagSuggestions = []
            return
        }
        
        autocompleteTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            let tags = await networkService.fetchAutocomplete(query: lastWord)
            guard !Task.isCancelled else { return }
            self.tagSuggestions = tags
        }
    }
    
    public func selectSuggestion(_ tag: AutocompleteTag) {
        var words = searchQuery.components(separatedBy: .whitespaces)
        if !words.isEmpty {
            words.removeLast()
        }
        words.append(tag.name)
        searchQuery = words.joined(separator: " ") + " "
        tagSuggestions = []
        loadInitialPosts()
    }
    
    public func toggleNsfw() {
        appSettings.isNsfwEnabled.toggle()
        loadInitialPosts()
    }
}
