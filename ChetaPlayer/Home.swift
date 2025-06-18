//
//  Home.swift
//  ChetaPlayer
//
//  Created by Shaikat on 16.6.2025.
//

//  A beginner-friendly, modular video player using SwiftUI and AVKit.
//  Features: Play/Pause, Forward/Reverse, Custom Seeker, Auto-hiding Controls


import SwiftUI
import AVKit


struct Home: View {
    // MARK: - Properties
    var size: CGSize
    var safeArea: EdgeInsets
    
    // Video player
    @State private var player: AVPlayer? = setupPlayer()
    
    @State private var showPlayerControls: Bool = false
    @State private var isPlaying: Bool = false
    @State private var timeoutTask: DispatchWorkItem?
    
    // Video Seeker properties
    // Seeker/progress
    @GestureState private var isDragging: Bool = false
    @State private var isSeeking: Bool = false
    @State private var progress: CGFloat = 0
    @State private var lastDraggedProgress: CGFloat = 0
    
    // MARK: - Body
    
    var body: some View {
        let videoPlayerSize: CGSize = CGSize(width: size.width,
                                             height: size.height / 3.5)
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .overlay {
                        // Dim background when controls are visible or dragging
                        Rectangle()
                            .fill(.black.opacity(0.4))
                            .opacity(showPlayerControls || isDragging ? 1 : 0)
                            .animation(.easeInOut(duration: 0.35),
                                       value: isDragging)
                        // here we will add play back controls
                            .overlay { PlayBackContols() }
                    }.onTapGesture { handleTap() }
                    .overlay(alignment: .bottom) { VideoSeekerView(size) }
            }
        }
        .frame(width: videoPlayerSize.width,
               height: videoPlayerSize.height)
        .padding(.top, safeArea.top)
        .onAppear() {
            observePlayerProgress()
        }
    }
    
    // MARK: - Helper Functions
    static func setupPlayer() -> AVPlayer? {
        if let bundle = Bundle.main.path(forResource: "Why You Should NEVER Take a Break ⧸ Funny animated short film",
                                         ofType: "mp4") {
            return .init(url: URL(filePath: bundle))
        }
        return nil
    }
    
    func observePlayerProgress() {
        player?.addPeriodicTimeObserver(forInterval: .init(seconds: 1,
                                                           preferredTimescale: 1),
                                        queue: .main) { time in
            if let currentPlayerTime = player?.currentItem {
                let totalDuration = currentPlayerTime.duration.seconds
                guard let currentDuration = player?.currentTime().seconds else {
                    return
                }
                
                let calculatedProgress = currentDuration / totalDuration
                progress = calculatedProgress
            }
        }
    }
    
    /// Handle tap to show/hide controls
    func handleTap() {
        withAnimation(.easeInOut(duration: 0.35)) {
            showPlayerControls.toggle()
        }
        if isPlaying {
            timeoutControls()
        }
    }
    
    /// Auto-hide controls after a delay
    func timeoutControls() {
        if let timeoutTask {
            timeoutTask.cancel()
        }
        timeoutTask = .init(block: {
            withAnimation(.easeInOut(duration: 0.35)) {
                showPlayerControls = false
            }
        })
        
        if let timeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5,
                                          execute: timeoutTask)
        }
    }
    
    /// Seek video by seconds (positive = forward, negative = backward)
    func seek(by seconds: Double) {
        guard let player = player,
              let currentItem = player.currentItem else { return }
        let currentTime = player.currentTime().seconds
        let duration = currentItem.duration.seconds
        var newTime = currentTime + seconds
        newTime = max(min(newTime, duration), 0) // Clamp between 0 and duration
        player.seek(to: CMTime(seconds: newTime,
                               preferredTimescale: 1))
    }
    
    // MARK: - UI Components
    
    /// Playback controls: Reverse, Play/Pause, Forward
    @ViewBuilder
    func PlayBackContols() -> some View  {
        HStack(spacing: 25) {
            // back(reverse)
            Button{
                seek(by: -10) // Go back 10 seconds
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.title3)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.black.opacity(0.35))
                    }
            }
            .disabled(player == nil)
            .opacity(0.6)
            
            // play / pause
            Button{
                if isPlaying {
                    player?.pause()
                    // cancelling timeout task when the video is paused
                    if let timeoutTask {
                        timeoutTask.cancel()
                    }
                    
                } else {
                    player?.play()
                    timeoutControls()
                }
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: !isPlaying ? "play.fill" : "pause.fill")
                    .font(.title2)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.white.opacity(0.35))
                    }
            }
            
            // front(forward)
            Button{
                // player.forward
                seek(by: 10)
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title3)
                    .fontWeight(.ultraLight)
                    .foregroundStyle(.white)
                    .padding(15)
                    .background {
                        Circle()
                            .fill(.black.opacity(0.35))
                    }
            }
            .disabled((player == nil))
            .opacity(0.6)
        }
        .opacity(showPlayerControls && !isDragging ? 1 : 0)
        .animation(.easeInOut(duration: 0.25),
                   value: showPlayerControls && !isDragging)
    }
    
    /// Custom video seeker/progress bar with draggable thumb
    @ViewBuilder
    func VideoSeekerView(_ videoSize: CGSize) -> some View {
        let thumbWidth: CGFloat = 15
        ZStack(alignment: .leading) {
            Rectangle().fill(.gray)
            Rectangle().fill(.red)
                .frame(width: max((videoSize.width - thumbWidth) * progress + thumbWidth / 2, 0))
        }
        .frame(height: 3)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.red)
                .frame(width: thumbWidth, height: thumbWidth)
                .contentShape(Rectangle().inset(by: -10))
                .offset(x: progress * (videoSize.width - thumbWidth))
                .gesture(DragGesture()
                    .updating($isDragging) { _, out, _ in out = true }
                    .onChanged { value in
                        timeoutTask?.cancel()
                        let translationX = value.translation.width
                        let calculated = (translationX / (videoSize.width - thumbWidth)) + lastDraggedProgress
                        progress = max(min(calculated, 1), 0)
                        isSeeking = true
                    }
                    .onEnded { _ in
                        lastDraggedProgress = progress
                        if let item = player?.currentItem {
                            let total = item.duration.seconds
                            player?.seek(to: .init(seconds: total * progress, preferredTimescale: 1))
                            if isPlaying { timeoutControls() }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isSeeking = false }
                    }
                )
        }
    }
    
}

#Preview {
    ContentView()
}
