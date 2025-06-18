//
//  ContentView.swift
//  ChetaPlayer
//
//  Created by Shaikat on 16.6.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Use GeometryReader to get screen size and safe area insets for adaptive layout
        GeometryReader {
            let size = $0.size
            let safeAreaInsets = $0.safeAreaInsets
            
            Home(size: size,
                 safeArea: safeAreaInsets)
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}
