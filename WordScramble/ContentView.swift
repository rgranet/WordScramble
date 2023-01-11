//
//  ContentView.swift
//  WordScramble
//
//  Created by Ruben Granet on 30/11/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    // properties to control alerts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    
    var body: some View {
        
        NavigationView {
            List {
                Text("Score : \(score)")
                    .foregroundColor(.blue)
                    .font(.headline)
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    List(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .toolbar{
                Button("New word", action: startGame)
            }
            .navigationTitle(rootWord)
            .onSubmit{addNewWord()}
            .onAppear{startGame()}
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate word with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else { return }
        
        if answer.count < 3 {
            wordError(title: "Really, 3 letters?", message: "You can do better")
        } else {
            
            guard isOriginal(word: answer) else {
                wordError(title: "Word already used", message: "Be more original")
                return
            }
            
            guard isPossible(word: answer) else {
                wordError(title: "Word not possible", message: "You can't spell that word form '\(rootWord)'")
                return
            }
            
            guard isReal(word: answer) else {
                wordError(title: "Word not recognized", message: "You can't make them up, you know")
                return
            }
            
            withAnimation {
                usedWords.insert(answer, at: 0)
                score += 1
            }
            
        }
        newWord = ""
    }
    
    
    func startGame() {
        score = 0
        
        //1. find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            
            //2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
            
                //3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                //4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit :-)
                
                return
            }
        }
        
        //If we are *HERE* then there was a problem - trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
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
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
