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
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            if let difficulty = userDefault.stringForKey(difficultyString) {
                if let gameDifficulty = GameDifficulty(rawValue: difficulty) {
                    return gameDifficulty
                } else {
                    Settings.difficulty = .Easy
                    return .Easy
                }
            } else {
                return .Easy
            }
        }
        set {
            if (newValue.difficultyAvailable) {
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(newValue.rawValue, forKey: difficultyString)
            }
        }
    }
    
    // Vibrations
    class var vibrationEnabled: Bool {
        get {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey(vibrationString)
        }
        set {
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setBool(newValue, forKey: vibrationString)
        }
    }
    
    // Mark with long press
    class var markWithLongPressEnabled: Bool {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            return userDefault.boolForKey(markWithLongPressString)
        }
        set {
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setBool(newValue, forKey: markWithLongPressString)
        }
    }
    
    // Bottom Bar Hidden
    class var bottomBarHidden: Bool {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            return userDefault.boolForKey(bottomBarHiddenString)
        }
        set {
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setBool(newValue, forKey: bottomBarHiddenString)
        }
    }
    
    // Complete version
    class var completeVersionPurchased: Bool {
        get {
            let userDefault = NSUserDefaults.standardUserDefaults()
            return userDefault.boolForKey(completeVersionString)
        }
        set {
            let userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setBool(newValue, forKey: completeVersionString)
        }
    }
}