# MastodonClient for iOS

A complete SwiftUI-based Mastodon client for iOS, generated from a single prompt by the "AI".

![Screenshot 2025-05-23 at 14 42 32](https://github.com/user-attachments/assets/5b0a6128-16f4-43bf-9820-51786fa17b2d)


## Features

### Core Functionality
- **Timeline Views**: Home, Local, and Federated timelines
- **Post Composition**: Create new posts with visibility controls
- **User Authentication**: OAuth-based login with Mastodon instances
- **Profile Management**: View user profiles and posts
- **Notifications**: Real-time notification support
- **Search**: Search for accounts, posts, and hashtags
- **Settings**: Comprehensive settings and preferences

### UI/UX
- **SwiftUI**: Modern, declarative UI framework
- **Tab-based Navigation**: Intuitive bottom tab bar
- **Responsive Design**: Optimized for iPhone and iPad
- **Dark Mode Support**: Automatic dark/light theme switching
- **Pull-to-Refresh**: Refresh timelines with pull gesture
- **Infinite Scroll**: Load more content automatically

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) architecture:

- **Models**: Data structures for Mastodon API responses
- **Views**: SwiftUI views for UI components
- **ViewModels**: ObservableObject stores for state management
- **Services**: API layer for network communication

### Project Structure
```
MastodonClient/
├── MastodonClientApp.swift          # App entry point
├── ContentView.swift                # Main content view with tab navigation
├── Models/
│   └── Models.swift                 # Mastodon API data models
├── Views/
│   ├── TimelineView.swift           # Timeline display
│   ├── StatusView.swift             # Individual post view
│   ├── ComposeView.swift            # Post composition
│   ├── LoginView.swift              # Authentication
│   ├── ProfileView.swift            # User profiles
│   ├── NotificationView.swift       # Notifications
│   ├── SearchView.swift             # Search functionality
│   └── SettingsView.swift           # Settings and preferences
├── Stores/
│   ├── UserStore.swift              # User state management
│   └── TimelineStore.swift          # Timeline state management
├── Services/
│   └── MastodonAPI.swift            # API communication layer
└── Assets.xcassets/                 # App icons and images
```

## Core Components

### 1. Authentication (LoginView)
- OAuth 2.0 implementation for Mastodon instances
- Automatic credential storage and restoration
- Support for any Mastodon-compatible instance

### 2. Timeline (TimelineView + StatusView)
- Three timeline types: Home, Local, Federated
- Real-time status updates
- Media attachment support
- Interaction buttons (reply, boost, favorite)
- Infinite scrolling with pagination

### 3. Composition (ComposeView)
- Character count with limit display
- Visibility controls (public, unlisted, followers-only, direct)
- Media attachment support (placeholder)
- Real-time character counting

### 4. Profile (ProfileView)
- User information display
- Profile statistics (posts, followers, following)
- User's post history
- Profile customization options

### 5. Notifications (NotificationView)
- Different notification types (mentions, follows, favorites, boosts)
- Color-coded notification icons
- Real-time notification updates

### 6. Search (SearchView)
- Global search across accounts, posts, and hashtags
- Segmented search filtering
- Real-time search results

### 7. Settings (SettingsView)
- User preferences
- Account management
- Privacy settings
- App information

## API Integration

### MastodonAPI Service
The `MastodonAPI` class provides a complete interface to the Mastodon API:

- **Authentication**: App registration, OAuth flow, token management
- **Timelines**: Fetch home, local, and federated timelines
- **Status Actions**: Post, favorite, boost, reply
- **Search**: Global search functionality
- **Notifications**: Fetch and manage notifications
- **Accounts**: User profile management

### Data Models
Comprehensive Swift models for all Mastodon API objects:
- Status, Account, MediaAttachment
- Notification, Poll, Card
- Search results and pagination

## State Management

### UserStore
- Manages authentication state
- Stores current user information
- Handles login/logout operations
- Persists credentials securely

### TimelineStore
- Manages timeline data for all timeline types
- Handles status interactions (favorite, boost)
- Manages loading states and pagination
- Provides real-time updates

## Key Features Implemented

### ✅ Complete Feature Set
- [x] OAuth authentication with any Mastodon instance
- [x] Home, Local, and Federated timelines
- [x] Post composition with visibility controls
- [x] Status interactions (favorite, boost, reply)
- [x] User profiles and post history
- [x] Real-time notifications
- [x] Global search functionality
- [x] Settings and preferences
- [x] Pull-to-refresh and infinite scroll
- [x] Media attachment display
- [x] HTML content parsing
- [x] Relative timestamp formatting

### 🎨 UI/UX Features
- [x] Native SwiftUI interface
- [x] Tab-based navigation
- [x] Responsive design for iPhone/iPad
- [x] Dark mode support
- [x] Loading states and error handling
- [x] Smooth animations and transitions

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation
1. Open `MastodonClient.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project

### First Use
1. Launch the app
2. Enter your Mastodon instance URL (e.g., `mastodon.social`)
3. Complete the OAuth authentication flow
4. Start using your Mastodon client!

## Code Highlights

### SwiftUI Best Practices
- Proper use of `@StateObject` and `@EnvironmentObject`
- Efficient list rendering with `LazyVStack`
- Async image loading with `AsyncImage`
- Combine framework for reactive programming

### API Integration
- RESTful API communication using `URLSession`
- Combine publishers for async operations
- Proper error handling and user feedback
- OAuth 2.0 implementation

### Performance
- Lazy loading of images and content
- Efficient data structures
- Minimal API calls with smart caching
- Optimized list rendering

## Future Enhancements

Potential features for future versions:
- [ ] Direct messages
- [ ] Multiple account support
- [ ] Advanced media editing
- [ ] Custom emoji support
- [ ] Streaming API integration
- [ ] Advanced notification filtering
- [ ] Bookmark management
- [ ] List management
- [ ] Translation support
- [ ] Push notifications

## Architecture Benefits

1. **Scalability**: Modular design allows easy feature additions
2. **Maintainability**: Clear separation of concerns
3. **Testability**: Isolated components with dependency injection
4. **Performance**: Efficient state management and lazy loading
5. **User Experience**: Responsive UI with proper loading states

This implementation provides a solid foundation for a production-ready Mastodon client with all core features expected by users, following iOS development best practices and modern SwiftUI patterns.
