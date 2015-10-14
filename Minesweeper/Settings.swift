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
    
    private static let userDefault = NSUserDefaults.standardUserDefaults()
    
    class var difficulty: GameDifficulty {
        get {
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
                userDefault.setObject(newValue.rawValue, forKey: difficultyString)
            }
        }
    }
    
    // Vibrations
    class var vibrationEnabled: Bool {
        get {
            return userDefault.boolForKey(vibrationString)
        }
        set {
            userDefault.setBool(newValue, forKey: vibrationString)
        }
    }
    
    // Mark with long press
    class var markWithLongPressEnabled: Bool {
        get {
            return userDefault.boolForKey(markWithLongPressString)
        }
        set {
            userDefault.setBool(newValue, forKey: markWithLongPressString)
        }
    }
    
    // Bottom Bar Hidden
    class var bottomBarHidden: Bool {
        get {
            return userDefault.boolForKey(bottomBarHiddenString)
        }
        set {
            userDefault.setBool(newValue, forKey: bottomBarHiddenString)
        }
    }
    
    // Complete version
    class var completeVersionPurchased: Bool {
        get {
            return userDefault.boolForKey(completeVersionString)
        }
        set {
            userDefault.setBool(newValue, forKey: completeVersionString)
        }
    }
}