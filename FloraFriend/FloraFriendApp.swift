//
//  FloraFriendApp.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct FloraFriendApp: App {
    @AppStorage("hasCompletedOnboarding") private var shouldShowOnboarding = true
    @StateObject private var subscriptionService = SubscriptionService()
    @StateObject private var plantIdentificationService = PlantIdentificationService()
    @StateObject private var cameraManager = CameraManager()
    @State private var showPaywall = false
    
    private var modelContainer: ModelContainer {
        do {
            let container = try ModelContainer(
                for: PlantIdentification.self, PlantChatMessage.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            return container
        } catch {
            print("Failed to create model container: \(error)")
            // Fallback to in-memory container
            do {
                return try ModelContainer(
                    for: PlantIdentification.self, PlantChatMessage.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
            } catch {
                fatalError("Failed to create fallback model container: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CameraView()
                .fullScreenCover(isPresented: $shouldShowOnboarding) {
                    OnboardingView()
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    PaywallView()
                }
                .task {
                    if !self.shouldShowOnboarding {
                        if !subscriptionService.isSubscribed {
                            showPaywall = true
                        }
                    }
                }
                .environmentObject(subscriptionService)
                .environmentObject(plantIdentificationService)
                .environmentObject(cameraManager)
        }
        .modelContainer(modelContainer)
    }
    
    init() {
        configureRevenueCat()
    }
    
    private func configureRevenueCat() {
        // Replace with your actual RevenueCat API key
        Purchases.configure(withAPIKey: "REPLACE_WITH_YOUR_REVENUECAT_API_KEY")
        
        // Enable debug logs (remove in production)
        Purchases.logLevel = .debug
    }
}
