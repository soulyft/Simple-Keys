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
            let availableWidth = size.width - (horizontalPadding * 2)
            let whiteKeyWidth = availableWidth / CGFloat(whiteKeys.count)
            let whiteKeyHeight = min(size.height * (isLandscape ? 0.7 : 0.78), whiteKeyWidth * (isLandscape ? 3.2 : 4.6))
            let blackKeyWidth = whiteKeyWidth * (isLandscape ? 0.58 : 0.64)
            let blackKeyHeight = isLandscape ? whiteKeyHeight * 0.62 : whiteKeyHeight

            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ZStack(alignment: .topLeading) {
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
                        .padding(.top, isLandscape ? whiteKeyHeight * 0.02 : 0)
                    }
                    .frame(width: availableWidth, height: whiteKeyHeight, alignment: .topLeading)
                    .padding(.horizontal, horizontalPadding)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Piano keyboard")

                    Spacer()
                }
            }
            .onAppear {
                _ = PianoSoundEngine.shared
            }
        }
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

#Preview {
    ContentView()
}
