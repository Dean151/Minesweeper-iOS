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
        self.navigationController!.toolbarHidden = false
        
        // Creating segmented toolbar
        let items = [NSLocalizedString("ALL", comment: "")] + GameDifficulty.allShortDescValues
        difficultyControl = UISegmentedControl(items: items)
        difficultyControl.apportionsSegmentWidthsByContent = true
        difficultyControl.selectedSegmentIndex = 0
        difficultyControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: .ValueChanged);
        
        let frame = difficultyControl.frame
        let newFrame = CGRectMake(frame.origin.x, frame.origin.y, 300, frame.height)
        difficultyControl.frame = newFrame

        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let segmItem = UIBarButtonItem(customView: difficultyControl)
        
        self.toolbarItems = [space, segmItem, space]
    }
    
    func segmentedControlChanged(sender: UISegmentedControl) {
        var animation = UITableViewRowAnimation.Automatic
        
        if sender.selectedSegmentIndex == 0 {
            self.difficulty = nil
            animation = .Right
        } else {
            if let diff = self.difficulty {
                animation = (diff.toInt < sender.selectedSegmentIndex) ? .Left : .Right
            } else {
                animation = .Left
            }
            self.difficulty = GameDifficulty.fromInt(sender.selectedSegmentIndex)
        }
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: animation)
    }
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            GameCounter.sharedInstance.resetAllStats()
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
        }
    }
    
    // MARK: TableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1 {
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""), destructiveButtonTitle: NSLocalizedString("RESET_ALL_STATISTICS", comment: ""))
            
            actionSheet.showInView(self.view)
        }
    }
    
    // MARK: TableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard section == 0 else { return nil }
        
        if let difficulty = self.difficulty {
            return difficulty.description
        } else {
            return NSLocalizedString("ALL_DIFFICULTIES", comment: "")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = UITableViewCell(style: .Value1, reuseIdentifier: reusableCellIdentifier)
        
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