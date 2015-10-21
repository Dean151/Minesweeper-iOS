//
//  GameCounter.swift
//  Minesweeper
//
//  Created by Thomas Durand on 16/10/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import Crashlytics
import Foundation
import GCHelper

class GameCounter {
    private let nbGameWonString = "won"
    private let nbGameLostString = "lost"
    private let nbGameStartedString = "started"
    
    private let userDefault = NSUserDefaults.standardUserDefaults()
    
    // Singleton
    static let sharedInstance = GameCounter()
    
    var nbGameWon: Int {
        var nb = 0
        for difficulty in GameDifficulty.allValues {
            nb += getNbGameWon(difficulty)
        }
        return nb
    }
    
    var nbGameLost: Int {
        var nb = 0
        for difficulty in GameDifficulty.allValues {
            nb += getNbGameLost(difficulty)
        }
        return nb
    }
    
    var nbGameStarted: Int {
        var nb = 0
        for difficulty in GameDifficulty.allValues {
            nb += getNbGameStarted(difficulty)
        }
        return nb
    }
    
    // Number of game won for a difficulty
    func getNbGameWon(difficulty: GameDifficulty) -> Int {
        return userDefault.integerForKey(difficulty.rawValue + nbGameWonString)
    }
    
    // Number of game initiated for a difficulty
    func getNbGameStarted(difficulty: GameDifficulty) -> Int {
        return userDefault.integerForKey(difficulty.rawValue + nbGameStartedString)
    }
    
    // Number of game concluded for a difficulty
    func getNbGameLost(difficulty: GameDifficulty) -> Int {
        return userDefault.integerForKey(difficulty.rawValue + nbGameLostString)
    }
    
    func countGameWon(difficulty: GameDifficulty) {
        let nb = getNbGameWon(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameWonString)
        
        Answers.logCustomEventWithName("GameWon", customAttributes: ["Difficulty": difficulty.rawValue])
        
        // Achievement for One game
        let achievementIdentifier = "fr.Dean.Minesweeper.\(difficulty.rawValue)GameWon"
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifier, percent: 100.0)
        
        // Achievement for Ten games
        let achievementIdentifierTen = "fr.Dean.Minesweeper.Ten\(difficulty.rawValue)GameWon"
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifierTen, percent: 10, showCompletionBanner: true, addToExistingAvancement: true)
        
        // Achievement for Hundred games
        let achievementIdentifierHundred = "fr.Dean.Minesweeper.HundredGamesWon"
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifierHundred, percent: 1, showCompletionBanner: true, addToExistingAvancement: true)
    }
    
    func countGameStarted(difficulty: GameDifficulty) {
        let nb = getNbGameStarted(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameStartedString)
        
        Answers.logCustomEventWithName("GameStarted", customAttributes: ["Difficulty": difficulty.rawValue])
    }
    
    func countGameLost(difficulty: GameDifficulty) {
        let nb = getNbGameLost(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameLostString)
        
        Answers.logCustomEventWithName("GameLost", customAttributes: ["Difficulty": difficulty.rawValue])
    }
    
    func reportScore(score: NSTimeInterval, forDifficulty: GameDifficulty) {
        let leaderboardIdentifier = "fr.Dean.Minesweeper.\(forDifficulty.rawValue)"
        let score2submit = Int(100 * Double(score))
        GCHelper.sharedInstance.reportLeaderboardIdentifier(leaderboardIdentifier, score: score2submit)
    }
    
    func resetAllStats() {
        for difficulty in GameDifficulty.allValues {
            userDefault.setInteger(0, forKey: difficulty.rawValue + nbGameStartedString)
            userDefault.setInteger(0, forKey: difficulty.rawValue + nbGameWonString)
            userDefault.setInteger(0, forKey: difficulty.rawValue + nbGameLostString)
        }
    }
}