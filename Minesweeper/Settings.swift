//
//  Settings.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

class Settings {
    private static let difficultyString = "difficulty"
    private static let vibrationString = "vibration"
    private static let markWithLongPressString = "markWithLongPress"
    private static let bottomBarHiddenString = "bottomBarHidden"
    private static let completeVersionString = "completeVersion"
    
    class var difficulty: GameDifficulty {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let difficulty = userDefault.stringForKey(difficultyString) {
            if let gameDifficulty = GameDifficulty(rawValue: difficulty) {
                return gameDifficulty
            } else {
                self.setDifficulty(.Easy)
                return .Easy
            }
        } else {
            return .Easy
        }
    }
    
    class func setDifficulty(difficulty: GameDifficulty) {
        if (difficulty.difficultyAvailable) {
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(difficulty.rawValue, forKey: difficultyString)
        }
    }
    
    // Vibrations
    class var isVibrationEnabled: Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey(vibrationString)
    }
    
    class func setVibration(enabled: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(enabled, forKey: vibrationString)
    }
    
    // Mark with long press
    class var isMarkWithLongPressEnabled: Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey(markWithLongPressString)
    }
    
    class func setMarkForLongPress(enabled: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(enabled, forKey: markWithLongPressString)
    }
    
    // Bottom Bar Hidden
    class var isBottomBarHidden: Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey(bottomBarHiddenString)
    }
    
    class func setBottomBarHidden(enabled: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(enabled, forKey: bottomBarHiddenString)
    }
    
    // Ads
    class var isCompleteVersionPurchased: Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey(completeVersionString)
    }
    
    class func setCompletVersionPurchased(purchased: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(purchased, forKey: completeVersionString)
    }
}