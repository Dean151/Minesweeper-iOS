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
    fileprivate let nbGameWonString = "won"
    fileprivate let nbGameLostString = "lost"
    fileprivate let nbGameStartedString = "started"
    
    fileprivate let userDefault = UserDefaults.standard
    
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
    func getNbGameWon(_ difficulty: GameDifficulty) -> Int {
        return userDefault.integer(forKey: difficulty.rawValue + nbGameWonString)
    }
    
    // Number of game initiated for a difficulty
    func getNbGameStarted(_ difficulty: GameDifficulty) -> Int {
        return userDefault.integer(forKey: difficulty.rawValue + nbGameStartedString)
    }
    
    // Number of game concluded for a difficulty
    func getNbGameLost(_ difficulty: GameDifficulty) -> Int {
        return userDefault.integer(forKey: difficulty.rawValue + nbGameLostString)
    }
    
    func countGameWon(_ difficulty: GameDifficulty) {
        let nb = getNbGameWon(difficulty)
        userDefault.set(nb+1, forKey: difficulty.rawValue + nbGameWonString)
        
        Answers.logLevelEnd(difficulty.rawValue, score: nil, success: true, customAttributes: nil)
        
        // Achievement for One game
        let achievementIdentifier = "fr.Dean.Minesweeper.\(difficulty.rawValue)GameWon"
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifier, percent: 100.0)
        
        // Achievement for Ten games
        let achievementIdentifierTen = "fr.Dean.Minesweeper.Ten\(difficulty.rawValue)GameWon"
        let progressTen = min(Double((nb+1)*10), 100)
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifierTen, percent: progressTen)
        
        // Achievement for Hundred games
        let achievementIdentifierHundred = "fr.Dean.Minesweeper.HundredGamesWon"
        let progressHundred = min(Double((self.nbGameWon)), 100)
        GCHelper.sharedInstance.reportAchievementIdentifier(achievementIdentifierHundred, percent: progressHundred)
    }
    
    func countGameStarted(_ difficulty: GameDifficulty) {
        let nb = getNbGameStarted(difficulty)
        userDefault.set(nb+1, forKey: difficulty.rawValue + nbGameStartedString)
        
        Answers.logLevelStart(difficulty.rawValue, customAttributes: nil)
    }
    
    func countGameLost(_ difficulty: GameDifficulty) {
        let nb = getNbGameLost(difficulty)
        userDefault.set(nb+1, forKey: difficulty.rawValue + nbGameLostString)
        
        Answers.logLevelEnd(difficulty.rawValue, score: nil, success: false, customAttributes: nil)
    }
    
    func reportScore(_ score: TimeInterval, forDifficulty: GameDifficulty) {
        let leaderboardIdentifier = "fr.Dean.Minesweeper.\(forDifficulty.rawValue)"
        let score2submit = Int(100 * Double(score))
        GCHelper.sharedInstance.reportLeaderboardIdentifier(leaderboardIdentifier, score: score2submit)
    }
    
    func resetAllStats() {
        for difficulty in GameDifficulty.allValues {
            userDefault.set(0, forKey: difficulty.rawValue + nbGameStartedString)
            userDefault.set(0, forKey: difficulty.rawValue + nbGameWonString)
            userDefault.set(0, forKey: difficulty.rawValue + nbGameLostString)
        }
    }
}
