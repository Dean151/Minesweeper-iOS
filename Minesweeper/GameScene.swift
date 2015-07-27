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
    
    var _selectedTile: Tile?
    var selectedTile: Tile? {
        get {
            return _selectedTile
        }
        set {
            if newValue != nil {
                newValue!.sprite.runAction(SKAction.sequence([
                SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 10 }),
                SKAction.group([SKAction.scaleTo(Theme.scaleForOveredTile, duration: 0.1), SKAction.fadeAlphaTo(Theme.alphaForOveredTile, duration: 0.1)])
                ]))
                
            }
            
            if _selectedTile != nil {
                _selectedTile!.sprite.runAction(SKAction.sequence([
                    SKAction.group([SKAction.scaleTo(1, duration: 0.1), SKAction.fadeAlphaTo(1, duration: 0.1)]),
                    SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 0 })
                    ]))
            }
            
            _selectedTile = newValue
        }
    }
    
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
        }
    }
    
    func addSpritesForTiles(tiles: [Tile]) {
        for tile in tiles {
            let size = tileSize-5
            let sprite = SKShapeNode(rectOfSize: CGSizeMake(size, size))
            tile.sprite = sprite
            
            sprite.fillColor = Theme.unrevealedTileColor
            sprite.lineWidth = 0
            sprite.position = pointForColumn(tile.x, row: tile.y)
            
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.runAction(
                SKAction.sequence([
                    SKAction.waitForDuration(0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeInWithDuration(0.25),
                        SKAction.scaleTo(1.0, duration: 0.25)
                        ])
                    ]))
            
            tileLayer.addChild(sprite)
        }
    }
    
    func changeTilesWithAnimation(tiles: [Tile]) {
        
        for tile in tiles {
            let actions = SKAction.sequence([
                SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 10}),
                SKAction.scaleTo(Theme.scaleForModifyingTile, duration: 0.05),
                SKAction.customActionWithDuration(0, actionBlock: {
                    (node, time) in
                    if tile.isMine && (tile.isRevealed || self.board.gameOver) {
                        if tile.isMarked {
                            (tile.sprite as! SKShapeNode).fillColor = Theme.solvedMineTileColor
                        } else if tile.isRevealed {
                            (tile.sprite as! SKShapeNode).fillColor = Theme.explodedMineTileColor
                        } else {
                            (tile.sprite as! SKShapeNode).fillColor = Theme.unsolvedMineTileColor
                        }
                    } else if tile.isRevealed {
                        (tile.sprite as! SKShapeNode).fillColor = Theme.revealedTileColor
                        
                        if tile.nbMineAround != 0 {
                            if tile.sprite.children.count == 0 {
                                let detail = SKLabelNode(text: "\(tile.nbMineAround)")
                                detail.fontColor = Theme.fontColorWithMines(tile.nbMineAround)
                                detail.fontSize = self.tileSize*2/3
                                detail.position = CGPointMake(0, -self.tileSize/4)
                                tile.sprite.addChild(detail)
                            }
                        }
                    } else if tile.isMarked {
                        (tile.sprite as! SKShapeNode).fillColor = Theme.markedTileColor
                    } else {
                        (tile.sprite as! SKShapeNode).fillColor = Theme.unrevealedTileColor
                    }
                }),
                SKAction.scaleTo(1, duration: 0.05),
                SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 0 })
                ])
            
            tile.sprite.runAction(actions)
        }
    }
    
    func presentMinesWithAnimation() {
        let minesTiles = board.tiles.filter({ (tile: Tile) in return tile.isMine })
        changeTilesWithAnimation(minesTiles)
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let tile = board.getTile(column, y: row) {
                selectedTile = tile
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if selectedTile != nil {
                if let tile = board.getTile(column, y: row) {
                    if tile != selectedTile {
                        selectedTile = tile
                    }
                } else {
                    selectedTile = nil
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let location = touch.locationInNode(tileLayer)
        
        let (success, column, row) = convertPoint(location)
        if success && !board.gameOver {
            if let tile = board.getTile(column, y: row) {
                let tiles: [Tile]
                if controller.playOrFlagControl.selectedSegmentIndex == 0 {
                    tiles = board.play(tile)
                } else {
                    tiles = board.mark(tile)
                }
                
                tile.sprite.runAction(SKAction.group([SKAction.scaleTo(1.0, duration: 0.1), SKAction.fadeAlphaTo(1, duration: 0.1)])) {
                    if self.board.gameOver {
                        self.changeTilesWithAnimation(tiles)
                        self.presentMinesWithAnimation()
                    } else {
                        self.changeTilesWithAnimation(tiles)
                    }
                    
                }
            }
        }
        
        selectedTile = nil
    }
}
