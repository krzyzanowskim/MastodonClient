import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let user = userStore.currentUser {
                        HStack {
                            AsyncImage(url: URL(string: user.avatar)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.displayName)
                                    .fontWeight(.semibold)
                                
                                Text("@\(user.username)")
                                    .foregroundColor(.secondary)
                                
                                Text(userStore.instance)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                Section("Preferences") {
                    SettingsRow(
                        icon: "bell",
                        title: "Notifications",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "eye",
                        title: "Privacy",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "textformat",
                        title: "Appearance",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "accessibility",
                        title: "Accessibility",
                        action: {}
                    )
                }
                
                Section("Content") {
                    SettingsRow(
                        icon: "hand.raised",
                        title: "Content Filtering",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "person.2.slash",
                        title: "Blocked Users",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "speaker.slash",
                        title: "Muted Users",
                        action: {}
                    )
                }
                
                Section("About") {
                    SettingsRow(
                        icon: "info.circle",
                        title: "About MastodonClient",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "questionmark.circle",
                        title: "Help & Support",
                        action: {}
                    )
                    
                    SettingsRow(
                        icon: "doc.text",
                        title: "Terms & Privacy",
                        action: {}
                    )
                }
                
                Section {
                    Button {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.square")
                                .foregroundColor(.red)
                            Text("Log Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    userStore.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserStore())
}