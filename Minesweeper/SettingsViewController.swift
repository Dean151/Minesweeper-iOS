//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

import Eureka
import GameKit
import GCHelper

import Crashlytics

class SettingsViewController: FormViewController {
    
    var parentVC: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("SETTINGS", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.donePressed(_:)))
        
        setupForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let parent = parentVC {
            parent.performSettingsChanges()
            parent.performDifficultyChanges()
        }
    }
    
    func setupForm() {
        form.removeAll()
        
        form
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("DIFFICULTY", comment: ""))
            }
            <<< PushRow<GameDifficulty>("difficulty") {
                $0.title = NSLocalizedString("DIFFICULTY", comment: "")
                $0.options = GameDifficulty.allValues
                $0.value = Settings.sharedInstance.difficulty
            }.onChange { row in
                    guard let difficulty = row.value else { return }
                    Settings.sharedInstance.difficulty = difficulty
            }
            <<< ButtonRow("stats") {
                $0.title = NSLocalizedString("STATISTICS", comment: "")
            }.onCellSelection { form in
                self.deselectRows()
                
                let statsVC = StatsTableViewController(style: .grouped)
                self.navigationController!.pushViewController(statsVC, animated: true)
            }
            
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("GAMEPLAY", comment: ""))
            }
            <<< SwitchRow("vibrate") {
                $0.title = NSLocalizedString("VIBRATIONS", comment: "")
                $0.value = Settings.sharedInstance.vibrationEnabled
                $0.hidden = .function(["vibrate"], { form in
                    return UIDevice.current.model != "iPhone"
                })
            }.onChange{ row in
                    guard let vibrate = row.value else { return }
                    Settings.sharedInstance.vibrationEnabled = vibrate
            }
            
            <<< SwitchRow("longPress") {
                $0.title = NSLocalizedString("MARK_WITH_LONG_PRESS", comment: "")
                $0.value = Settings.sharedInstance.markWithLongPressEnabled
            }.onChange{ row in
                    guard let longPress = row.value else { return }
                    Settings.sharedInstance.markWithLongPressEnabled = longPress
            }
            
            <<< SwitchRow("deepPress") {
                $0.title = NSLocalizedString("MARK_WITH_DEEP_PRESS", comment: "")
                $0.value = Settings.sharedInstance.markWithDeepPressEnabled
                }.onChange{ row in
                    guard let deepPress = row.value else { return }
                    Settings.sharedInstance.markWithDeepPressEnabled = deepPress
            }
            
            <<< SwitchRow("hiddenToolbar") {
                $0.title = NSLocalizedString("HIDE_TOOLBAR", comment: "")
                $0.value = Settings.sharedInstance.bottomBarHidden
                $0.hidden = .function(["longPress", "deepPress"], { form in
                    if let r1 : SwitchRow = form.rowBy(tag: "longPress"), let r2: SwitchRow = form.rowBy(tag: "deepPress") {
                        return r1.value == false && r2.value == false
                    }
                    return true
                })
            }.onChange{ row in
                    guard let hideToolbar = row.value else { return }
                    Settings.sharedInstance.bottomBarHidden = hideToolbar
            }
            
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("GAME_CENTER", comment: ""))
                $0.hidden = .function(["gamecenter"], { form -> Bool in
                    return !GCHelper.sharedInstance.isUserAuthenticated
                })
            }
            <<< ButtonRow("leaderboards") {
                $0.title = NSLocalizedString("LEADERBOARDS", comment: "")
                }.onCellSelection({ cell, row in
                    self.deselectRows()
                    
                    GCHelper.sharedInstance.showGameCenter(self, viewState: .leaderboards)
                })
            <<< ButtonRow("achievements") {
                $0.title = NSLocalizedString("ACHIEVEMENTS", comment: "")
            }.onCellSelection({ cell, row in
                self.deselectRows()
                
                GCHelper.sharedInstance.showGameCenter(self, viewState: .achievements)
            })
    }
    
    func updateForm() {
        self.form.allRows.forEach{ row in
            row.evaluateDisabled()
            row.evaluateHidden()
            row.updateCell()
        }
    }
    
    func deselectRows() {
        if let indexPath = self.tableView!.indexPathForSelectedRow {
            self.tableView!.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func donePressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
