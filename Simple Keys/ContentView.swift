//
//  ContentView.swift
//  Simple Keys
//
//  Created by Corey Lofthus on 10/1/25.
//

import SwiftUI

struct PianoKey: Identifiable {
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
    private let whiteKeys: [PianoKey] = [
        PianoKey(displayName: "C", frequency: 261.63),
        PianoKey(displayName: "D", frequency: 293.66),
        PianoKey(displayName: "E", frequency: 329.63),
        PianoKey(displayName: "F", frequency: 349.23),
        PianoKey(displayName: "G", frequency: 392.00),
        PianoKey(displayName: "A", frequency: 440.00),
        PianoKey(displayName: "B", frequency: 493.88)
    ]

    private let blackKeys: [PianoKey] = [
        PianoKey(displayName: "C♯", frequency: 277.18, positionMultiplier: 0.95),
        PianoKey(displayName: "D♯", frequency: 311.13, positionMultiplier: 1.95),
        PianoKey(displayName: "F♯", frequency: 369.99, positionMultiplier: 3.95),
        PianoKey(displayName: "G♯", frequency: 415.30, positionMultiplier: 4.95),
        PianoKey(displayName: "A♯", frequency: 466.16, positionMultiplier: 5.95)
    ]

    private let backgroundGradient = LinearGradient(colors: [
        Color(red: 0.96, green: 0.97, blue: 0.99),
        Color(red: 0.89, green: 0.92, blue: 0.97)
    ], startPoint: .top, endPoint: .bottom)

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let isLandscape = size.width > size.height
            let horizontalPadding = size.width * (isLandscape ? 0.05 : 0.08)
            let availableWidth = max(size.width - (horizontalPadding * 2), size.width * 0.7)
            let whiteKeyWidth = availableWidth / CGFloat(whiteKeys.count)
            let preferredHeight = whiteKeyWidth * (isLandscape ? 4.0 : 5.0)
            let whiteKeyHeight = min(size.height * 0.9, preferredHeight)
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight = whiteKeyHeight * 0.6

            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                VStack {
                    Spacer()

                    ZStack(alignment: .topLeading) {
                        whiteKeyStack(width: whiteKeyWidth, height: whiteKeyHeight)

                        blackKeyStack(
                            whiteKeyWidth: whiteKeyWidth,
                            blackKeyWidth: blackKeyWidth,
                            blackKeyHeight: blackKeyHeight
                        )
                        .padding(.top, whiteKeyHeight * 0.02)
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

    private func whiteKeyStack(width: CGFloat, height: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(whiteKeys) { key in
                Button {
                    PianoSoundEngine.shared.play(frequency: key.frequency)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                        .overlay(alignment: .bottom) {
                            Text(key.displayName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.black.opacity(0.7))
                                .padding(.bottom, 10)
                        }
                }
                .buttonStyle(.plain)
                .frame(width: width, height: height, alignment: .bottom)
                .accessibilityLabel("\(key.displayName) note")
            }
        }
    }

    private func blackKeyStack(whiteKeyWidth: CGFloat, blackKeyWidth: CGFloat, blackKeyHeight: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(blackKeys) { key in
                if let position = key.positionMultiplier {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .overlay(alignment: .bottom) {
                            Text(key.displayName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.85))
                                .padding(.bottom, 8)
                        }
                        .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 6)
                        .frame(width: blackKeyWidth, height: blackKeyHeight, alignment: .bottom)
                        .position(
                            x: whiteKeyWidth * position,
                            y: blackKeyHeight / 2
                        )
                }
            }

            ForEach(blackKeys) { key in
                if let position = key.positionMultiplier {
                    Button {
                        PianoSoundEngine.shared.play(frequency: key.frequency)
                    } label: {
                        Color.clear
                    }
                    .frame(width: blackKeyWidth, height: blackKeyHeight)
                    .contentShape(RoundedRectangle(cornerRadius: 6))
                    .position(
                        x: whiteKeyWidth * position,
                        y: blackKeyHeight / 2
                    )
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(key.displayName) sharp note")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
