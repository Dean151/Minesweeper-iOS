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
    fileprivate let difficultyString = "difficulty"
    fileprivate let vibrationString = "vibrationDisabled"
    fileprivate let markWithLongPressString = "markWithLongPressDisabled"
    fileprivate let markWithDeepPressString = "markWithDeepPressEnabled"
    fileprivate let bottomBarHiddenString = "bottomBarHidden"
    fileprivate let completeVersionString = "completeVersion"
    
    fileprivate let userDefault = UserDefaults.standard
    
    // Singleton
    static let sharedInstance = Settings()
    
    init() {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SecureNSUserDefaultKey") as? String else {
            fatalError("Could access encryption key")
        }
        userDefault.setSecret(key)
    }
    
    var difficulty: GameDifficulty {
        get {
            if let difficulty = userDefault.string(forKey: difficultyString) {
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
            userDefault.set(newValue.rawValue, forKey: difficultyString)
        }
    }
    
    // Vibrations
    var vibrationEnabled: Bool {
        get {
            return !userDefault.bool(forKey: vibrationString)
        }
        set {
            userDefault.set(!newValue, forKey: vibrationString)
        }
    }
    
    // Mark with long press
    var markWithLongPressEnabled: Bool {
        get {
            return !userDefault.bool(forKey: markWithLongPressString)
        }
        set {
            userDefault.set(!newValue, forKey: markWithLongPressString)
        }
    }
    
    // Mark with deep press
    var markWithDeepPressEnabled: Bool {
        get {
            return userDefault.bool(forKey: markWithDeepPressString)
        }
        set {
            userDefault.set(newValue, forKey: markWithDeepPressString)
        }
    }
    
    // Bottom Bar 
    var bottomBarHidden: Bool {
        get {
            return userDefault.bool(forKey: bottomBarHiddenString)
        }
        set {
            userDefault.set(newValue, forKey: bottomBarHiddenString)
        }
    }
    
    // Complete 
    var completeVersionPurchased: Bool {
        get {
            return userDefault.secretBool(forKey: completeVersionString)
        }
        set {
            userDefault.setSecretBool(newValue, forKey: completeVersionString)
        }
    }
}
