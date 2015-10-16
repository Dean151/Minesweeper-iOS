//
//  GameCounter.swift
//  Minesweeper
//
//  Created by Thomas Durand on 16/10/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import Foundation

class GameCounter {
    private let nbGameWonString = "won"
    private let nbGameStartedString = "started"
    private let nbGameFinishedString = "finished"
    
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
    
    var nbGameStarted: Int {
        var nb = 0
        for difficulty in GameDifficulty.allValues {
            nb += getNbGameStarted(difficulty)
        }
        return nb
    }
    
    var nbGameFinished: Int {
        var nb = 0
        for difficulty in GameDifficulty.allValues {
            nb += getNbGameFinished(difficulty)
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
    func getNbGameFinished(difficulty: GameDifficulty) -> Int {
        return userDefault.integerForKey(difficulty.rawValue + nbGameFinishedString)
    }
    
    func countGameWon(difficulty: GameDifficulty) {
        let nb = getNbGameWon(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameWonString)
        print("Games won: \(nb+1)")
    }
    
    func countGameStarted(difficulty: GameDifficulty) {
        let nb = getNbGameStarted(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameStartedString)
        print("Games started: \(nb+1)")
    }
    
    func countGameFinished(difficulty: GameDifficulty) {
        let nb = getNbGameFinished(difficulty)
        userDefault.setInteger(nb+1, forKey: difficulty.rawValue + nbGameFinishedString)
        print("Games finished: \(nb+1)")
    }
}