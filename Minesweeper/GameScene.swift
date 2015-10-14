//
//  GameScene.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import AudioToolbox
import SpriteKit
import HexColors

class GameScene: SKScene {
    let maxTileSize: CGFloat = 65
    
    let board: Board
    unowned let controller: GameViewController
    var tileSize: CGFloat
    
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    
    var textures = [SKTexture?](count: 14, repeatedValue: nil)
    
    var timerForMarking: NSTimer!
    
    var _selectedTile: Tile?
    var selectedTile: Tile? {
        get {
            return _selectedTile
        }
        set {
            if timerForMarking != nil {
                timerForMarking.invalidate()
            }
            
            if newValue != nil {
                if Settings.markWithLongPressEnabled {
                    timerForMarking = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: Selector("markSelectedTileWithAnimation"), userInfo: nil, repeats: false)
                }
                
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
        self.board = Board(difficulty: difficulty)
        
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
        
        self.resizeBoard(animated: true)
    }
    
    func resizeBoard(animated animated: Bool) {
        let size = self.size
            
        self.tileSize = min(size.width / CGFloat(board.width), size.height / CGFloat(board.height), maxTileSize)
        tileLayer.position = CGPoint(
            x: -tileSize * CGFloat(board.width) / 2,
            y: -tileSize * CGFloat(board.height) / 2)

        addSpritesForTiles(board.tiles, animated: animated)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if let _ = self.view {
            self.resizeBoard(animated: false)
        }
    }
    
    func addSpritesForTiles(tiles: [Tile], animated: Bool) {
        tileLayer.removeAllChildren()
        
        for tile in tiles {
            let sprite = SKSpriteNode(texture: textureForTile(tile))
            sprite.size = CGSizeMake(tileSize*0.9, tileSize*0.9)
            tile.sprite = sprite
            sprite.position = pointForColumn(tile.x, row: tile.y)
            
            if animated {
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
            }
            
            tileLayer.addChild(sprite)
        }
    }
    
    func changeTilesWithAnimation(tiles: [Tile]) {
        changeTilesWithAnimation(tiles, cliquedTile: nil, randomDelay: false, completion: nil)
    }
    
    func changeTilesWithAnimation(tiles: [Tile], completion: (() -> ())?) {
        changeTilesWithAnimation(tiles, cliquedTile: nil, randomDelay: false) {
            Void in
            if completion != nil {
                completion!()
            }
        }
    }
    
    func changeTilesWithAnimation(tiles: [Tile], cliquedTile: Tile?, completion: (() -> ())?) {
        changeTilesWithAnimation(tiles, cliquedTile: cliquedTile, randomDelay: false) {
            Void in
            if completion != nil {
                completion!()
            }
        }
    }
    
    func changeTilesWithAnimation(tiles: [Tile], cliquedTile: Tile?, randomDelay: Bool, completion: (() -> ())?) {
        let sortedTiles = cliquedTile != nil ? tiles.sort({ (a: Tile, b: Tile) in
                return a.squareDistanceFromTile(cliquedTile!) < b.squareDistanceFromTile(cliquedTile!) }) : tiles
        
        for (index, tile) in sortedTiles.enumerate() {
            
            let timeByMine: NSTimeInterval = 0.8/NSTimeInterval(board.nbMines)
            
            let actions = SKAction.sequence([
                SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 10 }),
                SKAction.waitForDuration((randomDelay ? NSTimeInterval(timeByMine * Double(index)) : 0)) ,
                SKAction.scaleTo(Theme.scaleForModifyingTile, duration: 0.05),
                SKAction.runBlock({ (tile.sprite as! SKSpriteNode).texture = self.textureForTile(tile) }),
                SKAction.scaleTo(1, duration: 0.05),
                SKAction.customActionWithDuration(0, actionBlock: { (node, time) in node.zPosition = 0 })
                ])
            
            tile.sprite.runAction(actions) {
                void in
                if completion != nil {
                    if tile == sortedTiles.last {
                        completion!()
                    }
                }
            }
        }
    }
    
    func markSelectedTileWithAnimation() {
        if selectedTile != nil {
            let tiles = board.mark(selectedTile!)
            selectedTile = nil
            
            for tile in tiles {
                let actions = SKAction.sequence([
                    SKAction.runBlock({
                        (tile.sprite as! SKSpriteNode).texture = self.textureForTile(tile)
                        tile.sprite.zPosition = 10
                        tile.sprite.setScale(Theme.scaleForMarkingTile)
                        tile.sprite.alpha = Theme.alphaForOveredTile
                    }),
                    SKAction.group([
                        SKAction.scaleTo(1, duration: 0.2),
                        SKAction.fadeAlphaTo(1, duration: 0.2)
                    ]),
                    SKAction.runBlock({
                        tile.sprite.zPosition = 0
                    })
                ])
                    
                tile.sprite.runAction(actions)
            }
        }
    }
    
    func presentMinesWithAnimation(cliquedTile: Tile) {
        let minesTiles = board.tiles.filter({ (tile: Tile) in return tile.isMine })
        
        changeTilesWithAnimation(minesTiles, cliquedTile: cliquedTile, randomDelay: !board.isGameWon) { Void in self.showGameOverScreen() }
    }
    
    func showGameOverScreen() {
        runAction(SKAction.waitForDuration(0.5)) {
            Void in
            if self.board.isGameWon {
                // TODO Add game over screen
            } else {
                
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(tileLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let tile = board.getTile(column, y: row) {
                selectedTile = tile
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(tileLayer)
        
        let (success, _, _) = convertPoint(location)
        if success && !board.gameOver {
            if let tile = selectedTile {
                let tiles: [Tile]
                if controller.playOrFlagControl.selectedSegmentIndex == 0 {
                    tiles = board.play(tile)
                } else {
                    tiles = board.mark(tile)
                }
                
                tile.sprite.runAction(SKAction.group([SKAction.scaleTo(1.0, duration: 0.1), SKAction.fadeAlphaTo(1, duration: 0.1)])) {
                    if self.board.gameOver {
                        if !self.board.isGameWon {
                            if Settings.vibrationEnabled {
                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                        }
                        self.changeTilesWithAnimation(tiles, cliquedTile: tile) {
                            Void in self.presentMinesWithAnimation(tile)
                        }
                    } else {
                        self.changeTilesWithAnimation(tiles)
                    }
                    
                }
            }
        }
        
        selectedTile = nil
    }
    
    func textureForTile(tile: Tile) -> SKTexture {
        var mineType = 13
        
        // Finding witch texture we need
        if tile.isMine && (tile.isRevealed || tile.board.gameOver) {
            if tile.isMarked {
                mineType = 10
            } else if tile.isRevealed {
                mineType = 11
            } else {
                mineType = 12
            }
        } else if tile.isRevealed {
            mineType = tile.nbMineAround
        } else if tile.isMarked {
            mineType = 9
        }
        
        // Returning the texture if already generated
        if textures[mineType] != nil {
            return textures[mineType]!
        }
        
        // Generating texture otherwise
        let size = tileSize * UIScreen.mainScreen().scale
        let sprite = SKShapeNode(rectOfSize: CGSizeMake(size*0.9, size*0.9))
        sprite.lineWidth = 0
        
        switch (mineType) {
        case 0:
            sprite.fillColor = Theme.revealedTileColor
        case 1,2,3,4,5,6,7,8:
            sprite.fillColor = Theme.revealedTileColor
            let detail = SKLabelNode(text: "\(tile.nbMineAround)")
            detail.fontColor = Theme.fontColorWithMines(tile.nbMineAround)
            detail.fontSize = size*2/3
            detail.position = CGPointMake(0, -size/4)
            sprite.addChild(detail)
        case 9:
            sprite.fillColor = Theme.markedTileColor
        case 10:
            sprite.fillColor = Theme.solvedMineTileColor
        case 11:
            sprite.fillColor = Theme.explodedMineTileColor
        case 12:
            sprite.fillColor = Theme.unsolvedMineTileColor
        default:
            sprite.fillColor = Theme.unrevealedTileColor
        }
        
        // Saving the texture
        let texture = self.view!.textureFromNode(sprite)
        textures[mineType] = texture
        
        // Returning the texture
        return texture!
    }
}
