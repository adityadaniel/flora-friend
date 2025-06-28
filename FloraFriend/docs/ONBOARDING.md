### **FloraFriend: Onboarding Flow Specification**
### 1. Overview & Goals

#### 1.1. Overview
This specification details the user onboarding experience for new FloraFriend users. The flow consists of a 5-step, full-screen sequence that is displayed once upon the first launch of the application after installation. Its primary purpose is to welcome the user, secure necessary system permissions, communicate the app's value, and present the premium subscription offer before transitioning to the main application.

#### 1.2. Goals
*   **Welcome & Educate:** Create a positive first impression and clearly communicate the app's core functionalities.
*   **Permission Acquisition:** Increase the acceptance rate for Camera and Photo Library permissions by providing context before triggering the system prompts.
*   **Monetization:** Present the value proposition of the PRO plan at a moment of high user engagement and intent.
*   **Activation:** Seamlessly guide the user from installation to their first potential action within the main app.

### 2. User Flow & Logic

The onboarding flow is managed by a persistent flag.

1.  **On App Launch:** The application checks the value of a flag stored in `UserDefaults` (e.g., `hasCompletedOnboarding`).
2.  **If `hasCompletedOnboarding` is `false` (Default):**
    *   The `OnboardingView` is presented modally over the entire screen.
    *   The user progresses through the 5 steps.
    *   Upon completion of the final step, the `hasCompletedOnboarding` flag is set to `true`.
    *   The `OnboardingView` is dismissed, revealing the main application interface.
3.  **If `hasCompletedOnboarding` is `true`:**
    *   The onboarding flow is skipped entirely.
    *   The user is taken directly to the main application interface.

### 3. Common UI Components

#### 3.1. Continuous Progress Bar
*   **Description:** A single, continuous, capsule-shaped progress bar displayed at the top of each onboarding screen.
*   **Appearance:**
    *   **Track:** A light gray (`Color.gray.opacity(0.3)`) capsule background that spans the width of the screen (with padding).
    
    *   **Fill:** A solid green (`Color.green`) capsule that fills the track from left to right.
*   **Behavior:**
    *   The width of the Fill component is proportional to the user's progress.
    *   `Fill Width = Total Width * (Current Step Index + 1) / Total Steps`
    *   The bar must animate smoothly to its new width over a duration of `0.3s` with an `easeInOut` curve whenever the user advances a step.

#### 3.2. Primary Action Button
*   **Description:** Used for the main call-to-action on each screen.
*   **Appearance:** Full-width, green background, white bold text, with rounded corners.
*   **Example:** "Get Started", "Allow Camera Access".

#### 3.3. Secondary Action Button
*   **Description:** Used for secondary actions like skipping the paywall.
*   **Appearance:** Plain text button, typically using the app's accent color.
*   **Example:** "Skip", "Maybe Later".

### 4. Screen-by-Screen Specification

#### **Screen 1: Welcome**
*   **Purpose:** To greet the user and set a friendly, modern tone.
*   **Progress Bar State:** 20% full.
*   **UI Elements:**
    1.  App Icon (FloraFriend leaf logo)
    2.  Title Text
    3.  Description Text
    4.  Primary Action Button
*   **Content:**
    *   **Title:** "Welcome to FloraFriend"
    *   **Description:** "Your Personal Plant Expert."
    *   **Button Text:** "Get Started"
*   **Behavior & Animation:**
    *   The screen appears with all elements initially invisible (opacity 0).
    *   **0.0s - 2.0s:** The App Icon fades in.
    *   **2.0s - 4.0s:** The Title Text fades in.
    *   **4.0s - 6.0s:** The Description Text fades in.
    *   **At 6.0s:** The "Get Started" button fades in quickly (`0.3s`).
*   **Action:** Tapping "Get Started" advances the user to Screen 2.

#### **Screen 2: Camera Permission**
*   **Purpose:** To provide context for the camera permission request, increasing user trust.
*   **Progress Bar State:** Animates to 40% full.
*   **UI Elements:**
    1.  Large Icon (`systemName: "camera.fill"`)
    2.  Title Text
    3.  Description Text
    4.  Primary Action Button
*   **Content:**
    *   **Title:** "Identify Plants Instantly"
    *   **Description:** "To identify plants in real-time, FloraFriend needs access to your camera. We only use it when you're ready to scan."
    *   **Button Text:** "Allow Camera Access"
*   **Behavior:**
    *   Tapping the button triggers the native iOS system prompt for camera permission.
    *   After the user interacts with the system prompt (taps "Allow" or "Don't Allow"), the flow automatically advances to Screen 3.

#### **Screen 3: Photo Library Permission**
*   **Purpose:** To provide context for Photo Library access.
*   **Progress Bar State:** Animates to 60% full.
*   **UI Elements:**
    1.  Large Icon (`systemName: "photo.on.rectangle.angled"`)
    2.  Title Text
    3.  Description Text
    4.  Primary Action Button
*   **Content:**
    *   **Title:** "Use Your Favorite Photos"
    *   **Description:** "You can also identify plants from your existing photos. Grant access to select your best shots from the gallery."
    *   **Button Text:** "Allow Photo Access"
*   **Behavior:**
    *   Tapping the button triggers the native iOS system prompt for photo library permission.
    *   After the user interacts with the system prompt, the flow automatically advances to Screen 4.

#### **Screen 4: Paywall**
*   **Purpose:** To convert the user to a PRO subscriber.
*   **Progress Bar State:** Animates to 80% full.
*   **UI Elements:**
    1.  Title Text
    2.  List of PRO features with icons
    3.  Subscription plan selection UI (e.g., two selectable cards for Yearly and Weekly)
    4.  Primary Action Button
    5.  Secondary Action Button (Close/Skip)
*   **Content:**
    *   **Title:** "Unlock FloraFriend PRO"
    *   **Features:** "Unlimited Scans", "AI Chat Assistant", "Disease Detection", etc.
    *   **Button Text:** "Start Free Trial & Subscribe" (or similar, from RevenueCat)
    *   **Secondary Text:** "Skip" or a visible 'X' icon in the top corner.
*   **Behavior:**
    *   Tapping the primary button initiates the purchase flow via the RevenueCat SDK. On success or failure, the flow advances to Screen 5.
    *   Tapping "Skip" or 'X' immediately advances the flow to Screen 5.

#### **Screen 5: Onboarding Complete**
*   **Purpose:** To provide a satisfying conclusion and transition the user into the app.
*   **Progress Bar State:** Animates to 100% full.
*   **UI Elements:**
    1.  Large Icon (`systemName: "checkmark.circle.fill"`)
    2.  Title Text
    3.  Description Text
    4.  Primary Action Button
*   **Content:**
    *   **Title:** "You're All Set!"
    *   **Description:** "Let's start identifying. Point your camera at any plant or choose a photo to begin your journey."
    *   **Button Text:** "Start Exploring"
*   **Behavior:**
    *   Tapping the button performs two actions:
        1.  Sets the `hasCompletedOnboarding` flag to `true` in `UserDefaults`.
        2.  Dismisses the entire `OnboardingView`.

### 5. Technical Implementation Details

*   **Framework:** SwiftUI
*   **State Management:**
    *   **`@AppStorage("hasCompletedOnboarding")`:** Used in the main `App` struct to control whether the onboarding view is shown.
    *   **`@State private var currentStep`:** Used within `OnboardingView` to track the current page.
    *   **`TabView` with `.page` style:** Will be used as the container for the 5 screens, with its index bound to `currentStep`.
*   **Permissions:**
    *   **Camera:** `AVFoundation`'s `AVCaptureDevice.requestAccess(for: .video)`.
    *   **Photo Library:** `Photos` framework's `PHPhotoLibrary.requestAuthorization(for:)`.
*   **Monetization:** The paywall screen will be powered by the **RevenueCat SDK** to fetch offerings and handle transactions.

### 6. Acceptance Criteria

*   **AC-1:** On first app launch after a clean install, the user must be presented with the 5-step onboarding flow.
*   **AC-2:** On all subsequent launches, the user must be taken directly to the main app screen.
*   **AC-3:** The continuous progress bar must be present on all steps and animate smoothly between states.
*   **AC-4:** The Welcome Screen's icon, title, and description must fade in sequentially as specified.
*   **AC-5:** Tapping the permission buttons on Screens 2 and 3 must trigger the corresponding native iOS permission dialog.
*   **AC-6:** The user must be able to advance past the permission screens regardless of their choice (Allow/Don't Allow).
*   **AC-7:** The user must have an explicit option (e.g., 'X' or 'Skip' button) to bypass the paywall on Screen 4.
*   **AC-8:** Tapping the final button on Screen 5 must permanently dismiss the onboarding flow for all future sessions.
*   **AC-9:** Deleting and reinstalling the app must reset the flow, presenting onboarding again on the next first launch.
