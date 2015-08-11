//
//  SettingsViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import UIKit
import XLForm

class SettingsViewController: XLFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForm()
    }
    
    func setupForm() {
        let form = XLFormDescriptor(title: "Settings")
        
        var section = XLFormSectionDescriptor()
        section.title = "Difficulty"
        form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: "difficulty", rowType: XLFormRowDescriptorTypeSelectorPush, title: "Difficulty")
        row.selectorTitle = "Difficulty"
        row.selectorOptions = GameDifficulty.allRawValues
        row.value = Settings.difficulty.rawValue
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor()
        section.title = "Gameplay"
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "vibrate", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Vibrations")
        row.value = Settings.isVibrationEnabled
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "longPress", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Mark with long press")
        row.value = Settings.isMarkWithLongPressEnabled
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "hiddenToolbar", rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Hide Toolbar")
        row.value = Settings.isBottomBarHidden
        row.hidden = "$longPress==0"
        section.addFormRow(row)
        
        self.form = form
    }
    
    func saveForm() {
        let dict = self.formValues()
        
        if let raw = dict["difficulty"] as? String {
            if let difficulty = GameDifficulty(rawValue: raw) {
                Settings.saveDifficulty(difficulty)
            }
        }
        
        if let vibrate = dict["vibrate"] as? Bool {
            Settings.setVibration(vibrate)
        }
        
        if let longPress = dict["longPress"] as? Bool {
            Settings.setMarkForLongPress(longPress)
        }
        
        if let hiddenToolbar = dict["hiddenToolbar"] as? Bool {
            Settings.setBottomBarHidden(hiddenToolbar)
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        saveForm()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
