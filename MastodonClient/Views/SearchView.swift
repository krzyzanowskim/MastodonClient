import SwiftUI
import Combine

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults = SearchResults(accounts: [], statuses: [], hashtags: [])
    @State private var isLoading = false
    @State private var selectedScope: SearchScope = .all
    @State private var cancellables = Set<AnyCancellable>()
    
    private let api = MastodonAPI.shared
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: performSearch)
                
                Picker("Search Scope", selection: $selectedScope) {
                    Text("All").tag(SearchScope.all)
                    Text("Accounts").tag(SearchScope.accounts)
                    Text("Posts").tag(SearchScope.statuses)
                    Text("Hashtags").tag(SearchScope.hashtags)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Search Mastodon")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Find accounts, posts, and hashtags")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        if selectedScope == .all || selectedScope == .accounts {
                            if !searchResults.accounts.isEmpty {
                                Section("Accounts") {
                                    ForEach(searchResults.accounts) { account in
                                        AccountRowView(account: account)
                                    }
                                }
                            }
                        }
                        
                        if selectedScope == .all || selectedScope == .statuses {
                            if !searchResults.statuses.isEmpty {
                                Section("Posts") {
                                    ForEach(searchResults.statuses) { status in
                                        StatusView(status: status)
                                    }
                                }
                            }
                        }
                        
                        if selectedScope == .all || selectedScope == .hashtags {
                            if !searchResults.hashtags.isEmpty {
                                Section("Hashtags") {
                                    ForEach(searchResults.hashtags, id: \.name) { hashtag in
                                        HashtagRowView(hashtag: hashtag)
                                    }
                                }
                            }
                        }
                        
                        if searchResults.accounts.isEmpty && 
                           searchResults.statuses.isEmpty && 
                           searchResults.hashtags.isEmpty && 
                           !searchText.isEmpty && 
                           !isLoading {
                            Text("No results found")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        
        let searchType: SearchType? = {
            switch selectedScope {
            case .all:
                return nil
            case .accounts:
                return .accounts
            case .statuses:
                return .statuses
            case .hashtags:
                return .hashtags
            }
        }()
        
        api.search(query: searchText, type: searchType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        print("Search failed: \(error)")
                    }
                },
                receiveValue: { results in
                    searchResults = results
                }
            )
            .store(in: &cancellables)
    }
}

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar
        
        init(_ parent: SearchBar) {
            self.parent = parent
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            parent.onSearchButtonClicked()
        }
    }
}

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: account.avatar)) { image in
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
                Text(account.displayName)
                    .fontWeight(.semibold)
                
                Text("@\(account.username)")
                    .foregroundColor(.secondary)
                
                if !account.note.isEmpty {
                    Text(account.note.htmlToString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button("Follow") {
                // Follow action
            }
            .buttonStyle(.bordered)
            .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

struct HashtagRowView: View {
    let hashtag: Tag
    
    var body: some View {
        HStack {
            Image(systemName: "number")
                .foregroundColor(.blue)
            
            Text(hashtag.name)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

enum SearchScope {
    case all
    case accounts
    case statuses
    case hashtags
}

#Preview {
    SearchView()
}