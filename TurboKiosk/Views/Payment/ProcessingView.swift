//
//  ProcessingView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI

struct ProcessingView: View {
    // Animation state
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .stroke(lineWidth: 8)
                .frame(width: 80, height: 80)
                .foregroundColor(Color.blue.opacity(0.3))
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.blue, lineWidth: 8)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                )
                .onAppear {
                    isAnimating = true
                }
            
            Text("Processing Your Payment")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Please do not close this screen")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(30)
        .background(Color.gray.opacity(0.7))
        .cornerRadius(15)
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            ProcessingView()
        }
    }
}
