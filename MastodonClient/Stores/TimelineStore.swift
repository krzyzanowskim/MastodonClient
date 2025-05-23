import Foundation
import Combine

class TimelineStore: ObservableObject {
    @Published var homeTimeline: [Status] = []
    @Published var localTimeline: [Status] = []
    @Published var federatedTimeline: [Status] = []
    @Published var isLoading: Bool = false
    @Published var notifications: [MastodonNotification] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let api = MastodonAPI.shared
    
    func refreshTimeline(type: TimelineType = .home) {
        isLoading = true
        
        api.getTimeline(type: type)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        print("Timeline refresh failed: \(error)")
                    }
                },
                receiveValue: { statuses in
                    switch type {
                    case .home:
                        self.homeTimeline = statuses
                    case .local:
                        self.localTimeline = statuses
                    case .federated:
                        self.federatedTimeline = statuses
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMoreStatuses(type: TimelineType = .home) {
        let currentTimeline: [Status]
        switch type {
        case .home:
            currentTimeline = homeTimeline
        case .local:
            currentTimeline = localTimeline
        case .federated:
            currentTimeline = federatedTimeline
        }
        
        guard let lastStatus = currentTimeline.last else { return }
        
        api.getTimeline(type: type, maxId: lastStatus.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Load more failed: \(error)")
                    }
                },
                receiveValue: { statuses in
                    switch type {
                    case .home:
                        self.homeTimeline.append(contentsOf: statuses)
                    case .local:
                        self.localTimeline.append(contentsOf: statuses)
                    case .federated:
                        self.federatedTimeline.append(contentsOf: statuses)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshNotifications() {
        api.getNotifications()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Notifications refresh failed: \(error)")
                    }
                },
                receiveValue: { notifications in
                    self.notifications = notifications
                }
            )
            .store(in: &cancellables)
    }
    
    func favouriteStatus(_ status: Status) {
        let isFavourited = status.favourited ?? false
        
        let publisher = isFavourited ? 
            api.unfavouriteStatus(id: status.id) : 
            api.favouriteStatus(id: status.id)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Favourite action failed: \(error)")
                    }
                },
                receiveValue: { updatedStatus in
                    self.updateStatusInTimelines(updatedStatus)
                }
            )
            .store(in: &cancellables)
    }
    
    func reblogStatus(_ status: Status) {
        let isReblogged = status.reblogged ?? false
        
        let publisher = isReblogged ? 
            api.unreblogStatus(id: status.id) : 
            api.reblogStatus(id: status.id)
        
        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Reblog action failed: \(error)")
                    }
                },
                receiveValue: { updatedStatus in
                    self.updateStatusInTimelines(updatedStatus)
                }
            )
            .store(in: &cancellables)
    }
    
    func postStatus(content: String, replyToId: String? = nil) {
        api.postStatus(content: content, replyToId: replyToId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Post failed: \(error)")
                    }
                },
                receiveValue: { newStatus in
                    if replyToId == nil {
                        self.homeTimeline.insert(newStatus, at: 0)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateStatusInTimelines(_ updatedStatus: Status) {
        updateStatusInArray(&homeTimeline, with: updatedStatus)
        updateStatusInArray(&localTimeline, with: updatedStatus)
        updateStatusInArray(&federatedTimeline, with: updatedStatus)
    }
    
    private func updateStatusInArray(_ array: inout [Status], with updatedStatus: Status) {
        if let index = array.firstIndex(where: { $0.id == updatedStatus.id }) {
            array[index] = updatedStatus
        }
    }
}