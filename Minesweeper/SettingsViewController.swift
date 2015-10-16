//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import Eureka
import IAPController

class SettingsViewController: FormViewController {
    
    var parentVC: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed:")
        
        setupForm()
        
        self.preferredContentSize = CGSizeMake(320, 400)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchedProducts:", name: IAPControllerFetchedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPurchasedProduct:", name: IAPControllerPurchasedNotification, object: nil)
        
        // Fetching iAP
        IAPController.sharedInstance.fetchProducts()
    }
    
    func setupForm() {
        form.removeAll()
        
            form
            +++ Section("Difficulty")
            <<< PushRow<GameDifficulty>("difficulty") {
                $0.title = "Difficulty"
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
                
            +++ Section(header: "Premium Features", footer: "") {
                $0.hidden = .Function(["Premium Features"], { form -> Bool in
                    return Settings.sharedInstance.completeVersionPurchased
                })
            }
            <<< ButtonRow("buy") {
                $0.title = "Unlock all features"
                $0.disabled = .Function([], { form -> Bool in
                    if let _ = IAPController.sharedInstance.products?.first {
                        return false
                    }
                    return true
                })
                }.onCellSelection { cell, row in
                    if let indexPath = self.tableView!.indexPathForSelectedRow {
                        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
                    }
                    
                    guard let product = IAPController.sharedInstance.products?.first else { return }
                    product.buy()
            }.cellUpdate { cell, row in
                if let product = IAPController.sharedInstance.products?.first {
                    row.title = "Unlock all features (\(product.priceFormatted!))"
                }
            }
            <<< ButtonRow("restore") {
                $0.title = "Restore previous purchase"
                $0.disabled = .Function([], { form -> Bool in
                    if let _ = IAPController.sharedInstance.products?.first {
                        return false
                    }
                    return true
                })
            }.onCellSelection { cell, row in
                    if let indexPath = self.tableView!.indexPathForSelectedRow {
                        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
                    }
                    
                    IAPController.sharedInstance.restore()
            }
            
            +++ Section("Gameplay")
            <<< SwitchRow("vibrate") {
                $0.title = "Vibrations"
                $0.value = Settings.sharedInstance.vibrationEnabled
                $0.hidden = .Function(["vibrate"], { form in
                    return UIDevice.currentDevice().model != "iPhone"
                })
            }.onChange{ row in
                guard let vibrate = row.value else { return }
                Settings.sharedInstance.vibrationEnabled = vibrate
            }
            
            <<< SwitchRow("longPress") {
                $0.title = "Mark with long press"
                $0.value = Settings.sharedInstance.markWithLongPressEnabled
            }.onChange{ row in
                guard let longPress = row.value else { return }
                Settings.sharedInstance.markWithLongPressEnabled = longPress
            }
            
            <<< SwitchRow("hiddenToolbar") {
                $0.title = "Hide toolbar"
                $0.value = Settings.sharedInstance.bottomBarHidden
                $0.hidden = .Function(["longPress"], { form in
                    if let r1 : SwitchRow = form.rowByTag("longPress") {
                        return r1.value == false
                    }
                    return true
                })
            }.onChange{ row in
                guard let hideToolbar = row.value else { return }
                Settings.sharedInstance.bottomBarHidden = hideToolbar
            }
    }
    
    func updateForm() {
        self.form.allRows.forEach{ row in
            row.evaluateDisabled()
            row.evaluateHidden()
            row.updateCell()
        }
    }
    
    func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let parent = parentVC {
            parent.performSettingsChanges()
            parent.performDifficultyChanges()
        }
    }
    
    func presentAvantagesOfFullVersion() {
        // TODO present avantages of Full Version
    }
    
    // MARK: Purchases
    
    func didFetchedProducts(sender: AnyObject) {
        self.updateForm()
    }
    
    func didPurchasedProduct(sender: AnyObject) {
        self.updateForm()
        Settings.sharedInstance.completeVersionPurchased = true
        
        NSNotificationCenter.defaultCenter().postNotificationName(BannerShouldBeHiddenByIAP, object: nil)
        
        let alert = UIAlertView(title: NSLocalizedString("THANK_YOU", comment: ""), message: NSLocalizedString("IAP_SUCCESS", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DISMISS", comment: ""))
        alert.show()
    }
}
