import SwiftUI

public struct PostCardView: View {
    public let post: Post
    public let onSelect: () -> Void
    
    public init(post: Post, onSelect: @escaping () -> Void) {
        self.post = post
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .bottomLeading) {
                if let previewUrl = post.preview?.url ?? post.sample?.url,
                   let url = URL(string: previewUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.darkCard)
                                .aspectRatio(1.0, contentMode: .fit)
                                .shimmerEffect()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.darkCard)
                                .aspectRatio(1.0, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "photo.badge.exclamationmark")
                                        .foregroundColor(.portalGrey)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Rectangle()
                        .fill(Color.darkCard)
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.portalGrey)
                        )
                }
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.85),
                        Color.black.opacity(0.0)
                    ]),
                    startPoint: .bottom,
                    endPoint: .center
                )
                
                HStack(alignment: .bottom) {
                    if let score = post.score?.total {
                        HStack(spacing: 3) {
                            Image(systemName: score >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 10, weight: .bold))
                            Text("\(score)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(score > 0 ? .neonOrange : (score < 0 ? .red : .portalGrey))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    if post.isVideo {
                        HStack(spacing: 3) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            if !post.formattedDuration.isEmpty {
                                Text(post.formattedDuration)
                                    .font(.system(size: 10, weight: .medium))
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(6)
                    }
                }
                .padding(6)
                
                if post.is_favorited == true {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(5)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
