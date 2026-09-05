import SwiftUI

public struct SearchBarView: View {
    @ObservedObject public var viewModel: FeedViewModel
    @ObservedObject public var appSettings = AppSettings.shared
    public let onOpenDrawer: () -> Void
    
    @State private var isSearching: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    public init(viewModel: FeedViewModel, onOpenDrawer: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onOpenDrawer = onOpenDrawer
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Button(action: onOpenDrawer) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.neonOrange)
                        .frame(width: 36, height: 36)
                        .background(Color.darkCard)
                        .clipShape(Circle())
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.portalGrey)
                        .font(.system(size: 15))
                    
                    TextField("태그 검색 (예: feral, fox)...", text: $viewModel.searchQuery)
                        .focused($isFieldFocused)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .onChange(of: viewModel.searchQuery) { newValue in
                            viewModel.updateAutocomplete(for: newValue)
                        }
                        .onSubmit {
                            viewModel.tagSuggestions = []
                            viewModel.loadInitialPosts()
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                            viewModel.tagSuggestions = []
                            viewModel.loadInitialPosts()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.portalGrey)
                                .font(.system(size: 15))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.darkCard)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isFieldFocused ? Color.neonOrange.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
                )
                
                Button(action: {
                    viewModel.toggleNsfw()
                }) {
                    Text(appSettings.isNsfwEnabled ? "R-18" : "SAFE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(appSettings.isNsfwEnabled ? .white : .neonOrange)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 7)
                        .background(appSettings.isNsfwEnabled ? Color.red : Color.darkCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appSettings.isNsfwEnabled ? Color.clear : Color.neonOrange, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: {
                        viewModel.searchQuery = "#HOT#"
                        viewModel.loadInitialPosts()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.neonOrange)
                                .font(.system(size: 12))
                            Text("HOT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(viewModel.searchQuery == "#HOT#" ? Color.neonOrange.opacity(0.3) : Color.darkCard)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(viewModel.searchQuery == "#HOT#" ? Color.neonOrange : Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        viewModel.searchQuery = "order:score"
                        viewModel.loadInitialPosts()
                    }) {
                        Text("★ Top Score")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.darkCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                    
                    Button(action: {
                        viewModel.searchQuery = "order:favcount"
                        viewModel.loadInitialPosts()
                    }) {
                        Text("♥ Most Favorited")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.darkCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 12)
            }
            
            if !viewModel.tagSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(viewModel.tagSuggestions) { tag in
                                Button(action: {
                                    isFieldFocused = false
                                    viewModel.selectSuggestion(tag)
                                }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(tag.categoryColor)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(tag.name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 13, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Text("\(tag.post_count)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.portalGrey)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.darkSurface)
                                }
                                .buttonStyle(PlainButtonStyle())
                                Divider().background(Color.white.opacity(0.06))
                            }
                        }
                    }
                    .frame(maxHeight: 220)
                }
                .background(Color.darkSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonOrange.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 12)
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
            }
        }
    }
}
