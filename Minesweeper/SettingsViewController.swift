//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit

import EasyGameCenter
import Eureka
import GameKit
import IAPController

import Crashlytics

class SettingsViewController: FormViewController, GKGameCenterControllerDelegate {
    
    var parentVC: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("SETTINGS", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed:")
        
        setupForm()
        
        self.preferredContentSize = CGSizeMake(320, 400)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchedProducts:", name: IAPControllerFetchedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPurchasedProduct:", name: IAPControllerPurchasedNotification, object: nil)
        
        // Fetching iAP
        IAPController.sharedInstance.fetchProducts()
    }
    
    override func viewWillDisappear(animated: Bool) {
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
                    if difficulty.difficultyAvailable {
                        Settings.sharedInstance.difficulty = difficulty
                    } else {
                        row.value = Settings.sharedInstance.difficulty
                        self.presentAvantagesOfFullVersion()
                    }
            }
            
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("PREMIUM_FEATURES", comment: ""))
                $0.hidden = .Function(["Premium Features"], { form -> Bool in
                    return Settings.sharedInstance.completeVersionPurchased
                })
            }
            <<< ButtonRow("about") {
                $0.title = NSLocalizedString("ABOUT_PREMIUM", comment: "")
                }.onCellSelection { cell, row in
                    self.deselectRows()
                    self.presentAvantagesOfFullVersion()
            }
            <<< ButtonRow("buy") {
                $0.title = NSLocalizedString("BUY_PREMIUM", comment: "")
                $0.disabled = .Function([], { form -> Bool in
                    if let _ = IAPController.sharedInstance.products?.first {
                        return false
                    }
                    return true
                })
            }.onCellSelection { cell, row in
                    self.deselectRows()
                    guard let product = IAPController.sharedInstance.products?.first else { return }
                    product.buy()
            }.cellUpdate { cell, row in
                    if let product = IAPController.sharedInstance.products?.first {
                        row.title = String.localizedStringWithFormat(NSLocalizedString("BUY_PREMIUM_WITH_PRICE", comment: ""),
                            product.priceFormatted!);
                    }
            }
            <<< ButtonRow("restore") {
                $0.title = NSLocalizedString("RESTORE", comment: "")
                $0.disabled = .Function([], { form -> Bool in
                    if let _ = IAPController.sharedInstance.products?.first {
                        return false
                    }
                    return true
                })
            }.onCellSelection { cell, row in
                    self.deselectRows()
                    IAPController.sharedInstance.restore()
            }
            
            +++ Section() {
                $0.header = HeaderFooterView<UIView>(stringLiteral: NSLocalizedString("GAMEPLAY", comment: ""))
            }
            <<< SwitchRow("vibrate") {
                $0.title = NSLocalizedString("VIBRATIONS", comment: "")
                $0.value = Settings.sharedInstance.vibrationEnabled
                $0.hidden = .Function(["vibrate"], { form in
                    return UIDevice.currentDevice().model != "iPhone"
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
                $0.hidden = .Function(["longPress", "deepPress"], { form in
                    if let r1 : SwitchRow = form.rowByTag("longPress"), r2: SwitchRow = form.rowByTag("deepPress") {
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
                $0.hidden = .Function(["gamecenter"], { form -> Bool in
                    return !EGC.isPlayerIdentified
                })
            }
            <<< ButtonRow("leaderboards") {
                $0.title = NSLocalizedString("LEADERBOARDS", comment: "")
                }.onCellSelection({ cell, row in
                    self.deselectRows()
                    let gcvc = GKGameCenterViewController()
                    gcvc.viewState = .Leaderboards
                    gcvc.gameCenterDelegate = self
                    self.presentViewController(gcvc, animated: true, completion: nil)
                })
            <<< ButtonRow("achievements") {
                $0.title = NSLocalizedString("ACHIEVEMENTS", comment: "")
            }.onCellSelection({ cell, row in
                self.deselectRows()
                let gcvc = GKGameCenterViewController()
                gcvc.viewState = .Achievements
                gcvc.gameCenterDelegate = self
                self.presentViewController(gcvc, animated: true, completion: nil)
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
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentAvantagesOfFullVersion() {
        // TODO present avantages of Full Version
    }
    
    // MARK : GameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: In-App Purchases
    
    func didFetchedProducts(sender: AnyObject) {
        self.updateForm()
    }
    
    func didPurchasedProduct(sender: AnyObject) {
        self.updateForm()
        Settings.sharedInstance.completeVersionPurchased = true
        
        Answers.logPurchaseWithPrice(1.99, currency: "USD", success: true, itemName: "Premium Buyed", itemType: nil, itemId: nil, customAttributes: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName(BannerShouldBeHiddenByIAP, object: nil)
        
        let alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_SUCCESS", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}
