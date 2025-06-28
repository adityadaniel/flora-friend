//
//  CircularTimerCloseButton.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 14/06/25.
//

import SwiftUI

struct CircularTimerCloseButton: View {
    @Binding var showCloseButton: Bool
    @Binding var timerProgress: CGFloat
    let onClose: () -> Void
    
    var body: some View {
        if showCloseButton {
            Button("×") {
                onClose()
            }
            .font(.title2)
            .foregroundColor(.primary)
        } else {
            ZStack {
                Circle()
                    .stroke(Color.green50, lineWidth: 4)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(Color.green500, lineWidth: 4)
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
            }
        }
    }
}
