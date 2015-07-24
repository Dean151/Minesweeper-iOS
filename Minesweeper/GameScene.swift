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
    
    init(size: CGSize, controller: GameViewController) {
        self.controller = controller
        self.board = controller.board
        self.tileSize = 10
        super.init(size: size)
        
        // Setting up the scene
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = UIColor(hexString: "#ECF0F1")
        addChild(gameLayer)
        
        gameLayer.addChild(tileLayer)
        
        resizeBoard()
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
        }
    }
    
    func addSpritesForTiles(tiles: [Tile]) {
        for tile in tiles {
            let size = tileSize-5
            let sprite = SKShapeNode(rectOfSize: CGSizeMake(size, size))
            sprite.fillColor = UIColor(hexString: "#337ab7")
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
                        (tile.sprite as! SKShapeNode).fillColor = UIColor(hexString: "#5cb85c")
                    } else {
                        (tile.sprite as! SKShapeNode).fillColor = UIColor(hexString: "#5bc0de")
                    }
                } else {
                    (tile.sprite as! SKShapeNode).fillColor = UIColor(hexString: "#d9534f")
                }
            } else if tile.isRevealed {
                (tile.sprite as! SKShapeNode).fillColor = UIColor.whiteColor()
                
                if tile.nbMineAround != 0 {
                    let detail = SKLabelNode(text: "\(tile.nbMineAround)")
                    detail.fontColor = UIColor.blackColor()
                    detail.position = CGPointZero
                    tile.sprite.addChild(detail)
                }
            } else if tile.isMarked {
                (tile.sprite as! SKShapeNode).fillColor = UIColor(hexString: "#f0ad4e")
            } else {
                (tile.sprite as! SKShapeNode).fillColor = UIColor(hexString: "#337ab7")
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
