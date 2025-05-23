import SwiftUI
import Combine

struct LoginView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var instance: String = ""
    @State private var authCode: String = ""
    @State private var isLoading: Bool = false
    @State private var showingWebView: Bool = false
    @State private var errorMessage: String = ""
    @State private var clientId: String = ""
    @State private var clientSecret: String = ""
    @State private var authorizationURL: URL?
    @State private var cancellables = Set<AnyCancellable>()
    
    private let api = MastodonAPI.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome to Mastodon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connect to your Mastodon instance")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    TextField("Instance (e.g., mastodon.social)", text: $instance)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !clientId.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Step 2: Get Authorization Code")
                                .font(.headline)
                            
                            Text("1. Tap 'Open Authorization Page' below")
                            Text("2. Authorize the app in your browser")
                            Text("3. Copy the authorization code")
                            Text("4. Paste it here and tap 'Complete Login'")
                            
                            TextField("Authorization Code", text: $authCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if isLoading {
                        ProgressView()
                    } else if clientId.isEmpty {
                        VStack(spacing: 8) {
                            Text("Step 1: Register App")
                                .font(.headline)
                            
                            Button("Get Authorization") {
                                registerApp()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(instance.isEmpty)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Button("Open Authorization Page") {
                                if let url = authorizationURL {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Complete Login") {
                                completeLogin()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(authCode.isEmpty)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func registerApp() {
        guard !instance.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        api.createApp(instance: instance)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        errorMessage = "Failed to register app: \(error.localizedDescription)"
                    }
                },
                receiveValue: { application in
                    self.clientId = application.clientId
                    self.clientSecret = application.clientSecret
                    
                    self.authorizationURL = self.api.getAuthorizationURL(instance: self.instance, clientId: self.clientId)
                }
            )
            .store(in: &cancellables)
    }
    
    private func completeLogin() {
        guard !authCode.isEmpty else { return }
        
        isLoading = true
        errorMessage = ""
        
        api.getAccessToken(
            instance: instance,
            clientId: clientId,
            clientSecret: clientSecret,
            code: authCode
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            },
            receiveValue: { token in
                userStore.login(instance: instance, accessToken: token.accessToken)
            }
        )
        .store(in: &cancellables)
    }
}