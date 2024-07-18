//
//  ContentView.swift
//  WordScramble
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 18/07/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        
        NavigationStack {
            List {
                
                Section {
                    VStack {
                        Text("Score")
                            .font(.headline)
                        
                        Text(score.formatted())
                            .font(.largeTitle)
                    }
                }
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .onSubmit(addNewWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id:\.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button(action: { startGame() }, label: {
                    Text("New word")
                })
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible",
                      message: "You can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isNotToShort(word: answer) else {
            wordError(title: "Too short", message: "Stop being lazy and write a nice word")
            return
        }
        
        guard isNotRootWord(word: answer) else {
            wordError(title: "Word equal to root", message: "Come on. Are you trying to cheat me?")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized",
                      message: "You can't just make them up, you know")
            return
        }
        
        let points = answer.count
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += points
        }
        newWord = ""
    }
    
    func startGame() {
        score = 0
        guard let file = Bundle.main.url(forResource: "start", withExtension: "txt"),
              let fileContent = try? String(contentsOf: file) else { return }
        
        let allWords = fileContent.components(separatedBy: "\n")
        
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isNotToShort(word: String) -> Bool {
        word.count > 2
    }
    
    func isNotRootWord(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
