//
//  ContentView.swift
//  Simple Keys
//
//  Created by Corey Lofthus on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    let offset: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 0) {
            
            //rectangles are keys
            HStack(spacing: 8) {
                Spacer()
                    .frame(width: 64)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                Spacer()
                    .frame(width: 64)
            }
            
            //spaces are keys
            HStack(spacing: 16) {
                Spacer()
                    .frame(width: 120 - offset)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                Spacer()
                    .frame(width: 88 + offset)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                Spacer()
                    .frame(width: 120 - offset)
            }
                .frame(height: 256)
        }
        .background{
            Color.black.opacity(0.08)
        }
        .ignoresSafeArea()
        
    }
}

#Preview {
    ContentView()
}
