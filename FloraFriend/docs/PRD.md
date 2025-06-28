## **Product Requirements Document: FloraFriend**

**Version:** 1.1
**Status:** Approved for Development
**Date:** October 26, 2023

### 1. Introduction & Vision

**FloraFriend** is a modern iOS application designed for plant enthusiasts of all levels, from beginners to experienced gardeners. The app's core function is to identify plants instantly and accurately using the device's camera. Beyond identification, it serves as a comprehensive digital plant care assistant, offering detailed information, personalized care advice through an AI-powered chat, and a personal **History** of all identified plants.

**Our vision is to make plant care accessible, enjoyable, and data-driven for everyone by creating the most intuitive and helpful plant companion app on the market.**

### 2. Goals & Objectives

*   **User Goal:** To quickly identify unknown plants, receive accurate care instructions, and have an automatic, hassle-free log of their findings for future reference.
*   **Business Goal:** To build a sustainable revenue stream through a freemium model, converting free users to paid subscribers using the **RevenueCat SDK** for robust subscription management.
*   **Product Goal:** To deliver a beautiful, fast, and highly functional user experience that becomes the go-to app for plant lovers, prioritizing simplicity and powerful features.

### 3. Target Audience

*   **New Plant Owners:** Individuals who have recently acquired plants and need immediate, clear guidance on care, watering, and light requirements to help their plants thrive.
*   **Home Gardeners & Hobbyists:** Enthusiasts who want to identify new plants in their garden or on nature walks and keep a digital log of their discoveries.
*   **Interior Decorators & Landscapers:** Professionals who need quick access to plant information, including toxicity, growth habits, and light needs, while on the job.

### 4. User Stories

*   **As a new plant owner,** I want to take a picture of my plant and instantly know what it is and how to water it, **so I don't accidentally kill it.**
*   **As a hiking enthusiast,** I want to identify interesting plants I see on the trail and have them automatically saved in a list, **so I can look them up again later.**
*   **As a free user,** I want to try the app's identification feature a few times, **so I can be confident in its accuracy before committing to a subscription.**
*   **As a paying subscriber,** I want to ask detailed questions about my plant's health in a chat, **so I can get expert-level advice tailored to my situation.**

### 5. Core User Flow: Identification to History

This revised flow streamlines the user experience by making every successful scan a saved memory.

1.  **App Launch:**
    *   **First-time User:** The user is presented with a paywall screen showcasing PRO features and subscription options. They can select a plan or tap the close button ('X') to proceed with the free version's limitations.
    *   **Returning User:** The user lands directly on the main identification screen (Camera View).

2.  **Plant Identification:**
    *   The user is on the **Camera View**.
    *   The user can either:
        *   Point the camera at a plant and tap the shutter button.
        *   Tap the gallery icon to select an existing photo from their device's library.
    *   The app displays a user-friendly loading/analyzing animation.

3.  **Viewing Results & Automatic Save:**
    *   Upon successful identification, the plant data (image, names, care info) is **automatically saved to the user's local "History".**
    *   The user is immediately navigated to the **Plant Details** screen for the newly identified plant. There is no manual "save" or "add" step required.

4.  **Accessing History:**
    *   The user navigates to the **History** tab.
    *   They see a chronologically sorted list (newest first) of all their past identifications.
    *   Tapping on any plant in the History list re-opens its corresponding **Plant Details** screen.

### 6. Feature Requirements

#### 6.1. Onboarding & Monetization
*   **Paywall:** A native SwiftUI screen presented on first launch and accessible from Settings.
    *   Clearly lists PRO benefits: unlimited identifications, free chat assistance, plant disease detection, etc.
    *   Presents subscription plans (e.g., Yearly, Weekly) fetched from **RevenueCat**.
    *   Includes a prominent "Continue" button and a clear close button ('X').
*   **Free Tier:** Users are granted a limited number of free identifications (e.g., 3). After exhausting them, a prompt to upgrade will be shown when attempting another identification.
*   **Subscription Management:** All purchases, trials, and restorations will be handled via the **RevenueCat SDK**.

#### 6.2. Plant Identification
*   **Camera Interface:** A clean, full-screen camera view with a central shutter button and a gallery access icon.
*   **Identification Engine:** Utilizes a backend service that processes the image with the **ChatGPT Vision API** to ensure API keys are secure. The API will return a structured JSON object with all required plant data.
*   **Automatic Save:** Every successful identification is non-negotiably saved to the local History.

#### 6.3. Identification History
*   **UI:** A dedicated tab/screen titled "History".
*   **List View:** A vertically scrolling list of all past identifications, sorted with the most recent at the top.
*   **History Item:** Each cell in the list must display the plant's thumbnail image, common name, scientific name, and the identification timestamp (e.g., "29 May 2025").
*   **Management:** Users can swipe-to-delete entries from their History.

#### 6.4. Plant Details Screen
*   A rich, vertically scrolling view with collapsable sections for easy navigation.
*   **Content Sections:**
    *   **Header:** Large plant image, Common Name, Scientific Name.
    *   **Description:** A detailed paragraph.
    *   **Care Guide:** Icon-based list (Light, Water, Soil, Temp, Humidity, Fertilizer).
    *   **Characteristics:** Height, Flowering, Leaf details.
    *   **Safety Information:** Clear toxicity warnings for humans and pets with distinct icons.
    *   **Habitat & Origin** and **Scientific Classification**.
*   **Primary Action:** A prominent, floating "Chat" button.

#### 6.5. AI Chat
*   **Interface:** A standard chat UI.
*   **Context-Awareness:** When initiated from a Plant Details screen, the chat session is pre-loaded with the context of that specific plant. The prompt to the ChatGPT text API will be structured to reflect this.
*   **Suggested Prompts:** Offers tappable, pre-written questions ("How much water does it need?") to guide users.

#### 6.6. Settings
*   **Get PRO:** Navigates to the RevenueCat-powered paywall.
*   **Restore Purchases:** Triggers RevenueCat's restore function.
*   **General:** App Version, Write a Review, Rate the App.
*   **Support & Legal:** Mail link for support, and navigation links to the EULA and Privacy Policy.

### 7. Technical Specifications

*   **Language:** **Swift 5+**
*   **UI Framework:** **SwiftUI**
*   **Architecture & State Management:** The app will leverage SwiftUI's native state management tools directly, forgoing a formal MVVM pattern to maintain simplicity and performance.
    *   **`@State`:** For simple, transient view-specific state (e.g., showing/hiding a loading indicator).
    *   **`@StateObject`:** To create and own the lifecycle of reference-type model objects that hold business logic and data for a major view (e.g., an `IdentificationViewModel` that handles the camera, API calls, and resulting data).
    *   **`@ObservedObject`:** To pass an existing model object owned by a parent view down the view hierarchy.
    *   **`@Binding`:** For creating a two-way connection to a state owned by a parent view (e.g., for a custom toggle component).
*   **In-App Purchases:** **RevenueCat SDK** is the sole authority for managing paywalls, offerings, subscriptions, free trials, and receipt validation.
*   **API Integration:** All calls to the ChatGPT API (Vision and Text) will be proxied through a secure backend server (e.g., running on Vercel, Firebase Functions, or similar) to protect API keys. The app will only communicate with our secure backend.
*   **Local Storage:** **SwiftData** for robust, modern persistence of the Identification History.
*   **Camera:** **AVFoundation** for building the custom camera interface.
*   **Photo Library:** **PhotosUI** (`PhotoPicker`).
*   **Networking:** Native `URLSession` with `async/await`.

### 8. Non-Functional Requirements

*   **Performance:**
    *   App launch time should be under 2 seconds.
    *   The identification process (from photo snap to result display) should be optimized for speed, with clear loading states.
*   **Security:** API keys must *never* be stored in the client-side application binary.
*   **Usability:** The app must adhere to Apple's Human Interface Guidelines (HIG) for a familiar, intuitive user experience.
*   **Accessibility:** The app must support Dynamic Type and be navigable using VoiceOver to ensure it is usable by all.

### 9. Success Metrics (KPIs)

*   **Activation Rate:** Percentage of new users who complete their first successful identification.
*   **Conversion Rate:** Percentage of free users who start a trial or subscribe to a PRO plan (tracked via RevenueCat).
*   **Retention:** D1, D7, and D30 user retention rates.
*   **Revenue:** Monthly Recurring Revenue (MRR) and Churn Rate (tracked via RevenueCat).
*   **Engagement:** Average number of identifications per user per week; number of AI chat sessions initiated.

### 10. Future Considerations (Post V1.1)

*   **Plant Disease Detection:** An advanced feature allowing users to photograph a diseased leaf to identify the issue and get treatment advice.
*   **Care Reminders:** Allow users to set custom push notifications for watering and fertilizing schedules based on their plant's needs.
*   **Augmented Reality (AR):** Use ARKit to preview how a plant would look in a user's space before they buy it.
