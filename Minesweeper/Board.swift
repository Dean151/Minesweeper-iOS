//
//  Board.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

enum GameDifficulty: String {
    case Easy = "easy", Medium = "medium", Hard = "hard", Insane = "insane"
    
    var description: String {
        switch self {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
        case .Insane:
            return "Insane"
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
        case .Insane:
            return (12, 16)
        }
    }
    
    var nbMines: Int {
        switch self {
        case .Easy:
            return 10
        case .Medium:
            return 20
        case .Hard:
            return 35
        case .Insane:
            return 50
        }
    }
    
    static var allValues: [GameDifficulty] {
        return [.Easy, .Medium, .Hard, .Insane]
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
    
    func play(x: Int, y: Int) -> [Tile] {
        if let s = getTile(x, y: y) {
            return play(s)
        }
        
        return [Tile]()
    }
    
    func play(tile: Tile) -> [Tile] {
        var playedTiles = [Tile]()
        
        if !minesInitialized {
            initMines(tile)
        }
        
        if !tile.isMarked && !gameOver {
            if !tile.isRevealed {
                tile.isRevealed = true
                playedTiles.append(tile)
                
                if isGameWon {
                    gameOver = true
                    return playedTiles
                }
                
                if tile.isMine {
                    gameOver = true
                } else if tile.nbMineAround == 0 {
                    for neighbor in getNeighbors(tile) {
                        let tiles = play(neighbor)
                        playedTiles += tiles
                    }
                }
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
                            let tiles = play(neighbor)
                            playedTiles += tiles
                        }
                    }
                }
            }
        }
        
        return playedTiles
    }
    
    func mark(x: Int, y: Int) -> [Tile] {
        if let s = getTile(x, y: y) {
            return mark(s)
        }
        
        return [Tile]()
    }
    
    func mark(tile: Tile) -> [Tile] {
        var markedTiles = [Tile]()
        
        if  !gameOver {
            if !tile.isRevealed {
                tile.isMarked = !tile.isMarked
                markedTiles.append(tile)
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
                            let tiles = mark(neighbor)
                            markedTiles += tiles
                        }
                    }
                }
            }
        }
        return markedTiles
    }
}