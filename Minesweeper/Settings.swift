//
//  Settings.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SecureNSUserDefaults

class Settings {
    private let difficultyString = "difficulty"
    private let vibrationString = "vibrationDisabled"
    private let markWithLongPressString = "markWithLongPressDisabled"
    private let markWithDeepPressString = "markWithDeepPressEnabled"
    private let bottomBarHiddenString = "bottomBarHidden"
    private let completeVersionString = "completeVersion"
    
    private let userDefault = NSUserDefaults.standardUserDefaults()
    
    // Singleton
    static let sharedInstance = Settings()
    
    init() {
        guard let key = NSBundle.mainBundle().objectForInfoDictionaryKey("SecureNSUserDefaultKey") as? String else {
            fatalError("Could access encryption key")
        }
        userDefault.setSecret(key)
    }
    
    var difficulty: GameDifficulty {
        get {
            if let difficulty = userDefault.stringForKey(difficultyString) {
                if let gameDifficulty = GameDifficulty(rawValue: difficulty) {
                    return gameDifficulty
                } else {
                    self.difficulty = .Easy
                    return .Easy
                }
            } else {
                return .Easy
            }
        }
        set {
            userDefault.setObject(newValue.rawValue, forKey: difficultyString)
        }
    }
    
    // Vibrations
    var vibrationEnabled: Bool {
        get {
            return !userDefault.boolForKey(vibrationString)
        }
        set {
            userDefault.setBool(!newValue, forKey: vibrationString)
        }
    }
    
    // Mark with long press
    var markWithLongPressEnabled: Bool {
        get {
            return !userDefault.boolForKey(markWithLongPressString)
        }
        set {
            userDefault.setBool(!newValue, forKey: markWithLongPressString)
        }
    }
    
    // Mark with deep press
    var markWithDeepPressEnabled: Bool {
        get {
            return userDefault.boolForKey(markWithDeepPressString)
        }
        set {
            userDefault.setBool(newValue, forKey: markWithDeepPressString)
        }
    }
    
    // Bottom Bar 
    var bottomBarHidden: Bool {
        get {
            return userDefault.boolForKey(bottomBarHiddenString)
        }
        set {
            userDefault.setBool(newValue, forKey: bottomBarHiddenString)
        }
    }
    
    // Complete 
    var completeVersionPurchased: Bool {
        get {
            return userDefault.secretBoolForKey(completeVersionString)
        }
        set {
            userDefault.setSecretBool(newValue, forKey: completeVersionString)
        }
    }
}