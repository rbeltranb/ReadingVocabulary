//
//  CardsTableViewController.swift
//  Reading Vocabulary
//
//  Created by Raul Beltrán Beltrán on 16/03/2017.
//  Copyright © 2017 Raul Beltrán Beltrán. All rights reserved.
//

import UIKit

class CardsTableViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var numDicWords: UILabel!
    let searchController = UISearchController(searchResultsController: nil)

    var leftDic = "de4", middleDic = "de5", rightDic = "de5" // Anyone in the middle, just to init.
    var dictionaries: [String: Dictionary] = [String: Dictionary]()
    var filteredWords = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Preserve selection between presentations.
        self.clearsSelectionOnViewWillAppear = false
        
        filteredWords = dictionaries[middleDic]!.wordList
        numDicWords.text = "\(filteredWords.count) words in "+middleDic

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: "CardTableViewCell")
        registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dictionaries[middleDic]!.saveDictionary()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as? CardTableViewCell
        
        // Fetches the appropriate card for the data source layout.
        cell?.textLabel?.text = filteredWords[indexPath.row]
        cell?.leftLabel.text = leftDic+"\u{2190}"
        cell?.rightLabel.text = "\u{2192}"+rightDic
        cell?.slidingDelegate = self

        return cell!
    }
    
    //MARK: Actions

    func hasPerformedSwipe(touch: CGPoint, direction: Int) {
        
        // Access the cell at this index path
        if let indexPath = tableView.indexPathForRow(at: touch) {
            
            if direction < 0 { // Left movement.
                if !isLeftTop() {
                    self.dictionaries[self.leftDic]!.wordList.append(self.dictionaries[self.middleDic]!.wordList.remove(at: indexPath.row))
                    filteredWords.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else { // Right movement.
                if !isRightTop() {
                    self.dictionaries[self.rightDic]!.wordList.append(self.dictionaries[self.middleDic]!.wordList.remove(at: indexPath.row))
                    filteredWords.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }

            numDicWords.text = "\(filteredWords.count) words in "+middleDic
        }
    }
    
    func hasPerformedTap(touch: CGPoint) {
        
        if let indexPath = tableView.indexPathForRow(at: touch) {
            let wordReference: UIReferenceLibraryViewController = UIReferenceLibraryViewController(term: filteredWords[indexPath.row])
            self.present(wordReference, animated: true, completion: nil)
        }
    }
    
    func isLeftTop() -> Bool {
        return self.leftDic == self.middleDic
    }
    
    func isRightTop() -> Bool {
        return self.rightDic == self.middleDic
    }
    
}

extension CardsTableViewController: UIViewControllerPreviewingDelegate, SlidingCellDelegate {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        let alertController = UIAlertController(title: "Delete '\(filteredWords[indexPath.row])'", message: "The word will be eliminated from \(middleDic).", preferredStyle: .alert)
        
        // The confirm action delete the word from the current dictionary.
        let confirmAction = UIAlertAction(title: "Delete", style: .default) { action in
            self.dictionaries[self.middleDic]!.wordList.remove(at: indexPath.row)
            self.filteredWords.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.numDicWords.text = "\(self.filteredWords.count) words in "+self.middleDic
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alertController
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

extension CardsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
            // If we haven't typed anything into the search bar then do not filter the results.
            if searchController.searchBar.text! == "" {
                filteredWords = (dictionaries[middleDic]?.wordList)!
            } else {
                // Filter the results.
                filteredWords = dictionaries[middleDic]!.wordList.filter { $0.lowercased().contains(searchController.searchBar.text!.lowercased()) }
            }
        
            numDicWords.text = "\(filteredWords.count) words in "+middleDic
            self.tableView.reloadData()
        }
}
