//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import StoreKit
import Eureka

class SettingsViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed:")
        
        setupForm()
    }
    
    func setupForm() {
        form.removeAll()
        
        form +++
            Section("Difficulty")
            <<< PushRow<String>("difficulty") {
                $0.title = "Difficulty"
                $0.options = GameDifficulty.allRawValues
                $0.value = Settings.difficulty.rawValue
            }.onChange { row in
                guard let rawVal = row.value else { return }
                guard let difficulty = GameDifficulty(rawValue: rawVal) else { return }
                Settings.setDifficulty(difficulty)
            }
            
            +++ Section("Gameplay")
            <<< SwitchRow("vibrate") {
                $0.title = "Vibrations"
                $0.value = Settings.isVibrationEnabled
            }.onChange{ row in
                guard let vibrate = row.value else { return }
                Settings.setVibration(vibrate)
            }
            
            <<< SwitchRow("longPress") {
                $0.title = "Mark with long press"
                $0.value = Settings.isMarkWithLongPressEnabled
            }.onChange{ row in
                guard let longPress = row.value else { return }
                Settings.setMarkForLongPress(longPress)
            }
            
            <<< SwitchRow("hiddenToolbar") {
                $0.title = "Hide toolbar"
                $0.value = Settings.isBottomBarHidden
            }.onChange{ row in
                guard let hideToolbar = row.value else { return }
                Settings.setBottomBarHidden(hideToolbar)
            }
        /*
        if !Settings.isCompleteVersionPurchased {
            section = XLFormSectionDescriptor()
            section.title = "Purchase complete version"
            section.footerTitle = "Complete version gives you access to Hard and Insane levels of difficulty"
            form.addFormSection(section)
            
            hideAdsRow = XLFormRowDescriptor(tag: "fullVersion", rowType: XLFormRowDescriptorTypeButton, title: "Purchase complete version")
            hideAdsRow!.action.formSelector = Selector("purchaseFullVersion")
            hideAdsRow!.disabled = true
            section.addFormRow(hideAdsRow!)
            
            restoreRow = XLFormRowDescriptor(tag: "restorePurchase", rowType: XLFormRowDescriptorTypeButton, title: "Restore purchases")
            restoreRow!.action.formSelector = Selector("restoreInAppPurchase")
            hideAdsRow!.disabled = true
            section.addFormRow(restoreRow!)
        }
        
        self.form = form
        */
    }
    
    func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
