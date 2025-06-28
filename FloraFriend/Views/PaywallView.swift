//
//  PaywallView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorscheme
    @State private var isPurchasing = false
    @State private var isAnimating = false
    @State private var showCloseButton = false
    @State private var timerProgress: CGFloat = 0
    @State private var freeTrialEnabled = true
    
    private let features = [
        ("leaf.fill", "Unlimited Plant Identifications", "Identify as many plants as you want"),
        ("message.fill", "AI Plant Expert Chat", "Get personalized care advice"),
        ("cross.case.fill", "Plant Disease Detection", "Diagnose plant health issues"),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                VStack(spacing: adaptiveSpacing(for: geometry.size)) {
                    
                    headerSection(for: geometry.size)
                    featuresSection(for: geometry.size)
                    
                    Spacer(minLength: adaptiveMinSpacing(for: geometry.size))
                    
                    if self.subscriptionService.packages.isEmpty {
                        placeholderPricing
                    } else {
                        pricingSection
                    }
                    termsSection
                }
                .padding(adaptivePadding(for: geometry.size))
                .task {
                    self.subscriptionService.fetchPackages()
                }
            .onAppear {
                isAnimating = true
                startTimer()
            }
            .onChange(of: self.subscriptionService.defaultSelected?.identifier ?? "", { oldValue, newValue in
                if let package = self.subscriptionService.defaultSelected, package.packageType == .weekly {
                    self.freeTrialEnabled = true
                } else {
                    self.freeTrialEnabled = false
                }
            })
            .onChange(of: self.freeTrialEnabled, { oldValue, newValue in
                if newValue {
                    self.subscriptionService.defaultSelected = self.subscriptionService.packages.first(where: { $0.packageType == .weekly })
                } else {
                    self.subscriptionService.defaultSelected = self.subscriptionService.packages.first(where: { $0.packageType != .weekly })
                }
            })
                .navigationBarHidden(true)
                .toolbar(.hidden, for: .navigationBar)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            CircularTimerCloseButton(
                                showCloseButton: $showCloseButton,
                                timerProgress: $timerProgress
                            ) {
                                dismiss()
                            }
                        }
                        Spacer()
                    }
                    .padding([.top, .trailing], adaptivePadding(for: geometry.size))
                )
            }
        }
    }
    
    private var placeholderPricing: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.green200)
                .overlay {
                    ProgressView()
                }
                .frame(height: 50)
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.green200)
                .overlay {
                    ProgressView()
                }
                .frame(height: 50)
        }
    }
    
    private func headerSection(for size: CGSize) -> some View {
        VStack(spacing: size.height > 700 ? 8 : 4) {
            Image(systemName: "leaf.fill")
                .font(.system(size: size.height > 700 ? 60 : 40))
                .foregroundColor(.green500)
                .symbolEffect(.wiggle, options: .repeat(.periodic()), value: self.isAnimating)
            
            HStack(spacing: 2) {
                Text("FloraFriend")
                    .font(size.height > 700 ? .largeTitle : .title2)
                    .fontWeight(.bold)
                Text("PRO")
                    .font(size.height > 700 ? .title2 : .title3)
                    .fontWeight(.black)
                    .padding(.horizontal, size.height > 700 ? 16 : 12)
                    .padding(.vertical, size.height > 700 ? 4 : 2)
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green500.gradient)
                    }
            }
            
            Text("Unlock the full potential of plant identification")
                .font(size.height > 700 ? .headline : .subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func featuresSection(for size: CGSize) -> some View {
        VStack(spacing: size.height > 700 ? 16 : 10) {
            ForEach(features, id: \.0) { icon, title, description in
                HStack(spacing: size.height > 700 ? 16 : 12) {
                    Image(systemName: icon)
                        .font(size.height > 700 ? .title2 : .title3)
                        .foregroundColor(.green500)
                        .frame(width: size.height > 700 ? 30 : 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(size.height > 700 ? .headline : .subheadline)
                            .foregroundColor(colorscheme == .dark ? .green500 : .green900)

                        Text(description)
                            .font(size.height > 700 ? .caption : .caption2)
                            .foregroundColor(colorscheme == .dark ? .green400 : .green700)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(adaptivePadding(for: size))
        .background(Color.green100)
        .cornerRadius(12)
    }
    
    private var pricingSection: some View {
        VStack(spacing: 8) {
            ForEach(subscriptionService.packages, id: \.identifier) { package in
                PackageView(
                    package: package,
                    isSelected: self.subscriptionService.defaultSelected?.identifier == package.identifier
                ) {
                    self.subscriptionService.defaultSelected = package
                }
            }
            
            if let weeklyPackage = subscriptionService.packages.first(where: { $0.storeProduct.subscriptionPeriod?.unit == .week }),
               let intro = weeklyPackage.storeProduct.introductoryDiscount {
                HStack {
                    Text("3 days free trial")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Toggle(isOn: $freeTrialEnabled) {
                        Text(intro.localizedPriceString)
                    }
                    .labelsHidden()
                    .tint(.green500)
                }
                .padding(.horizontal)
            }
            
            Button(action: purchaseSelected) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(self.subscriptionService.defaultSelected?.packageType == .weekly ? "Try for free" : "Subscribe now")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(self.subscriptionService.defaultSelected != nil ? Color.green500 : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(25)
                .padding(.top, 12)
            }
            .disabled(self.subscriptionService.defaultSelected == nil || isPurchasing)
        }
    }
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Terms apply. Cancel anytime.")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            HStack {
                Button("Restore Purchases") {
                    restorePurchases()
                }
                .foregroundColor(.green500)
                .buttonStyle(.plain)
                
                Text("•")
                    .foregroundColor(.green200)

                Link("Privacy Policy", destination: URL(string: Constants.privacyPolicyURL)!)

                Text("•")
                    .foregroundColor(.green200)

                Link("Terms of Service", destination: URL(string: Constants.termsOfServiceURL)!)
            }
            .font(.footnote)
            .foregroundColor(.green500)
        }
    }
    
    private func purchaseSelected() {
        guard let package = self.subscriptionService.defaultSelected else { return }
        
        isPurchasing = true
        
        Task {
            do {
                let success = try await subscriptionService.purchase(package: package)
                DispatchQueue.main.async {
                    isPurchasing = false
                    if success {
                        dismiss()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isPurchasing = false
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                try await subscriptionService.restorePurchases()
                DispatchQueue.main.async {
                    if subscriptionService.isSubscribed {
                        dismiss()
                    }
                }
            } catch {
                // Handle error
            }
        }
    }
    
    private func startTimer() {
        #if DEBUG
        let timerDuration: TimeInterval = 3
        #else
        let timerDuration: TimeInterval = 7
        #endif
        withAnimation(.linear(duration: timerDuration)) {
            timerProgress = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timerDuration) {
            showCloseButton = true
        }
    }
    
    private func adaptiveSpacing(for size: CGSize) -> CGFloat {
        let screenHeight = size.height
        if screenHeight > 900 {
            return 32
        } else if screenHeight > 700 {
            return 20
        } else {
            return 12
        }
    }
    
    private func adaptivePadding(for size: CGSize) -> CGFloat {
        let screenHeight = size.height
        if screenHeight > 900 {
            return 32
        } else if screenHeight > 700 {
            return 20
        } else {
            return 16
        }
    }
    
    private func adaptiveMinSpacing(for size: CGSize) -> CGFloat {
        let screenHeight = size.height
        if screenHeight > 900 {
            return 40
        } else if screenHeight > 700 {
            return 20
        } else {
            return 8
        }
    }
}



#Preview {
    PaywallView()
        .environmentObject(SubscriptionService())
}
