import AVFoundation

final class PianoSoundEngine {
    static let shared = PianoSoundEngine()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format: AVAudioFormat
    private let sampleRate: Double

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        sampleRate = format.sampleRate

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

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
        player.scheduleBuffer(buffer, at: nil, options: [.interrupts], completionHandler: nil)

        if !player.isPlaying {
            player.play()
        }
    }

    private func makeBuffer(frequency: Double) -> AVAudioPCMBuffer {
        let duration: Double = 0.7
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Unable to allocate audio buffer")
        }

        buffer.frameLength = frameCount

        let attackSamples = Int(sampleRate * 0.02)
        let releaseSamples = Int(sampleRate * 0.15)
        let releaseStart = max(0, Int(frameCount) - releaseSamples)

        let amplitude: Float = 0.25
        let channel = buffer.floatChannelData![0]
        for sampleIndex in 0..<Int(frameCount) {
            let phase = 2.0 * Double.pi * Double(sampleIndex) * frequency / sampleRate
            var envelope: Float = 1.0

            if sampleIndex < attackSamples {
                envelope = Float(sampleIndex) / Float(attackSamples)
            } else if sampleIndex > releaseStart {
                envelope = Float(Int(frameCount) - sampleIndex) / Float(releaseSamples)
            }

            channel[sampleIndex] = Float(sin(phase)) * amplitude * envelope
        }

        return buffer
    }
}
