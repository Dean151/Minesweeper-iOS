//
//  Board.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

enum GameDifficulty {
    case Easy, Medium, Hard
    
    var description: String {
        switch self {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
        }
    }
    
    var size: (width: Int, height: Int) {
        switch self {
        case .Easy:
            return (8, 8)
        case .Medium:
            return (8, 12)
        case .Hard:
            return (10, 14)
        }
    }
    
    var nbMines: Int {
        switch self {
        case .Easy:
            return 10
        case .Medium:
            return 20
        case .Hard:
            return 40
        }
    }
    
    static var allValues: [GameDifficulty] {
        return [.Easy, .Medium, .Hard]
    }
}

class Board {
    let height: Int
    let width: Int
    let nbMines: Int
    
    var minesInitialized: Bool
    var gameOver: Bool
    
    var tiles: [Tile]
    
    var isGameWon: Bool {
        for t in tiles {
            if !t.isRevealed && !t.isMine {
                return false
            }
        }
        
        return true
    }
    
    init(width: Int, height: Int, nbMines: Int) {
        self.width = width
        self.height = height
        self.nbMines = nbMines
        
        assert(nbMines < width * height, "Impossible to have more mines than available cases")
        
        minesInitialized = false
        gameOver = false
        
        tiles = [Tile]()
        for y in 0..<height {
            for x in 0..<width {
                self.tiles.append(Tile(board: self, x: x, y: y))
            }
        }
    }
    
    func initMines(playedSquare: Tile) {
        var possibilities = [Tile]()
        
        var protectedTiles = self.getNeighbors(playedSquare)
        protectedTiles.append(playedSquare)
        
        for tile in tiles {
            if !contains(protectedTiles, tile) {
                possibilities.append(tile)
            }
        }
        
        for i in 0..<nbMines {
            let index = Int(arc4random_uniform(UInt32(possibilities.count)))
            possibilities[index].setMine()
            possibilities.removeAtIndex(index)
        }
        
        minesInitialized = true
    }
    
    func isInBoard(x: Int, y: Int) -> Bool {
        return x >= 0 && y >= 0 && x < width && y < height
    }
    
    func getIndex(x: Int, y: Int) -> Int {
        return y * width + x
    }
    
    func getTile(x: Int, y: Int) -> Tile? {
        if isInBoard(x, y: y) {
            return tiles[getIndex(x, y: y)]
        }
        
        return nil
    }
    
    func getNeighbors(square: Tile) -> [Tile] {
        var neighbors = [Tile]()
        
        let dx: [Int] = [-1, 0, 1, -1, 1, -1, 0, 1]
        let dy: [Int] = [-1, -1, -1, 0, 0, 1, 1, 1]
        
        for i in 0..<dx.count {
            if let adj = getTile(square.x + dx[i], y: square.y + dy[i]) {
                neighbors.append(adj)
            }
        }
        
        return neighbors
    }
    
    func play(x: Int, y: Int) -> Bool {
        if let s = getTile(x, y: y) {
            return play(s)
        }
        
        return false
    }
    
    func play(tile: Tile) -> Bool {
        if !minesInitialized {
            initMines(tile)
        }
        
        if !tile.isMarked && !gameOver {
            if !tile.isRevealed {
                tile.isRevealed = true
                
                if isGameWon {
                    gameOver = true
                    return true
                }
                
                if tile.isMine {
                    gameOver = true
                } else if tile.nbMineAround == 0 {
                    for neighbor in getNeighbors(tile) {
                        play(neighbor)
                    }
                }
                
                return true
            } else {
                var nbMarked = 0
                var neighbors = getNeighbors(tile)
                for neighbor in neighbors {
                    if neighbor.isMarked {
                        nbMarked++
                    }
                }
                if nbMarked == tile.nbMineAround {
                    for neighbor in neighbors {
                        if !neighbor.isRevealed && !neighbor.isMarked {
                            play(neighbor)
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func mark(x: Int, y: Int) {
        if let s = getTile(x, y: y) {
            mark(s)
        }
    }
    
    func mark(tile: Tile) {
        if !tile.isRevealed {
            tile.isMarked = !tile.isMarked
        } else {
            var nbUnrevealed = 0
            var neighbors = getNeighbors(tile)
            for neighbor in neighbors {
                if !neighbor.isRevealed {
                    nbUnrevealed++
                }
            }
            if nbUnrevealed == tile.nbMineAround {
                for neighbor in neighbors {
                    if !neighbor.isRevealed && !neighbor.isMarked {
                        mark(neighbor)
                    }
                }
            }
        }
    }
}