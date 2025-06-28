//
//  WelcomeView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showDescription = false
    @State private var showButton = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 100))
                .foregroundColor(.green500)
                .opacity(showIcon ? 1 : 0)
                .symbolEffect(.wiggle, options: .speed(2), value: showIcon)
            
            VStack(spacing: 16) {
                Text("Welcome to FloraFriend")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showTitle ? 1 : 0)
                    .animation(.easeInOut(duration: 2), value: showTitle)
                
                Text("Your Personal Plant Expert.")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showDescription ? 1 : 0)
                    .animation(.easeInOut(duration: 2), value: showDescription)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Get Started")
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
            .animation(.easeInOut(duration: 0.3), value: showButton)
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                showIcon = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showTitle = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                showDescription = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                showButton = true
            }
        }
    }
}
