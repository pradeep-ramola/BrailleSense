import SwiftUI
import Speech
import AVFoundation

// MARK: - Braille Mapping
let brailleAlphabet: [Character: Set<Int>] = [
    "a": [1], "b": [1,2], "c": [1,4], "d": [1,4,5], "e": [1,5],
    "f": [1,2,4], "g": [1,2,4,5], "h": [1,2,5], "i": [2,4], "j": [2,4,5],
    "k": [1,3], "l": [1,2,3], "m": [1,3,4], "n": [1,3,4,5], "o": [1,3,5],
    "p": [1,2,3,4], "q": [1,2,3,4,5], "r": [1,2,3,5], "s": [2,3,4],
    "t": [2,3,4,5], "u": [1,3,6], "v": [1,2,3,6], "w": [2,4,5,6],
    "x": [1,3,4,6], "y": [1,3,4,5,6], "z": [1,3,5,6],
    " ": []
]

struct ContentView: View {

    // Sentence recognized from voice
    @State private var sentence: String = ""
    @State private var currentIndex: Int = 0
    @State private var brailleDots: Set<Int> = []
    @State private var visitedDots: Set<Int> = []

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .heavy) // stronger haptics

    // Speech Recognition
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var audioEngine = AVAudioEngine()
    @State private var request: SFSpeechAudioBufferRecognitionRequest?
    @State private var isRecording = false

    let rows = 3
    let cols = 2
    let squareSize: CGFloat = 100

    var currentCharacter: Character {
        guard currentIndex < sentence.count else { return " " }
        return sentence[sentence.index(sentence.startIndex, offsetBy: currentIndex)]
    }

    var body: some View {
        VStack(spacing: 30) {

            // Display recognized sentence
            Text("Input: \(sentence)")
                .font(.headline)
                .padding()

            // Display current char
            Text("Letter: \(String(currentCharacter))")
                .font(.largeTitle)

            // Voice input button
            Button(action: toggleSpeech) {
                HStack {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                    Text(isRecording ? "Listening..." : "Speak")
                }
                .font(.title2)
                .padding()
                .background(isRecording ? Color.red.opacity(0.7) : Color.blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Braille Grid (centered)
            VStack {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<cols, id: \.self) { col in
                            let dotNumber = row * cols + col + 1
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: squareSize, height: squareSize)
                                .overlay(
                                    brailleDots.contains(dotNumber) ?
                                    Rectangle().fill(Color.black.opacity(0.8)) : nil
                                )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dot = getDotFromLocation(value.location)
                        handleDotTouch(dotNumber: dot)
                    }
                    .onEnded { _ in visitedDots.removeAll() }
            )

            // Navigation
            HStack {
                Button("⬅️ Previous") { previousCharacter() }
                Spacer()
                Button("Next ➡️") { nextCharacter() }
            }
            .padding(.horizontal)
        }
        .onAppear { updateBrailleDots() }
    }

    func updateBrailleDots() {
        brailleDots = brailleAlphabet[Character(currentCharacter.lowercased())] ?? []
        visitedDots.removeAll()
    }

    func previousCharacter() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateBrailleDots()
        }
    }

    func nextCharacter() {
        if currentIndex < max(sentence.count - 1, 0) {
            currentIndex += 1
            updateBrailleDots()
        }
    }

    func getDotFromLocation(_ location: CGPoint) -> Int {
        let col = min(max(Int(location.x / (squareSize + 20)), 0), cols-1)
        let row = min(max(Int(location.y / (squareSize + 20)), 0), rows-1)
        return row * cols + col + 1
    }

    func handleDotTouch(dotNumber: Int) {
        if brailleDots.contains(dotNumber) && !visitedDots.contains(dotNumber) {
            visitedDots.insert(dotNumber)
            hapticGenerator.prepare()
            hapticGenerator.impactOccurred()
        }
    }

    // MARK: Speech Recognition
    func toggleSpeech() {
        isRecording ? stopSpeech() : startSpeech()
    }

    func startSpeech() {
        sentence = ""
        currentIndex = 0

        request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        guard let request = request else { return }

        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isRecording = true

        speechRecognizer?.recognitionTask(with: request) { result, _ in
            if let result = result {
                sentence = result.bestTranscription.formattedString.lowercased()
                updateBrailleDots()
            }
        }
    }

    func stopSpeech() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request = nil
        isRecording = false
    }
}

