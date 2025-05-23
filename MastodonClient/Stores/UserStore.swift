import Foundation
import Combine

class UserStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: Account?
    @Published var instance: String = ""
    @Published var accessToken: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let api = MastodonAPI.shared
    
    init() {
        loadStoredCredentials()
    }
    
    func login(instance: String, accessToken: String) {
        self.instance = instance
        self.accessToken = accessToken
        
        api.baseURL = "https://\(instance)"
        api.accessToken = accessToken
        
        // Verify credentials
        api.verifyCredentials()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Login failed: \(error)")
                        self.logout()
                    case .finished:
                        break
                    }
                },
                receiveValue: { account in
                    self.currentUser = account
                    self.isLoggedIn = true
                    self.saveCredentials()
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
        isLoggedIn = false
        currentUser = nil
        instance = ""
        accessToken = ""
        
        api.baseURL = ""
        api.accessToken = ""
        
        clearStoredCredentials()
    }
    
    private func saveCredentials() {
        UserDefaults.standard.set(instance, forKey: "mastodon_instance")
        UserDefaults.standard.set(accessToken, forKey: "mastodon_access_token")
        
        if let userData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(userData, forKey: "mastodon_current_user")
        }
    }
    
    private func loadStoredCredentials() {
        guard let storedInstance = UserDefaults.standard.string(forKey: "mastodon_instance"),
              let storedToken = UserDefaults.standard.string(forKey: "mastodon_access_token") else {
            return
        }
        
        instance = storedInstance
        accessToken = storedToken
        
        api.baseURL = "https://\(instance)"
        api.accessToken = accessToken
        
        if let userData = UserDefaults.standard.data(forKey: "mastodon_current_user"),
           let user = try? JSONDecoder().decode(Account.self, from: userData) {
            currentUser = user
            isLoggedIn = true
        }
    }
    
    private func clearStoredCredentials() {
        UserDefaults.standard.removeObject(forKey: "mastodon_instance")
        UserDefaults.standard.removeObject(forKey: "mastodon_access_token")
        UserDefaults.standard.removeObject(forKey: "mastodon_current_user")
    }
}