import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var timelineStore: TimelineStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(timelineStore.notifications) { notification in
                    NotificationRowView(notification: notification)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Notifications")
            .refreshable {
                timelineStore.refreshNotifications()
            }
            .onAppear {
                if timelineStore.notifications.isEmpty {
                    timelineStore.refreshNotifications()
                }
            }
        }
    }
}

struct NotificationRowView: View {
    let notification: MastodonNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            notificationIcon
                .foregroundColor(notificationColor)
            
            AsyncImage(url: URL(string: notification.account.avatar)) { image in
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
                    Text(notification.account.displayName)
                        .fontWeight(.semibold)
                    
                    Text(notificationDescription)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatDate(notification.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let status = notification.status {
                    Text(status.content.htmlToString())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var notificationIcon: Image {
        switch notification.type {
        case "mention":
            return Image(systemName: "at")
        case "follow":
            return Image(systemName: "person.badge.plus")
        case "favourite":
            return Image(systemName: "heart.fill")
        case "reblog":
            return Image(systemName: "repeat")
        case "poll":
            return Image(systemName: "chart.bar")
        case "follow_request":
            return Image(systemName: "person.crop.circle.badge.questionmark")
        default:
            return Image(systemName: "bell")
        }
    }
    
    private var notificationColor: Color {
        switch notification.type {
        case "mention":
            return .blue
        case "follow":
            return .green
        case "favourite":
            return .red
        case "reblog":
            return .orange
        case "poll":
            return .purple
        case "follow_request":
            return .yellow
        default:
            return .secondary
        }
    }
    
    private var notificationDescription: String {
        switch notification.type {
        case "mention":
            return "mentioned you"
        case "follow":
            return "followed you"
        case "favourite":
            return "favourited your post"
        case "reblog":
            return "boosted your post"
        case "poll":
            return "poll ended"
        case "follow_request":
            return "requested to follow you"
        default:
            return notification.type
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

#Preview {
    NotificationView()
        .environmentObject(TimelineStore())
}