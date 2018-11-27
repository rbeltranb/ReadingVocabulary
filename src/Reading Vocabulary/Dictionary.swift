//
//  Dictionary.swift
//  Reading Vocabulary
//
//  Created by Raul Beltrán Beltrán on 17/03/2017.
//  Copyright © 2017 Raul Beltrán Beltrán. All rights reserved.
//

import Foundation

class Dictionary {
    
    //MARK: Types
    
    struct PropertyKey {
        static let languages: [String: String] = ["English": "en", "Deutsch": "de"]
        static let nameDictionary = "dictionary_level_"
        static let extDictionary = "csv"
    }
    
    //MARK: Properties
    
    var wordList = [String]()
    private var previousWordList = -1
    
    //MARK: Initialization
    
    init?(language: String, index: Int) {
        
        // The dictionary name components must not be empty
        guard (!language.isEmpty || index>0) else {
            return nil
        }
        
        let dictionaryName = PropertyKey.nameDictionary+PropertyKey.languages[language]!+String(index)
        let DocsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        ArchiveURL = DocsDirectory.appendingPathComponent(dictionaryName).appendingPathExtension(PropertyKey.extDictionary)
        loadDictionary()
    }
    
    func getUnknown(rawText: String) -> Set<String> {
        let textPrepared = rawText.lowercased()
        var wordsUnknown = Set<String>()
            
        let range = textPrepared.startIndex ..< textPrepared.endIndex
        textPrepared.enumerateSubstrings(in: range, options: .byWords) { (word,_,_,_) -> () in
                
            if !(self.wordList.contains(word!)) {
                wordsUnknown.insert(word!)
            }
        }
        
        return wordsUnknown
    }
    
    func getUnknown(wordList: Set<String>) -> Set<String> {
        return wordList.subtracting(self.wordList)
    }
    
    //MARK: Archiving Paths

    let fileManager: FileManager = FileManager.default
    var ArchiveURL : URL
    
    func saveDictionary() {
        let actualWordList = wordList.joined().hash
        
        if actualWordList != previousWordList {
            let databuffer = wordList.joined(separator: ",").data(using: String.Encoding.utf8)
            fileManager.createFile(atPath: ArchiveURL.path, contents: databuffer, attributes: nil)
            
            previousWordList = actualWordList
        }
    }
    
    func updateDictionary(wordList: Set<String>) {
        
        if (wordList.count > 0) {
            let file: FileHandle? = FileHandle(forUpdatingAtPath: ArchiveURL.path)
            
            if (file != nil && (file?.seekToEndOfFile())!>0) {
                let databuffer = (","+wordList.joined(separator: ",")).data(using: String.Encoding.utf8)
                file?.seekToEndOfFile()
                file?.write(databuffer!)
                file?.closeFile()
                self.wordList.append(contentsOf: wordList)
            } else {
                self.wordList = Array(wordList)
                saveDictionary()
            }
        }
    }
    
    private func loadDictionary() {
        
        if fileManager.fileExists(atPath: ArchiveURL.path) {
            let dataString = NSString(data: fileManager.contents(atPath: ArchiveURL.path)!,
                                      encoding: String.Encoding.utf8.rawValue)
            wordList = (dataString?.components(separatedBy: ","))!
            
            // Correct the empty data lecture.
            if wordList.count == 1 && wordList[0] == "" {
                wordList.remove(at: 0)
            }
        }
        
        previousWordList = wordList.joined().hash
    }
    
}
