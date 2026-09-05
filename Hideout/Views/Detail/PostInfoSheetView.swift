import SwiftUI

public struct PostInfoSheetView: View {
    public let post: Post
    public let onSearchTag: (String) -> Void
    public let onOpenRelatedQuery: (String) -> Void
    
    public init(
        post: Post,
        onSearchTag: @escaping (String) -> Void,
        onOpenRelatedQuery: @escaping (String) -> Void
    ) {
        self.post = post
        self.onSearchTag = onSearchTag
        self.onOpenRelatedQuery = onOpenRelatedQuery
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let relatedQuery = post.getAllRelatedIdsQuery() {
                        Button(action: {
                            onOpenRelatedQuery(relatedQuery)
                        }) {
                            HStack {
                                Image(systemName: "square.stack.3d.up.fill")
                                    .foregroundColor(.neonOrange)
                                Text("연관 포스트 묶어보기 (부모/자식 관계글)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.portalGrey)
                                    .font(.system(size: 12))
                            }
                            .padding()
                            .background(Color.darkCard)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.neonOrange.opacity(0.4), lineWidth: 1)
                            )
                        }
                    }
                    
                    if let pools = post.pools, !pools.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("앨범 (Pools)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.portalGrey)
                            
                            HStack(spacing: 8) {
                                ForEach(pools, id: \.self) { poolId in
                                    Button(action: {
                                        onSearchTag("pool:\(poolId)")
                                    }) {
                                        Text("Pool #\(poolId)")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.neonOrange)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.darkCard)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    if let tags = post.tags {
                        tagSection(title: "Artist", tags: tags.artist ?? [], color: .tagArtist)
                        tagSection(title: "Character", tags: tags.character ?? [], color: .tagCharacter)
                        tagSection(title: "Copyright", tags: tags.copyright ?? [], color: .tagCopyright)
                        tagSection(title: "Species", tags: tags.species ?? [], color: .tagSpecies)
                        tagSection(title: "General", tags: tags.general ?? [], color: .tagGeneral)
                        tagSection(title: "Meta", tags: tags.meta ?? [], color: .tagMeta)
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("정보 (Details)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.portalGrey)
                        
                        metadataRow(label: "Post ID", value: "#\(post.id)")
                        if let score = post.score?.total {
                            metadataRow(label: "Score", value: "\(score)")
                        }
                        if let ext = post.file?.ext {
                            metadataRow(label: "Format", value: ext.uppercased())
                        }
                        if let md5 = post.file?.md5 {
                            metadataRow(label: "MD5", value: md5)
                        }
                    }
                    
                    if let sources = post.sources, !sources.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("출처 (Sources)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.portalGrey)
                            
                            ForEach(sources, id: \.self) { src in
                                if let url = URL(string: src) {
                                    Link(destination: url) {
                                        HStack {
                                            Image(systemName: "link")
                                                .font(.system(size: 11))
                                            Text(src)
                                                .font(.system(size: 12))
                                                .lineLimit(1)
                                        }
                                        .foregroundColor(.neonOrange)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.darkSurface.edgesIgnoringSafeArea(.all))
            .navigationTitle("포스트 정보")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func tagSection(title: String, tags: [String], color: Color) -> some View {
        Group {
            if !tags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Button(action: {
                                onSearchTag(tag)
                            }) {
                                Text(tag)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(color.opacity(0.12))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.portalGrey)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

public struct FlowLayout: Layout {
    public var spacing: CGFloat = 6
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
