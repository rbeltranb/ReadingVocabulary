//
//  DictionaryUIPickerView.swift
//  Reading Vocabulary
//
//  Created by Raul Beltrán Beltrán on 18/03/2017.
//  Copyright © 2017 Raul Beltrán Beltrán. All rights reserved.
//

import UIKit

class DictionaryUIPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Properties
    
    var pickerData: [[String]] = [[String]]()
    let numDictionaries = 5 // Per language...
    var selectedDictionary = "de5" // Anyone, just to init.

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        pickerData.append([String](Dictionary.PropertyKey.languages.keys))
        for extra in Dictionary.PropertyKey.languages.count...numDictionaries {
            pickerData[0].append(pickerData[0][extra%Dictionary.PropertyKey.languages.count])
        }
        pickerData.append([String]())
        
        for index in 0...numDictionaries {
            pickerData[1].append(String(numDictionaries-index))
        }
        
        // Connect data from dictionary selector.
        self.delegate = self
        self.dataSource = self
    }
    
    // The number of columns of data
    func numberOfComponents(in: UIPickerView) -> Int {
        return 2 // Language an dictionary index.
    }
    
    // The number of rows of data
    func pickerView(_: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        return numDictionaries
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_: UIPickerView, titleForRow: Int, forComponent: Int) -> String? {
        return pickerData[forComponent][titleForRow]
    }
    
    //MARK: Actions
    
    // Catpure the picker view selection
    func pickerView(_: UIPickerView, didSelectRow: Int, inComponent: Int) {
        
        if inComponent == 0 {
            let range  = selectedDictionary.startIndex..<selectedDictionary.index(selectedDictionary.startIndex, offsetBy: 2)
            selectedDictionary = selectedDictionary.replacingCharacters(in: range, with: Dictionary.PropertyKey.languages[pickerData[0][didSelectRow]]!)
        } else { // 1
            let range  = selectedDictionary.index(selectedDictionary.startIndex, offsetBy: 2)..<selectedDictionary.endIndex
            selectedDictionary = selectedDictionary.replacingCharacters(in: range, with: pickerData[1][didSelectRow])
        }
    }
    
}
