//
//  SettingsView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @EnvironmentObject var subscriptionService: SubscriptionService
    @State private var showingPaywall = false
    @State private var showingMailComposer = false
    @State private var mailResult: Result<MFMailComposeResult, Error>?
    
    var body: some View {
        NavigationView {
            List {
                subscriptionSection
                generalSection
                supportSection
                legalSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(result: $mailResult)
        }
    }
    
    private var subscriptionSection: some View {
        Section {
            if subscriptionService.isSubscribed {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "crown.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("FloraFriend PRO")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Active subscription")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("Active")
                        .font(.caption).bold()
                        .foregroundColor(.green50)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green700)
                        .cornerRadius(8)
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green50)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.green700, lineWidth: 2)
                        }
                }
                
            } else {
                VStack(alignment: .center, spacing: 4) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green100)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green500)
                                    .font(.title3)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Get PRO")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("✓ Unlimited plant identifications")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .onTapGesture {
                        showingPaywall = true
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green600)
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var generalSection: some View {
        Section("GENERAL") {
            SettingsRow(
                icon: "info.circle",
                iconColor: .blue,
                title: "Version",
                subtitle: appVersion,
                action: nil
            )
            
            SettingsRow(
                icon: "arrow.clockwise",
                iconColor: .blue,
                title: "Restore purchases",
                subtitle: "Recover your plan if it's missing",
                action: {
                    Task {
                        try? await subscriptionService.restorePurchases()
                    }
                }
            )
            
            SettingsRow(
                icon: "square.and.pencil",
                iconColor: .red,
                title: "Write a review ❤️",
                subtitle: "Your feedback means the world to me and helps make the app even better!",
                action: writeReview
            )
            
            SettingsRow(
                icon: "star.fill",
                iconColor: .orange,
                title: "Rate the App!",
                subtitle: "Give the app some stars! It takes less than 5 seconds.",
                action: rateApp
            )
        }
    }
    
    private var supportSection: some View {
        Section("SUPPORT") {
            SettingsRow(
                icon: "envelope.fill",
                iconColor: .blue,
                title: "Mail",
                subtitle: "Bugs, ideas, and suggestions are very welcome!",
                action: MFMailComposeViewController.canSendMail() ? contactSupport : nil
            )
        }
    }
    
    private var legalSection: some View {
        Section("AGREEMENTS") {
            SettingsRow(
                icon: "doc.text.fill",
                iconColor: .gray,
                title: "EULA",
                subtitle: "End User License Agreement",
                action: {
                    if let url = URL(string: Constants.termsOfServiceURL) {
                        UIApplication.shared.open(url)
                    }
                }
            )
            
            SettingsRow(
                icon: "doc.text.fill",
                iconColor: .gray,
                title: "Privacy Policy",
                subtitle: nil,
                action: {
                    if let url = URL(string: Constants.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                }
            )
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func writeReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id/write-review") else { return }
        UIApplication.shared.open(url)
    }
    
    private func rateApp() {
        guard let url = URL(string: Constants.appstoreURL) else { return }
        UIApplication.shared.open(url)
    }
    
    private func contactSupport() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients([Constants.supportEmail])
        composer.setSubject("FloraFriend Support")
        
        let deviceInfo = """
        
        ---
        Device Info:
        iOS Version: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.model)
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
        """
        
        composer.setMessageBody("Please describe your issue or feedback:\n\n\(deviceInfo)", isHTML: false)
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            parent.dismiss()
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(iconColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.title3)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SubscriptionService())
}
