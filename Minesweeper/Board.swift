//
//  Board.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation

class Board {
    let height: Int
    let width: Int
    let nbMines: Int
    
    var minesInitialized: Bool
    var gameOver: Bool
    
    var board: [Square]
    
    var isGameWon: Bool {
        for s in board {
            if !s.isRevealed && !s.isMine {
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
        
        board = [Square]()
        for y in 0..<height {
            for x in 0..<width {
                self.board.append(Square(board: self, x: x, y: y))
            }
        }
    }
    
    func initMines(playedSquare: Square) {
        var possibilities = [Square]()
        for square in board {
            if square != playedSquare {
                possibilities.append(square)
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
    
    func getSquare(x: Int, y: Int) -> Square? {
        if isInBoard(x, y: y) {
            return board[getIndex(x, y: y)]
        }
        
        return nil
    }
    
    func getNeighbors(square: Square) -> [Square] {
        var neighbors = [Square]()
        
        let dx: [Int] = [-1, 0, 1, -1, 1, -1, 0, 1]
        let dy: [Int] = [-1, -1, -1, 0, 0, 1, 1, 1]
        
        for i in 0..<dx.count {
            if let adj = getSquare(square.x + dx[i], y: square.y + dy[i]) {
                neighbors.append(adj)
            }
        }
        
        return neighbors
    }
    
    func play(x: Int, y: Int) -> Bool {
        if let s = getSquare(x, y: y) {
            return play(s)
        }
        
        return false
    }
    
    func play(square: Square) -> Bool {
        if !minesInitialized {
            initMines(square)
        }
        
        if !square.isMarked && !gameOver {
            if !square.isRevealed {
                square.isRevealed = true
                
                if isGameWon {
                    gameOver = true
                    return true
                }
                
                if square.isMine {
                    gameOver = true
                } else if square.nbMineAround == 0 {
                    for neighbor in getNeighbors(square) {
                        play(neighbor)
                    }
                }
                
                return true
            } else {
                var nbMarked = 0
                var neighbors = getNeighbors(square)
                for neighbor in neighbors {
                    if neighbor.isMarked {
                        nbMarked++
                    }
                }
                if nbMarked == square.nbMineAround {
                    for neighbor in neighbors {
                        if !neighbor.isRevealed && !neighbor.isMarked {
                            play(square)
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    func mark(x: Int, y: Int) {
        if let s = getSquare(x, y: y) {
            mark(s)
        }
    }
    
    func mark(square: Square) {
        if !square.isRevealed {
            square.isMarked = !square.isMarked
        } else {
            var nbUnrevealed = 0
            var neighbors = getNeighbors(square)
            for neighbor in neighbors {
                if !neighbor.isRevealed {
                    nbUnrevealed++
                }
            }
            if nbUnrevealed == square.nbMineAround {
                for neighbor in neighbors {
                    if !neighbor.isRevealed && !neighbor.isMarked {
                        mark(square)
                    }
                }
            }
        }
    }
}