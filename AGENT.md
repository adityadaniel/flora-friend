# FloraFriend iOS App - Agent Guidelines

## Build/Test Commands
- **Build**: `xcodebuild -project FloraFriend.xcodeproj -scheme FloraFriend build`
- **Clean**: `xcodebuild -project FloraFriend.xcodeproj -scheme FloraFriend clean`
- **Run in Simulator**: Open in Xcode and use Cmd+R (no test targets configured yet)
- **Archive**: `xcodebuild -project FloraFriend.xcodeproj -scheme FloraFriend archive`

## Architecture
- **Platform**: iOS SwiftUI app with SwiftData persistence
- **Main Structure**: FloraFriend/ contains all source code
- **Key Dependencies**: RevenueCat (subscriptions), AIProxy (OpenAI API), ConfettiSwiftUI
- **Data Layer**: SwiftData with PlantIdentification model, CoreData-style @Model classes
- **Services**: PlantIdentificationService (AI plant recognition), SubscriptionService (RevenueCat)
- **Views**: MainTabView, CameraView, ChatView, HistoryView, PlantDetailsView, PaywallView, SettingsView

## Code Style & Conventions
- **Swift version**: Compatible with Xcode 16.2+, Swift 5.9+
- **Architecture**: MVVM with ObservableObject services, SwiftUI views
- **Naming**: Use descriptive camelCase for properties/methods, PascalCase for types
- **Comments**: Standard Swift comment headers with creation date and author
- **Error Handling**: Use Result types and custom Error enums for API calls
- **Debug Code**: Use `#if DEBUG` preprocessor for sample data and debug features
- **Imports**: Group by framework (Foundation, SwiftUI, SwiftData, then third-party)
