//
//  Settings.swift
//  Minesweeper
//
//  Created by Thomas Durand on 10/08/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

class Settings {
    class var getDifficulty: GameDifficulty {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let difficulty = userDefault.stringForKey("difficulty") {
            if let gameDifficulty = GameDifficulty(rawValue: difficulty) {
                return gameDifficulty
            } else {
                self.saveDifficulty(.Easy)
                return .Easy
            }
        } else {
            return .Easy
        }
    }
    
    class func saveDifficulty(difficulty: GameDifficulty) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(difficulty.rawValue, forKey: "difficulty")
    }
    
    class var isVibrationEnabled: Bool {
        let userDefault = NSUserDefaults.standardUserDefaults()
        return userDefault.boolForKey("vibration")
    }
    
    class func setVibration(enabled: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(enabled, forKey: "vibration")
    }
}