import SwiftUI
import Combine

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var userStatuses: [Status] = []
    @State private var isLoading = false
    @State private var cancellables = Set<AnyCancellable>()
    
    private let api = MastodonAPI.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let user = userStore.currentUser {
                    VStack(spacing: 0) {
                        // Header image
                        AsyncImage(url: URL(string: user.header)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                        .frame(height: 150)
                        .clipped()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                // Avatar
                                AsyncImage(url: URL(string: user.avatar)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(UIColor.systemBackground), lineWidth: 4)
                                )
                                .offset(y: -40)
                                
                                Spacer()
                                
                                Button("Edit Profile") {
                                    // Edit profile action
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 8)
                            }
                            .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("@\(user.username)")
                                    .foregroundColor(.secondary)
                                
                                if !user.note.isEmpty {
                                    Text(user.note.htmlToString())
                                        .font(.body)
                                        .padding(.top, 4)
                                }
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("\(user.statusesCount)")
                                            .fontWeight(.semibold)
                                        Text("Posts")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(user.followingCount)")
                                            .fontWeight(.semibold)
                                        Text("Following")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack {
                                        Text("\(user.followersCount)")
                                            .fontWeight(.semibold)
                                        Text("Followers")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                            .padding(.horizontal)
                            
                            Divider()
                                .padding(.top)
                            
                            // User's posts
                            LazyVStack {
                                ForEach(userStatuses) { status in
                                    StatusView(status: status)
                                        .padding(.horizontal)
                                    
                                    Divider()
                                }
                            }
                            
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                    }
                } else {
                    Text("No user data available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                loadUserStatuses()
            }
            .onAppear {
                if userStatuses.isEmpty {
                    loadUserStatuses()
                }
            }
        }
    }
    
    private func loadUserStatuses() {
        guard let userId = userStore.currentUser?.id else { return }
        
        isLoading = true
        
        api.getAccountStatuses(id: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        print("Failed to load user statuses: \(error)")
                    }
                },
                receiveValue: { statuses in
                    userStatuses = statuses
                }
            )
            .store(in: &cancellables)
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserStore())
}