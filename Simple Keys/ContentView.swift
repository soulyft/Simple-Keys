//
//  ContentView.swift
//  Simple Keys
//
//  Created by Corey Lofthus on 10/1/25.
//

import SwiftUI

struct PianoKey: Identifiable, Equatable {
    let id: String
    let displayName: String
    let frequency: Double
    let positionMultiplier: CGFloat?

    init(displayName: String, frequency: Double, positionMultiplier: CGFloat? = nil) {
        self.id = displayName
        self.displayName = displayName
        self.frequency = frequency
        self.positionMultiplier = positionMultiplier
    }
}

struct ContentView: View {
    private let portraitWhiteKeys: [PianoKey] = [
        PianoKey(displayName: "C", frequency: 261.63),
        PianoKey(displayName: "D", frequency: 293.66),
        PianoKey(displayName: "E", frequency: 329.63)
    ]

    private let portraitBlackKeys: [PianoKey] = [
        PianoKey(displayName: "C♯", frequency: 277.18, positionMultiplier: 0.95),
        PianoKey(displayName: "D♯", frequency: 311.13, positionMultiplier: 1.95)
    ]

    private let landscapeWhiteKeys: [PianoKey] = [
        PianoKey(displayName: "C", frequency: 261.63),
        PianoKey(displayName: "D", frequency: 293.66),
        PianoKey(displayName: "E", frequency: 329.63),
        PianoKey(displayName: "F", frequency: 349.23),
        PianoKey(displayName: "G", frequency: 392.00),
        PianoKey(displayName: "A", frequency: 440.00),
        PianoKey(displayName: "B", frequency: 493.88)
    ]

    private let landscapeBlackKeys: [PianoKey] = [
        PianoKey(displayName: "C♯", frequency: 277.18, positionMultiplier: 0.95),
        PianoKey(displayName: "D♯", frequency: 311.13, positionMultiplier: 1.95),
        PianoKey(displayName: "F♯", frequency: 369.99, positionMultiplier: 3.95),
        PianoKey(displayName: "G♯", frequency: 415.30, positionMultiplier: 4.95),
        PianoKey(displayName: "A♯", frequency: 466.16, positionMultiplier: 5.95)
    ]

    private let backgroundColor = Color(red: 0.91, green: 0.92, blue: 0.94)

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let isLandscape = size.width > size.height
            let whiteKeys = isLandscape ? landscapeWhiteKeys : portraitWhiteKeys
            let blackKeys = isLandscape ? landscapeBlackKeys : portraitBlackKeys
            let horizontalPadding = size.width * (isLandscape ? 0.05 : 0.16)
            let availableWidth = size.width
            let whiteKeyWidth = availableWidth / CGFloat(whiteKeys.count)
            let whiteKeyHeight = size.height
            let blackKeyWidth = whiteKeyWidth * (isLandscape ? 0.75 : 0.64)
            let blackKeyHeight = isLandscape ? whiteKeyHeight * 0.62 : whiteKeyHeight

            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack {

                    Group {
                        if isLandscape {
                            ZStack  {
                                whiteKeyStack(
                                    keys: whiteKeys,
                                    keyWidth: whiteKeyWidth,
                                    keyHeight: whiteKeyHeight,
                                    isLandscape: isLandscape
                                )

                                blackKeyStack(
                                    keys: blackKeys,
                                    whiteKeyWidth: whiteKeyWidth,
                                    blackKeyWidth: blackKeyWidth,
                                    blackKeyHeight: blackKeyHeight,
                                    isLandscape: isLandscape
                                )

                            }
                            .ignoresSafeArea()
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("Piano keyboard")
                        } else {
                            VerticalKeyboardView()
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("Piano keyboard")
                        }
                    }

    
                }
            }
            .onAppear {
                _ = PianoSoundEngine.shared
            }
        }
        .ignoresSafeArea(edges: .all)
    }

    private func whiteKeyStack(keys: [PianoKey], keyWidth: CGFloat, keyHeight: CGFloat, isLandscape: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(keys.enumerated()), id: \.element.id) { index, key in
                Button {
                    PianoSoundEngine.shared.play(frequency: key.frequency)
                } label: {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(alignment: .leading) {
                            if index != 0 {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: isLandscape ? 1 : 3)
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if index != keys.count - 1 {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: isLandscape ? 1 : 3)
                            }
                        }
                }
                .buttonStyle(.plain)
                .frame(width: keyWidth, height: keyHeight)
                .contentShape(Rectangle())
                .accessibilityLabel("\(key.displayName) note")
                
            }
        }
    }

    private func blackKeyStack(
        keys: [PianoKey],
        whiteKeyWidth: CGFloat,
        blackKeyWidth: CGFloat,
        blackKeyHeight: CGFloat,
        isLandscape: Bool
    ) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(keys) { key in
                if let position = key.positionMultiplier {
                    Button {
                        PianoSoundEngine.shared.play(frequency: key.frequency)
                    } label: {
                        RoundedRectangle(cornerRadius: isLandscape ? 6 : 0)
                            .fill(Color.black)
                    }
                    .buttonStyle(.plain)
                    .frame(width: blackKeyWidth, height: blackKeyHeight)
                    .contentShape(RoundedRectangle(cornerRadius: isLandscape ? 6 : 0))
                    .position(
                        x: whiteKeyWidth * position,
                        y: blackKeyHeight / 2
                    )
                    .accessibilityLabel("\(key.displayName) sharp note")
                }
            }
        }
    }
}

struct VerticalKeyboardView: View {
    let offset: CGFloat = 8

    var body: some View {
        VStack(spacing: 0) {
            // rectangles are keys (top row)
            HStack(spacing: 8) {
                Color.clear
                    .frame(width: 64)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 277.18) } // C♯
                    .accessibilityLabel("C sharp")
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 311.13) } // D♯
                    .accessibilityLabel("D sharp")
                Color.clear
                    .frame(width: 64)
            }

            // spaces are keys (bottom row)
            HStack(spacing: 16) {
                // Left space acts as a key (C)
                Color.clear
                    .frame(width: 120 - offset)
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 261.63) }
                    .accessibilityLabel("C note")

                // Black key (F♯)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 369.99) } // F♯
                    .accessibilityLabel("F sharp")

                // Middle space acts as a key (D)
                Color.clear
                    .frame(width: 88 + offset)
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 293.66) }
                    .accessibilityLabel("D note")

                // Black key (A♯)
                Rectangle()
                    .foregroundStyle(.black.opacity(0.88))
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 466.16) } // A♯
                    .accessibilityLabel("A sharp")

                // Right space acts as a key (E)
                Color.clear
                    .frame(width: 120 - offset)
                    .contentShape(Rectangle())
                    .onTapGesture { PianoSoundEngine.shared.play(frequency: 329.63) }
                    .accessibilityLabel("E note")
            }
            .frame(height: 256)
        }
        .background {
            Color.black.opacity(0.08)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
