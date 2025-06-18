//
//  VideoPlayer.swift
//  ChetaPlayer
//
//  Created by Shaikat on 17.6.2025.
//

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    
    func makeUIViewController(context: Context)-> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        
        return controller
    }
    
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController,
                                context: Context) { }
    
}
