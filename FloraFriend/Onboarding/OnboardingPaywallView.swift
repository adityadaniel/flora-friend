//
//  OnboardingPaywallView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct OnboardingPaywallView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var selectedPlan: PaywallPlan = .yearly
    
    enum PaywallPlan {
        case yearly, weekly
    }
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button(action: {
                    viewModel.skipPaywall()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                Text("Unlock FloraFriend PRO")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    FeatureRow(icon: "infinity", text: "Unlimited Scans")
                    FeatureRow(icon: "message.fill", text: "AI Chat Assistant")
                    FeatureRow(icon: "cross.case.fill", text: "Disease Detection")
                    FeatureRow(icon: "leaf.arrow.circlepath", text: "Plant Care Reminders")
                }
                .padding(.vertical)
            }
            
            VStack(spacing: 12) {
                PlanCard(
                    title: "Yearly Plan",
                    price: "$29.99/year",
                    savings: "Save 60%",
                    isSelected: selectedPlan == .yearly
                ) {
                    selectedPlan = .yearly
                }
                
                PlanCard(
                    title: "Weekly Plan",
                    price: "$2.99/week",
                    savings: nil,
                    isSelected: selectedPlan == .weekly
                ) {
                    selectedPlan = .weekly
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    // TODO: Integrate with RevenueCat
                    viewModel.nextStep()
                }) {
                    Text("Start Free Trial & Subscribe")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    viewModel.skipPaywall()
                }) {
                    Text("Skip")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let savings: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(price)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let savings = savings {
                    Text(savings)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .fill(isSelected ? Color.green : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
            )
        }
    }
}