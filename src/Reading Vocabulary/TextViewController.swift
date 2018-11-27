//
//  ViewController.swift
//  Reading Vocabulary
//
//  Created by Raul Beltrán Beltrán on 14/03/2017.
//  Copyright © 2017 Raul Beltrán Beltrán. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var dictionarySelector: DictionaryUIPickerView!
    @IBOutlet weak var textContainer: UITextView!
    
    private var previousTextBox = 0
    var dictionaries: [String: Dictionary] = [String: Dictionary]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        for index in 0...dictionarySelector.numDictionaries {
            for lang in Dictionary.PropertyKey.languages.keys {
                dictionaries[Dictionary.PropertyKey.languages[lang]!+String(index)] = Dictionary(language: lang, index: index)!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions

    @IBAction func buttonClearText(_ sender: UIButton) {
        textContainer.text = ""
    }
    
    @IBAction func buttonProcessAction(_ sender: UIButton) {
        let actualTextBox = textContainer.text.hashValue
        var unknownWords: Set<String> = []
        
        if (actualTextBox != previousTextBox) {
            do {
                let regex = try NSRegularExpression(pattern: "([¿?!@#$%^&*(){}\\[\\]_+\\-=„\"`´~0123456789.,\\/\\\\|;<>:])")
                let textFiltered = regex.stringByReplacingMatches(in: textContainer.text, options: .reportProgress, range: NSRange(textContainer.text.startIndex..., in: textContainer.text), withTemplate: "")
                
                unknownWords = (dictionaries[dictionarySelector.selectedDictionary]?.getUnknown(rawText: textFiltered))!
                
                for index in dictionaries.keys { //@TODO Work only over the language selected.
                    if index != dictionarySelector.selectedDictionary {
                        unknownWords = (dictionaries[index]?.getUnknown(wordList: unknownWords))!
                    }
                }
                
                dictionaries[dictionarySelector.selectedDictionary]?.updateDictionary(wordList: unknownWords)
                previousTextBox = actualTextBox
            } catch let error {
                print("Invalid regex: \(error.localizedDescription)")
            }
        }
        
        let alert = UIAlertController(title: "Unknown Words", message: "\(unknownWords.count) words added to \(dictionarySelector.selectedDictionary)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.default))
        self.present(alert, animated: true, completion:nil)
    }

    // MARK: - Navigation
    
    // Preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "SegueToTable") {
            let svc = segue.destination as! CardsTableViewController;
            
            svc.dictionaries = dictionaries
            svc.middleDic = dictionarySelector.selectedDictionary
            
            let index0 = svc.middleDic.index(svc.middleDic.startIndex, offsetBy: 2)
            let dicNum = Int(svc.middleDic[index0...])
            let range  = index0..<svc.middleDic.endIndex
            
            if dicNum! < dictionarySelector.numDictionaries {
                svc.rightDic = svc.middleDic.replacingCharacters(in: range, with: String(dicNum!+1))
            } else {svc.rightDic = svc.middleDic}
            
            if dicNum! > 1 { // Minimum dictionary number.
                svc.leftDic = svc.middleDic.replacingCharacters(in: range, with: String(dicNum!-1))
            } else {svc.leftDic = svc.middleDic}
        }
    }

}

