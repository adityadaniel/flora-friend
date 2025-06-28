//
//  OnboardingFlowView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") private var shouldShowOnboarding = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(viewModel.currentStep + 1), total: 5.0)
                    .tint(.green500)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Current step view
                Group {
                    switch viewModel.currentStep {
                    case 0:
                        WelcomeView()
                    case 1:
                        CameraPermissionView()
                    case 2:
                        PhotoPermissionView()
                    case 3:
                        PaywallView()
                    case 4:
                        CompletionView()
                    default:
                        EmptyView()
                    }
                }
                .environmentObject(viewModel)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(duration: 0.5), value: viewModel.currentStep)
            }
        }
        .onReceive(viewModel.$isCompleted) { completed in
            if completed {
                self.shouldShowOnboarding = false
            }
        }
    }
}
