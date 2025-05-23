import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedTab: Int = 0
    
    var body: some View {
        Group {
            if userStore.isLoggedIn {
                TabView(selection: $selectedTab) {
                    TimelineView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    SearchView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                        .tag(1)
                    
                    NotificationView()
                        .tabItem {
                            Image(systemName: "bell")
                            Text("Notifications")
                        }
                        .tag(2)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(4)
                }
                .accentColor(.blue)
            } else {
                LoginView()
            }
        }
    }
}