import AVFoundation

final class PianoSoundEngine {
    static let shared = PianoSoundEngine()

    private let engine = AVAudioEngine()
    private var players: [AVAudioPlayerNode] = []
    private var playerAvailability: [Bool] = []
    private var nextPlayerIndex: Int = 0
    private let playerQueue = DispatchQueue(label: "PianoSoundEngine.queue")
    private let format: AVAudioFormat
    private let sampleRate: Double

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        sampleRate = format.sampleRate

        for _ in 0..<5 {
            let player = AVAudioPlayerNode()
            players.append(player)
            playerAvailability.append(false)
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
        }

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }

        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
        }
    }

    func play(frequency: Double) {
        let buffer = makeBuffer(frequency: frequency)

        playerQueue.async {
            let playerIndex = self.nextAvailablePlayerIndex()
            let player = self.players[playerIndex]

            if self.playerAvailability[playerIndex] {
                player.stop()
            }

            self.playerAvailability[playerIndex] = true

            player.scheduleBuffer(buffer, at: nil, options: []) { [weak self] in
                self?.playerQueue.async {
                    self?.playerAvailability[playerIndex] = false
                }
            }

            if !player.isPlaying {
                player.play()
            }
        }
    }

    private func nextAvailablePlayerIndex() -> Int {
        if let availableIndex = playerAvailability.firstIndex(of: false) {
            return availableIndex
        }

        let index = nextPlayerIndex
        nextPlayerIndex = (nextPlayerIndex + 1) % players.count
        return index
    }

    private func makeBuffer(frequency: Double) -> AVAudioPCMBuffer {
        let duration: Double = 1.2
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Unable to allocate audio buffer")
        }

        buffer.frameLength = frameCount

        let attackSamples = max(1, Int(sampleRate * 0.008))
        let sustainStart = attackSamples
        let totalSamples = Int(frameCount)
        let amplitude: Float = 0.32
        let channel = buffer.floatChannelData![0]

        for sampleIndex in 0..<totalSamples {
            let phase = 2.0 * Double.pi * Double(sampleIndex) * frequency / sampleRate
            var envelope: Float = 1.0

            if sampleIndex < attackSamples {
                let progress = Float(sampleIndex) / Float(max(attackSamples, 1))
                envelope = pow(progress, 0.3)
            } else {
                let decayProgress = Float(sampleIndex - sustainStart) / Float(max(totalSamples - sustainStart, 1))
                envelope = exp(-decayProgress * 2.4)
            }

            channel[sampleIndex] = Float(sin(phase)) * amplitude * envelope
        }

        return buffer
    }
}
