import SwiftUI

struct StatusView: View {
    @ObservedObject var status: Status
    @EnvironmentObject var timelineStore: TimelineStore
    @State private var showingDetail = false
    
    var displayStatus: Status {
        status.reblog ?? status
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if status.reblog != nil {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundColor(.secondary)
                    Text("\(status.account.displayName) boosted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: displayStatus.account.avatar)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayStatus.account.displayName)
                            .fontWeight(.semibold)
                        
                        Text("@\(displayStatus.account.username)")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatDate(displayStatus.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !displayStatus.spoilerText.isEmpty {
                        Text(displayStatus.spoilerText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.bottom, 4)
                    }
                    
                    Text(displayStatus.content.htmlToString())
                        .font(.body)
                        .lineLimit(nil)
                    
                    if !displayStatus.mediaAttachments.isEmpty {
                        MediaAttachmentsView(attachments: displayStatus.mediaAttachments)
                    }
                    
                    HStack(spacing: 20) {
                        Button {
                            // Reply action
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                Text("\(displayStatus.repliesCount)")
                            }
                            .foregroundColor(.secondary)
                        }
                        
                        Button {
                            timelineStore.reblogStatus(displayStatus)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                Text("\(displayStatus.reblogsCount)")
                            }
                            .foregroundColor(displayStatus.reblogged == true ? .green : .secondary)
                        }
                        
                        Button {
                            timelineStore.favouriteStatus(displayStatus)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: displayStatus.favourited == true ? "heart.fill" : "heart")
                                Text("\(displayStatus.favouritesCount)")
                            }
                            .foregroundColor(displayStatus.favourited == true ? .red : .secondary)
                        }
                        
                        Button {
                            // Share action
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            StatusDetailView(status: displayStatus)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let now = Date()
        let timeDifference = now.timeIntervalSince(date)
        
        if timeDifference < 60 {
            return "\(Int(timeDifference))s"
        } else if timeDifference < 3600 {
            return "\(Int(timeDifference / 60))m"
        } else if timeDifference < 86400 {
            return "\(Int(timeDifference / 3600))h"
        } else {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "MMM d"
            return dayFormatter.string(from: date)
        }
    }
}

struct MediaAttachmentsView: View {
    let attachments: [MediaAttachment]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(attachments.count, 2)), spacing: 8) {
            ForEach(attachments, id: \.id) { attachment in
                AsyncImage(url: URL(string: attachment.previewUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct StatusDetailView: View {
    @ObservedObject var status: Status
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    StatusView(status: status)
                        .padding()
                    
                    Divider()
                    
                    // Thread/replies would go here
                    Text("Replies and thread view coming soon...")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension String {
    func htmlToString() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string
    }
}