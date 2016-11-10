//
//  StatsTableViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 21/10/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import UIKit

class StatsTableViewController: UITableViewController, UIActionSheetDelegate {
    
    let reusableCellIdentifier = "cell"
    
    var difficulty: GameDifficulty?
    var difficultyControl: UISegmentedControl!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("STATISTICS", comment: "")
        
        // Creating segmented toolbar
        let items = [NSLocalizedString("ALL", comment: "")] + GameDifficulty.allShortDescValues
        difficultyControl = UISegmentedControl(items: items)
        difficultyControl.apportionsSegmentWidthsByContent = true
        difficultyControl.selectedSegmentIndex = 0
        difficultyControl.addTarget(self, action: #selector(StatsTableViewController.segmentedControlChanged(_:)), for: .valueChanged);
        
        let frame = difficultyControl.frame
        let newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: 300, height: frame.height)
        difficultyControl.frame = newFrame

        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let segmItem = UIBarButtonItem(customView: difficultyControl)
        
        self.toolbarItems = [space, segmItem, space]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.isToolbarHidden = false
    }
    
    func segmentedControlChanged(_ sender: UISegmentedControl) {
        var animation = UITableViewRowAnimation.automatic
        
        if sender.selectedSegmentIndex == 0 {
            self.difficulty = nil
            animation = .right
        } else {
            if let diff = self.difficulty {
                animation = (diff.toInt < sender.selectedSegmentIndex) ? .left : .right
            } else {
                animation = .left
            }
            self.difficulty = GameDifficulty.fromInt(sender.selectedSegmentIndex)
        }
        tableView.reloadSections(IndexSet(integer: 0), with: animation)
    }
    
    // MARK: UIActionSheetDelegate
    
    func confirmReset(_ sender: UIAlertAction) {
        GameCounter.sharedInstance.resetAllStats()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    // MARK: TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionConfirm = UIAlertAction(title: NSLocalizedString("RESET_ALL_STATISTICS", comment: ""), style: .destructive, handler: confirmReset)
            let actionCancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
            
            alertController.addAction(actionConfirm)
            alertController.addAction(actionCancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard section == 0 else { return nil }
        
        if let difficulty = self.difficulty {
            return difficulty.description
        } else {
            return NSLocalizedString("ALL_DIFFICULTIES", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = UITableViewCell(style: .value1, reuseIdentifier: reusableCellIdentifier)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                row.textLabel!.text = NSLocalizedString("WON_GAMES", comment: "")
                if let difficulty = self.difficulty {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.getNbGameWon(difficulty))"
                } else {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.nbGameWon)"
                }
            case 1:
                row.textLabel!.text = NSLocalizedString("LOST_GAMES", comment: "")
                if let difficulty = self.difficulty {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.getNbGameLost(difficulty))"
                } else {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.nbGameLost)"
                }
            case 2:
                row.textLabel!.text = NSLocalizedString("GAMES_STARTED", comment: "")
                if let difficulty = self.difficulty {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.getNbGameStarted(difficulty))"
                } else {
                    row.detailTextLabel!.text = "\(GameCounter.sharedInstance.nbGameStarted)"
                }
            case 3:
                row.textLabel!.text = NSLocalizedString("GAMES_FINISHED", comment: "")
                var nbGameFinished = 0
                if let difficulty = self.difficulty {
                    nbGameFinished = GameCounter.sharedInstance.getNbGameWon(difficulty) + GameCounter.sharedInstance.getNbGameLost(difficulty)
                } else {
                    nbGameFinished = GameCounter.sharedInstance.nbGameWon + GameCounter.sharedInstance.nbGameLost
                }
                row.detailTextLabel!.text = "\(nbGameFinished)"
            case 4:
                row.textLabel!.text = NSLocalizedString("WIN_RATE", comment: "")
                var nbGameFinished = 0
                var nbGameWon = 0
                if let difficulty = self.difficulty {
                    nbGameWon = GameCounter.sharedInstance.getNbGameWon(difficulty)
                    nbGameFinished = nbGameWon + GameCounter.sharedInstance.getNbGameLost(difficulty)
                } else {
                    nbGameWon = GameCounter.sharedInstance.nbGameWon
                    nbGameFinished = nbGameWon + GameCounter.sharedInstance.nbGameLost
                }
                
                if nbGameFinished == 0 {
                    row.detailTextLabel!.text = NSLocalizedString("UNKNOWN", comment: "")
                } else {
                    let rate = Double(nbGameWon) * 100 / Double(nbGameFinished)
                    let roundedRate = Double(round(100 * rate)/100)
                    row.detailTextLabel!.text = "\(roundedRate)%"
                }
            default:
                break
            }
        } else {
            row.textLabel!.text = NSLocalizedString("RESET_ALL_STATISTICS", comment: "")
        }
        
        return row
    }
}
