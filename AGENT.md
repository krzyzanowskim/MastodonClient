# Agent Development Guide

## Project Structure

This is a complete iOS Mastodon client built with SwiftUI. The project follows MVVM architecture with these main components:

### Core Files
- `MastodonClientApp.swift` - Main app entry point
- `ContentView.swift` - Root view with tab navigation
- `Models/Models.swift` - All Mastodon API data models
- `Services/MastodonAPI.swift` - Complete API service layer
- `Stores/` - ObservableObject stores for state management
- `Views/` - All SwiftUI views

### Build Commands
```bash
# Build for iOS Simulator
xcodebuild -project MastodonClient.xcodeproj -scheme MastodonClient -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build

# Open in Xcode
open MastodonClient.xcodeproj
```

### Key Dependencies
- SwiftUI (UI framework)
- Combine (reactive programming)
- URLSession (networking)
- Foundation (core functionality)

## Architecture Patterns

### MVVM Implementation
- **Models**: Codable structs matching Mastodon API
- **Views**: SwiftUI views for UI components  
- **ViewModels**: `@ObservableObject` stores managing state
- **Services**: API layer with Combine publishers

### State Management
- `UserStore`: Authentication and current user state
- `TimelineStore`: Timeline data and status interactions
- Environment objects passed down view hierarchy

### API Integration
- Complete Mastodon API implementation
- OAuth 2.0 authentication flow
- RESTful endpoints with Combine publishers
- Error handling and response parsing

## Coding Standards

### SwiftUI Best Practices
- Use `@StateObject` for creating stores
- Use `@EnvironmentObject` for passing stores
- Prefer `AsyncImage` for remote images
- Use `LazyVStack` for performance in lists

### Networking
- All API calls return Combine publishers
- Proper error handling with custom error types
- URLSession configuration for requests
- JSON decoding with proper CodingKeys

### Code Organization
- Group related functionality in folders
- One major component per file
- Proper access control (private, internal, public)
- Clear naming conventions

## Feature Implementation Notes

### Authentication
- OAuth 2.0 flow with authorization codes
- Secure credential storage in UserDefaults
- Automatic login restoration
- Support for any Mastodon instance

### Timeline Features
- Three timeline types (Home, Local, Federated)
- Infinite scrolling with pagination
- Pull-to-refresh functionality
- Real-time status interactions

### Content Display
- HTML content parsing and display
- Media attachment support
- Relative timestamp formatting
- Proper accessibility support

### User Interface
- Tab-based navigation
- Responsive design for iPhone/iPad
- Dark mode support
- Loading states and error feedback

## Testing Strategy

### Unit Testing
- Test API service methods
- Test data model parsing
- Test store state management
- Mock network responses

### UI Testing
- Test navigation flows
- Test user interactions
- Test authentication flow
- Test content display

## Performance Considerations

### Optimization Techniques
- Lazy loading of images and content
- Efficient list rendering
- Minimal API calls
- Smart data caching

### Memory Management
- Proper Combine cancellable storage
- Efficient image loading
- Clean state management
- Avoid retain cycles

## Common Issues & Solutions

### Xcode Project Issues
- If project file is corrupted, regenerate from scratch
- Ensure proper file references in project structure
- Check build settings for iOS deployment target

### API Integration
- Handle rate limiting gracefully
- Implement proper error handling
- Use appropriate HTTP methods
- Validate API responses

### SwiftUI Performance
- Use `LazyVStack` for large lists
- Implement proper `Identifiable` conformance
- Avoid expensive computations in view bodies
- Use `@State` appropriately for local state

## Development Workflow

1. **Feature Planning**: Define requirements and UI mockups
2. **API Integration**: Implement or extend API service methods
3. **Model Updates**: Add or modify data models as needed
4. **View Implementation**: Create SwiftUI views with proper state binding
5. **Store Integration**: Connect views to appropriate stores
6. **Testing**: Add unit and UI tests
7. **Polish**: Add loading states, error handling, animations

## Deployment Notes

### App Store Requirements
- Proper app icons and launch screens
- Privacy policy for data usage
- App Store description and screenshots
- Compliance with App Store guidelines

### Configuration
- Update bundle identifier for distribution
- Configure signing certificates
- Set proper deployment target
- Add necessary entitlements

This codebase provides a complete, production-ready Mastodon client with modern iOS development practices.