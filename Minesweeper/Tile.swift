//
//  Square.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SpriteKit

class Tile: Equatable {
    unowned let board: Board
    var x, y: Int
    var isMine: Bool
    var isRevealed: Bool
    var isMarked: Bool
    var nbMineAround: Int
    
    var sprite: SKNode!
    
    init(board: Board, x: Int, y: Int) {
        self.board = board
        self.x = x
        self.y = y
        self.isMine = false
        self.isRevealed = false
        self.isMarked = false
        self.nbMineAround = 0
    }
    
    func setMine() {
        if (!isMine) {
            isMine = true
            let adjacents = board.getNeighbors(self)
            for adj in adjacents {
                adj.nbMineAround++
            }
        }
    }
    
    func squareDistanceFromTile(_ tile: Tile) -> Int {
        return (x - tile.x)*(x - tile.x) + (y - tile.y)*(y - tile.y)
    }
    
}

func ==(lhs: Tile, rhs: Tile) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
