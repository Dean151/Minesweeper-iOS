//
//  GameScene.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import SpriteKit
import HexColors

class GameScene: SKScene {
    let board: Board
    let controller: GameViewController
    var tileSize: CGFloat
    
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, controller: GameViewController, difficulty: GameDifficulty) {
        self.board = Board(width: difficulty.size.width, height: difficulty.size.height, nbMines: difficulty.nbMines)
        
        self.controller = controller
        self.tileSize = 10
        super.init(size: size)
        
        // Setting up the scene
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = Theme.backgroundColor
        addChild(gameLayer)
        
        gameLayer.addChild(tileLayer)
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.resizeBoard()
    }
    
    func resizeBoard() {
        if let view = self.view {
            let size = view.frame.size
            
            self.tileSize = min(size.width / CGFloat(board.width), size.height / CGFloat(board.height))
            tileLayer.position = CGPoint(
                x: -tileSize * CGFloat(board.width) / 2,
                y: -tileSize * CGFloat(board.height) / 2)
            
            tileLayer.removeAllChildren()
            addSpritesForTiles(board.tiles)
            updateBoard()
        }
    }
    
    func addSpritesForTiles(tiles: [Tile]) {
        for tile in tiles {
            let size = tileSize-5
            let sprite = SKShapeNode(rectOfSize: CGSizeMake(size, size))
            sprite.fillColor = Theme.unrevealedTileColor
            sprite.lineWidth = 0
            sprite.position = pointForColumn(tile.x, row: tile.y)
            tileLayer.addChild(sprite)
            tile.sprite = sprite
        }
    }
    
    func updateBoard() {
        for tile in board.tiles {
            if tile.isMine && (tile.isRevealed || board.gameOver) {
                if board.isGameWon {
                    if tile.isMarked {
                        (tile.sprite as! SKShapeNode).fillColor = Theme.solvedMineTileColor
                    } else {
                        (tile.sprite as! SKShapeNode).fillColor = Theme.unsolvedMineTileColor
                    }
                } else {
                    (tile.sprite as! SKShapeNode).fillColor = Theme.explodedMineTileColor
                }
            } else if tile.isRevealed {
                (tile.sprite as! SKShapeNode).fillColor = Theme.revealedTileColor
                
                if tile.nbMineAround != 0 {
                    if tile.sprite.children.count == 0 {
                        let detail = SKLabelNode(text: "\(tile.nbMineAround)")
                        detail.fontColor = Theme.fontColorWithMines(tile.nbMineAround)
                        detail.fontSize = tileSize*2/3
                        detail.position = CGPointMake(0, -tileSize/4)
                        tile.sprite.addChild(detail)
                    }
                }
            } else if tile.isMarked {
                (tile.sprite as! SKShapeNode).fillColor = Theme.markedTileColor
            } else {
                (tile.sprite as! SKShapeNode).fillColor = Theme.unrevealedTileColor
            }
        }
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*tileSize + tileSize/2,
            y: CGFloat(row)*tileSize + tileSize/2)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(board.width)*tileSize &&
            point.y >= 0 && point.y < CGFloat(board.height)*tileSize {
                return (true, Int(point.x / tileSize), Int(point.y / tileSize))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let tile = board.getTile(column, y: row) {
                if controller.playOrFlagControl.selectedSegmentIndex == 0 {
                    board.play(tile)
                } else {
                    board.mark(tile)
                }
                updateBoard()
            }
        }
    }
}
