//
//  PackageView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 14/06/25.
//

import SwiftUI
import RevenueCat
import Observation

struct PackageView: View {
    let package: Package
    var isSelected: Bool
    let onTap: () -> Void
    
    private var isPopular: Bool {
        package.packageType == .annual
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 2) {
                            Text(package.storeProduct.sk2Product?.displayName ?? "")
                            
                            if let period = package.storeProduct.subscriptionPeriod {
                                Text(periodDescription(period))
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        
                        if isPopular {
                            Text("Save 95%")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.gradient)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let period = package.storeProduct.subscriptionPeriod {
                            Text(repeatingPeriod(period))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                
            }
            .padding()
            .background(isSelected ? Color.green500.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green500 : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
    
    private func periodDescription(_ period: SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 1 ? "Daily" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "Weekly" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "Monthly" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "Annual" : "\(period.value) years"
        @unknown default:
            return ""
        }
    }
    
    private func repeatingPeriod(_ period: SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 1 ? "per day" : "\(period.value) days"
        case .week:
            return period.value == 1 ? "per week" : "\(period.value) weeks"
        case .month:
            return period.value == 1 ? "per month" : "\(period.value) months"
        case .year:
            return period.value == 1 ? "per year" : "\(period.value) years"
        @unknown default:
            return ""
        }
    }
}
