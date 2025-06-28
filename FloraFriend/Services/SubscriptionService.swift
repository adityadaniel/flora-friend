//
//  SubscriptionService.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import Foundation
import RevenueCat

@MainActor
class SubscriptionService: ObservableObject {
    @Published var isSubscribed = false
    @Published var freeIdentificationsLeft = 1
    @Published var packages: [Package] = []
    @Published var defaultSelected: Package?
    
    private let keychainService = KeychainService.shared
    private let maxFreeScans = 1
    
    init() {
        checkSubscriptionStatus()
        fetchPackages()
        updateFreeIdentificationsLeft()
    }
    
    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            if let customerInfo = customerInfo {
                self?.isSubscribed = customerInfo.entitlements.active.isEmpty == false
            }
        }
    }
    
    func fetchPackages() {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            if let offerings = offerings,
               let currentOffering = offerings.current {
                self?.packages = currentOffering.availablePackages
                self?.defaultSelected = currentOffering.weekly
            }
        }
    }
    
    func purchase(package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        
        self.isSubscribed = result.customerInfo.entitlements.active.isEmpty == false
        
        return !result.userCancelled
    }
    
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        
        self.isSubscribed = customerInfo.entitlements.active.isEmpty == false
    }
    
    func canIdentifyPlant() -> Bool {
        #if DEBUG
        return true
        #else
        return isSubscribed || keychainService.canUseFreeScans(maxFreeScans: maxFreeScans)
        #endif
    }
    
    func useIdentification() async {
        if !isSubscribed && keychainService.canUseFreeScans(maxFreeScans: maxFreeScans) {
            keychainService.incrementFreeScansUsed()
            updateFreeIdentificationsLeft()
        }
    }
    
    private func updateFreeIdentificationsLeft() {
        freeIdentificationsLeft = max(0, maxFreeScans - keychainService.freeScansUsed)
    }
}
