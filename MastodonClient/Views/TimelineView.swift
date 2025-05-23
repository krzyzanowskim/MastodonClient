import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var timelineStore: TimelineStore
    @State private var selectedTimeline: TimelineType = .home
    @State private var showingCompose = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Timeline", selection: $selectedTimeline) {
                    Text("Home").tag(TimelineType.home)
                    Text("Local").tag(TimelineType.local)
                    Text("Federated").tag(TimelineType.federated)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    ForEach(currentTimeline) { status in
                        StatusView(status: status)
                            .onAppear {
                                if status.id == currentTimeline.last?.id {
                                    timelineStore.loadMoreStatuses(type: selectedTimeline)
                                }
                            }
                    }
                    
                    if timelineStore.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding()
                    }
                }
                .refreshable {
                    timelineStore.refreshTimeline(type: selectedTimeline)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCompose = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                ComposeView()
            }
            .onChange(of: selectedTimeline) {
                timelineStore.refreshTimeline(type: selectedTimeline)
            }
            .onAppear {
                if currentTimeline.isEmpty {
                    timelineStore.refreshTimeline(type: selectedTimeline)
                }
            }
        }
    }
    
    private var currentTimeline: [Status] {
        switch selectedTimeline {
        case .home:
            return timelineStore.homeTimeline
        case .local:
            return timelineStore.localTimeline
        case .federated:
            return timelineStore.federatedTimeline
        }
    }
}