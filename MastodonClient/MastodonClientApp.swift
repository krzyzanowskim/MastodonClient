import SwiftUI

@main
struct MastodonClientApp: App {
    @StateObject private var userStore = UserStore()
    @StateObject private var timelineStore = TimelineStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userStore)
                .environmentObject(timelineStore)
        }
    }
}