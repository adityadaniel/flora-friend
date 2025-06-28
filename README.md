# 🌱 FloraFriend

**FloraFriend** is a modern iOS application that helps plant enthusiasts identify plants instantly using their device's camera. Beyond identification, it serves as a comprehensive digital plant care assistant with AI-powered chat support and automatic plant history tracking.

## ✨ Features

- **📸 Instant Plant Identification**: Point your camera at any plant and get immediate identification results
- **🤖 AI Plant Care Assistant**: Chat with AI to get personalized plant care advice
- **📝 Automatic History**: Every identified plant is automatically saved to your personal history
- **💎 Premium Features**: Unlimited identifications, advanced chat features, and disease detection
- **🔒 Privacy-First**: Secure API handling with no sensitive data stored locally

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**
- **Apple Developer Account** (for device testing and App Store distribution)

### Dependencies

FloraFriend uses the following Swift Package Manager dependencies:

- [**RevenueCat**](https://github.com/RevenueCat/purchases-ios-spm) (v5.28.1) - Subscription management
- [**AIProxy**](https://github.com/lzell/AIProxySwift) (v0.109.1) - Secure OpenAI API integration
- [**ConfettiSwiftUI**](https://github.com/simibac/ConfettiSwiftUI) (v2.0.3) - Celebration animations
- [**Lottie**](https://github.com/airbnb/lottie-ios) (v4.5.2) - Loading animations
- [**KeychainAccess**](https://github.com/kishikawakatsumi/KeychainAccess) - Secure data storage

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/FloraFriend.git
   cd FloraFriend
   ```

2. **Open in Xcode**:
   ```bash
   open FloraFriend.xcodeproj
   ```

3. **Install Dependencies**: 
   Dependencies are automatically resolved via Swift Package Manager when you build the project.

## ⚙️ Configuration

### 1. RevenueCat Setup

1. Create a [RevenueCat account](https://app.revenuecat.com)
2. Create a new project and get your API key
3. Update the API key in `FloraFriendApp.swift`:
   ```swift
   Purchases.configure(withAPIKey: "your_revenuecat_api_key_here")
   ```

### 2. AIProxy Setup

FloraFriend uses AIProxy to securely access OpenAI's Vision API without exposing API keys in the client.

1. **Sign up for AIProxy**: Visit [aiproxy.com](https://aiproxy.com)
2. **Get OpenAI API Key**: From [OpenAI Platform](https://platform.openai.com)
3. **Configure AIProxy**: Follow the setup guide in `FloraFriend/docs/aiproxy-setup.md`
4. **Update Configuration**: Set your AIProxy credentials in `PlantIdentificationService.swift`

### 3. App Permissions

The app requires the following permissions (already configured in `Info.plist`):
- **Camera Access**: For taking plant photos
- **Photo Library Access**: For selecting existing photos

## 🏗️ Project Structure

```
FloraFriend/
├── FloraFriendApp.swift          # Main app entry point
├── Models/
│   └── Plant.swift               # Core data models
├── Services/
│   ├── PlantIdentificationService.swift  # AI identification logic
│   ├── PlantChatService.swift    # AI chat functionality
│   ├── SubscriptionService.swift # RevenueCat integration
│   └── KeychainService.swift     # Secure storage
├── Views/
│   ├── CameraView.swift          # Main camera interface
│   ├── PlantDetailsView.swift    # Plant information display
│   ├── ChatView.swift            # AI chat interface
│   ├── HistoryView.swift         # Plant identification history
│   ├── SettingsView.swift        # App settings
│   └── PaywallView.swift         # Subscription management
├── Onboarding/
│   └── ...                       # User onboarding flow
└── Utility/
    ├── Constants.swift           # App constants
    └── Color+Ext.swift           # UI extensions
```

## 🛠️ Development

### Building the Project

1. **Select your target device** or simulator in Xcode
2. **Build and run** using `Cmd + R`
3. **For device testing**: Ensure your Apple Developer account is configured

### Architecture

- **Framework**: SwiftUI with native state management
- **Data Persistence**: SwiftData for local plant history
- **Networking**: URLSession with async/await
- **Camera**: AVFoundation for custom camera interface
- **Photo Selection**: PhotosUI framework

### Key Components

- **PlantIdentification**: Core model for identified plants
- **PlantChatMessage**: Chat conversation storage
- **CameraManager**: Camera functionality management
- **SubscriptionService**: Premium feature management

## 🧪 Testing

Run tests using Xcode's test navigator or:
```bash
xcodebuild test -scheme FloraFriend -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📱 Features Overview

### Core Functionality
- **Camera Integration**: Native camera with gallery selection
- **Plant Identification**: AI-powered identification using OpenAI Vision API
- **Automatic History**: Every identification is saved locally
- **Plant Details**: Comprehensive care information and characteristics

### Premium Features (RevenueCat)
- **Unlimited Identifications**: Remove free tier limitations
- **AI Chat Support**: Personalized plant care advice
- **Disease Detection**: Advanced plant health analysis
- **Priority Support**: Enhanced customer service

### User Experience
- **Smooth Onboarding**: Guided setup with permission requests
- **Intuitive Navigation**: Simple tab-based interface
- **Loading States**: Beautiful animations during processing
- **Error Handling**: Graceful error management with user feedback

## 🔐 Security & Privacy

- **API Security**: All OpenAI API calls are proxied through AIProxy
- **Local Storage**: Plant data stored securely using SwiftData
- **Keychain Integration**: Sensitive data protected in iOS Keychain
- **No Data Collection**: User privacy is prioritized

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- **Documentation**: Check the `docs/` folder for detailed guides
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Developer**: Created by [Daniel Aditya Istyana](mailto:your-email@example.com)

## 🙏 Acknowledgments

- **OpenAI** for the Vision API
- **RevenueCat** for subscription management
- **AIProxy** for secure API integration
- **Open Source Community** for the amazing Swift packages

---

**Made with 🌱 for plant lovers everywhere**