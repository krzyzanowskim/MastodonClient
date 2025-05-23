import SwiftUI

struct ComposeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var timelineStore: TimelineStore
    @EnvironmentObject var userStore: UserStore
    
    @State private var content: String = ""
    @State private var visibility: String = "public"
    @State private var isPosting: Bool = false
    @State private var characterCount: Int = 0
    
    private let maxCharacters = 500
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: URL(string: userStore.currentUser?.avatar ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("What's happening?", text: $content, axis: .vertical)
                            .font(.body)
                            .lineLimit(10...20)
                            .onChange(of: content) {
                                characterCount = content.count
                            }
                        
                        HStack {
                            Picker("Visibility", selection: $visibility) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text("Public")
                                }.tag("public")
                                
                                HStack {
                                    Image(systemName: "lock.open")
                                    Text("Unlisted")
                                }.tag("unlisted")
                                
                                HStack {
                                    Image(systemName: "person.2")
                                    Text("Followers")
                                }.tag("private")
                                
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("Direct")
                                }.tag("direct")
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                            
                            Text("\(characterCount)/\(maxCharacters)")
                                .font(.caption)
                                .foregroundColor(characterCount > maxCharacters ? .red : .secondary)
                        }
                    }
                }
                .padding()
                
                Divider()
                
                HStack {
                    Button {
                        // Add media
                    } label: {
                        Image(systemName: "photo")
                    }
                    
                    Button {
                        // Add poll
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                    
                    Button {
                        // Add emoji
                    } label: {
                        Image(systemName: "face.smiling")
                    }
                    
                    Spacer()
                    
                    if isPosting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postStatus()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || characterCount > maxCharacters || isPosting)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func postStatus() {
        isPosting = true
        
        timelineStore.postStatus(content: content)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPosting = false
            dismiss()
        }
    }
}

#Preview {
    ComposeView()
        .environmentObject(UserStore())
        .environmentObject(TimelineStore())
}