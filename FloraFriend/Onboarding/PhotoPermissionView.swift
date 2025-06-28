//
//  PhotoPermissionView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct PhotoPermissionView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 100))
                .foregroundColor(.green500)
                .opacity(showIcon ? 1 : 0)
            
            VStack(spacing: 16) {
                Text("Use Your Favorite Photos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: showTitle)
                
                Text("You can also identify plants from your existing photos. Grant access to select your best shots from the gallery.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showDescription ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6), value: showDescription)
            }
            
            Spacer()
            
            Button(action: {
                self.viewModel.requestPhotoLibraryPermission()
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green500)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .opacity(showButton ? 1 : 0)
            .animation(.easeInOut(duration: 0.6), value: showButton)
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showIcon = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                showTitle = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showDescription = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                showButton = true
            }
        }
    }
}
