import SwiftUI
import Speech
import AVFoundation
import PDFKit
import UniformTypeIdentifiers

// MARK: - Braille Mappings
let brailleAlphabet: [Character: Set<Int>] = [
    "a": [1], "b": [1,2], "c": [1,4], "d": [1,4,5], "e": [1,5],
    "f": [1,2,4], "g": [1,2,4,5], "h": [1,2,5], "i": [2,4], "j": [2,4,5],
    "k": [1,3], "l": [1,2,3], "m": [1,3,4], "n": [1,3,4,5], "o": [1,3,5],
    "p": [1,2,3,4], "q": [1,2,3,4,5], "r": [1,2,3,5], "s": [2,3,4],
    "t": [2,3,4,5], "u": [1,3,6], "v": [1,2,3,6], "w": [2,4,5,6],
    "x": [1,3,4,6], "y": [1,3,4,5,6], "z": [1,3,5,6],
    " ": []
]

// MARK: - Grade 2 Whole Word Contractions
let grade2WholeWordContractions: [String: Set<Int>] = [
    "the": [2,3,4,6],
    "and": [1,2,3,4,6],
    "for": [1,2,3,4,5],
    "of":  [1,2,3,5],
    "with": [2,3,4,5,6],
    "but": [1,2,3,4,6],
    "can": [1,2,3,4],
    "do": [1,4,5],
    "every": [1,2,3,4,6],
    "from": [1,2,3,4],
    "go": [1,2,4,5],
    "have": [1,2,6],
    "just": [2,3,4,5,6],
    "know": [1,3,4,5],
    "like": [1,2,3],
    "more": [1,3,4,5],
    "not": [1,3,4,5],
    "people": [1,2,3,4],
    "quite": [1,2,3,4,5],
    "rather": [1,2,3,5],
    "so": [2,3,4],
    "that": [2,3,4,5],
    "us": [1,3,6],
    "very": [1,2,3,6],
    "will": [2,4,5,6],
    "you": [1,3,4,5,6]
]

// MARK: - ContentView
struct ContentView: View {
    @State private var tokens: [String] = []
    @State private var currentIndex = 0
    @State private var brailleDots: Set<Int> = []
    @State private var visitedDots: Set<Int> = []
    @State private var sentence: String = ""
    @State private var statusMessage: String = ""

    // Speech & File
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var audioEngine = AVAudioEngine()
    @State private var request: SFSpeechAudioBufferRecognitionRequest?
    @State private var isRecording = false
    @State private var showFilePicker = false

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let rows = 3
    let cols = 2
    let squareSize: CGFloat = 100

    var currentToken: String {
        guard currentIndex < tokens.count else { return "" }
        return tokens[currentIndex]
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 30) {
            ScrollView {
                Text("Input: \(sentence)")
                    .font(.headline)
                    .padding()
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .foregroundColor(.green)
            }

            Text("Current: \(currentToken.replacingOccurrences(of: "~", with: ""))")
                .font(.largeTitle)

            Button(action: toggleSpeech) {
                HStack {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                    Text(isRecording ? "Listening..." : "Speak")
                }
                .font(.title2)
                .padding()
                .background(isRecording ? .red.opacity(0.7) : .blue.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Button(action: { showFilePicker.toggle() }) {
                Text("Upload PDF / TXT")
                    .font(.title2)
                    .padding()
                    .background(.green.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .fileImporter(isPresented: $showFilePicker,
                          allowedContentTypes: [.pdf, .plainText],
                          allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first { parseFile(url: url) }
                case .failure(let error):
                    statusMessage = "Error: \(error.localizedDescription)"
                }
            }

            // Braille grid
            VStack {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 20) {
                        ForEach(0..<cols, id: \.self) { col in
                            let dotNumber = row * cols + col + 1
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: squareSize, height: squareSize)
                                .overlay(
                                    brailleDots.contains(dotNumber)
                                    ? Rectangle().fill(Color.black.opacity(0.8))
                                    : nil
                                )
                        }
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if let dot = getDotFromLocation(value.location) {
                            handleDotTouch(dotNumber: dot)
                        }
                    }
                    .onEnded { _ in visitedDots.removeAll() }
            )

            HStack {
                Button("⬅️ Prev") { previous() }
                Spacer()
                Button("Next ➡️") { next() }
            }
            .padding()
        }
        .onAppear { updateBrailleDots() }
    }

    // MARK: - Braille Logic
    func updateBrailleDots() {
        let token = currentToken
        if token.starts(with: "~") {
            let word = token.replacingOccurrences(of: "~", with: "")
            brailleDots = grade2WholeWordContractions[word] ?? []
        } else if let ch = token.first {
            brailleDots = brailleAlphabet[ch] ?? []
        } else {
            brailleDots = []
        }
        visitedDots.removeAll()
    }

    func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateBrailleDots()
        }
    }

    func next() {
        if currentIndex < tokens.count - 1 {
            currentIndex += 1
            updateBrailleDots()
        }
    }

    func handleDotTouch(dotNumber: Int) {
        // FIXED: Only trigger haptic if the dot is part of the current pattern AND hasn't been visited yet
        if brailleDots.contains(dotNumber) && !visitedDots.contains(dotNumber) {
            visitedDots.insert(dotNumber)
            hapticGenerator.prepare()
            hapticGenerator.impactOccurred()
        }
        // If dot is not in brailleDots, do nothing (no haptic feedback)
    }

    func getDotFromLocation(_ location: CGPoint) -> Int? {
        // FIXED: Return optional Int and validate the dot is within valid range (1-6)
        let col = Int(location.x / (squareSize + 20))
        let row = Int(location.y / (squareSize + 20))
        let dotNumber = row * cols + col + 1
        
        // Only return valid dot numbers (1-6)
        if dotNumber >= 1 && dotNumber <= 6 && row >= 0 && row < rows && col >= 0 && col < cols {
            return dotNumber
        }
        return nil
    }

    // MARK: - Speech Recognition
    func toggleSpeech() { isRecording ? stopSpeech() : startSpeech() }

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
                processInputText(result.bestTranscription.formattedString)
            }
        }
    }

    func stopSpeech() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request = nil
        isRecording = false
    }

    // MARK: - Input Processing with Grade 2 Contractions
    func processInputText(_ text: String) {
        DispatchQueue.main.async {
            sentence = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

            // Tokenize using Grade 2
            var tempTokens: [String] = []
            let words = sentence.split(separator: " ").map(String.init)
            for word in words {
                if grade2WholeWordContractions[word] != nil {
                    tempTokens.append("~" + word) // mark as contraction
                } else {
                    for ch in word { tempTokens.append(String(ch)) }
                }
                tempTokens.append(" ") // space between words
            }
            tokens = tempTokens
            currentIndex = 0
            updateBrailleDots()
            statusMessage = "Processed the text."
        }
    }

    // MARK: - File Parsing
    func parseFile(url: URL) {
        if url.pathExtension.lowercased() == "pdf" { parsePDF(url: url) }
        else if url.pathExtension.lowercased() == "txt" { parseTXT(url: url) }
    }

    func parsePDF(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let pdf = PDFDocument(url: url) else { return }
            var extractedText = ""
            for i in 0..<pdf.pageCount {
                if let txt = pdf.page(at: i)?.string { extractedText += txt + " " }
            }
            DispatchQueue.main.async { processInputText(extractedText) }
        }
    }

    func parseTXT(url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let text = try? String(contentsOf: url, encoding: .utf8) {
                DispatchQueue.main.async { processInputText(text) }
            }
        }
    }
}
