//
//  OnboardingViewModel.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import AVFoundation
import Photos

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var isCompleted: Bool = false
    
    private let totalSteps = 5
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            completeOnboarding()
        }
    }
    
    func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
            DispatchQueue.main.async {
                self.nextStep()
            }
        }
    }
    
    func skipPaywall() {
        nextStep()
    }
    
    func completeOnboarding() {
        isCompleted = true
    }
}
