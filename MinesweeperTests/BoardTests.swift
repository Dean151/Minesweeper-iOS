//
//  BoardTests.swift
//  Minesweeper
//
//  Created by Thomas Durand on 14/10/2015.
//  Copyright © 2015 Thomas Durand. All rights reserved.
//

import XCTest
@testable import Minesweeper

class BoardTests: XCTestCase {
    var difficulty: GameDifficulty!
    var board: Board!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        difficulty = GameDifficulty.random
        board = Board(difficulty: difficulty)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // isInBoard should return true if in board, and false otherwise
    func testIsInBoard() {
        // Corner cases
        XCTAssertTrue(board.isInBoard(0, y: 0))
        XCTAssertTrue(board.isInBoard(0, y: board.height-1))
        XCTAssertTrue(board.isInBoard(board.width-1, y: 0))
        XCTAssertTrue(board.isInBoard(board.width-1, y: board.height-1))
        
        // Inside board
        let x = Int(arc4random_uniform(UInt32(board.width)))
        let y = Int(arc4random_uniform(UInt32(board.height)))
        XCTAssertTrue(board.isInBoard(x, y: y))
        
        // Out of board anyway
        XCTAssertFalse(board.isInBoard(-1, y: 0))
        XCTAssertFalse(board.isInBoard(0, y: -1))
        XCTAssertFalse(board.isInBoard(0, y: board.height))
        XCTAssertFalse(board.isInBoard(board.width, y: 0))
        XCTAssertFalse(board.isInBoard(board.width, y: board.height))
    }
    
    // Return nil if tile does not exist, tile otherwise
    func testTileGetter() {
        // Test out of board
        XCTAssertNil(board.getTile(-1, y: -1))
        XCTAssertNil(board.getTile(board.width, y: board.height))
        
        // Test random tile
        let x = Int(arc4random_uniform(UInt32(board.width)))
        let y = Int(arc4random_uniform(UInt32(board.height)))
        let tile = board.getTile(x, y: y)
        XCTAssertNotNil(tile)
        XCTAssertEqual(tile!.x, x)
        XCTAssertEqual(tile!.y, y)
    }
    
    /* Tiles are stored in a simple array, so we have to get the index in this array
      (0,0) (1,0) (2,0)      0 1 2
      (0,1) (1,1) (2,1)  =>  3 4 5
      (0,2) (1,2) (2,2)      6 7 8
    */
    func testTileIndexes() {
        XCTAssertEqual(board.getIndex(0, y: 0), 0)
        XCTAssertEqual(board.getIndex(1, y: 0), 1)
        XCTAssertEqual(board.getIndex(0, y: 1), board.width)
        XCTAssertEqual(board.getIndex(2, y: 1), board.width+2)
        XCTAssertEqual(board.getIndex(0, y: 2), board.width*2)
        XCTAssertEqual(board.getIndex(board.width-1, y: board.height-1), board.height*board.width-1)
    }
    
    func testMineInitialisation() {
        // Initialization of mines in board
        board.initMines(nil)
        
        // Number of mines
        var nbMines = 0
        for tile in board.tiles {
            if tile.isMine {
                nbMines++
            }
        }
        
        XCTAssertEqual(nbMines, difficulty.nbMines)
    }
    
    // We have to make sure we get the neighbors tiles
    func testNeighborsGetter() {
        // Testing for random tile
        let x = Int(arc4random_uniform(UInt32(board.width-2)))+1
        let y = Int(arc4random_uniform(UInt32(board.height-2)))+1
        
        neighborsTester(0, y: 0)
        neighborsTester(0, y: 1)
        neighborsTester(1, y: 0)
        neighborsTester(x, y: y)
        neighborsTester(board.width-1, y: board.height-1)
    }
    
    func neighborsTester(x: Int, y: Int) {
        guard let tile = board.getTile(x, y: y) else { return }
        let neighbors = board.getNeighbors(tile)
        
        // Normal case
        var nbNeighbors = 8
        
        // If in border, there is 3 neighbors fewer
        if x == 0 || x == board.width-1 {
            nbNeighbors -= 3
        }
        if y == 0 || y == board.height-1 {
            nbNeighbors -= 3
        }
        
        // Special case when tile is corner : we removed one neighbor twice !
        if nbNeighbors < 3 {
            nbNeighbors = 3
        }
        
        // Checking we have all neighbors
        XCTAssertEqual(neighbors.count, nbNeighbors)
        
        // Testing if all neighbors are neighbors
        for neighbor in neighbors {
            XCTAssert(neighbor.x >= x-1 && neighbor.x <= x+1)
            XCTAssert(neighbor.y >= y-1 && neighbor.y <= y+1)
        }
    }
}