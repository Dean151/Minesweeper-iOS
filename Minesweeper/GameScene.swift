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
    let board: Board
    unowned let controller: GameViewController
    var tileSize: CGFloat
    
    let gameLayer = SKNode()
    let tileLayer = SKNode()
    let scoreLayer = SKNode()
    
    var textures = [SKTexture?](repeating: nil, count: 16)
    
    var timerForMarking: Timer!
    
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
                if Settings.sharedInstance.markWithLongPressEnabled {
                    timerForMarking = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(GameScene.markSelectedTileWithAnimation), userInfo: nil, repeats: false)
                }
                
                newValue!.sprite.run(SKAction.sequence([
                SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in node.zPosition = 10 }),
                SKAction.group([SKAction.scale(to: Theme.scaleForOveredTile, duration: 0.1), SKAction.fadeAlpha(to: Theme.alphaForOveredTile, duration: 0.1)])
                ]))
            }
            
            if _selectedTile != nil {
                _selectedTile!.sprite.run(SKAction.sequence([
                    SKAction.group([SKAction.scale(to: 1, duration: 0.1), SKAction.fadeAlpha(to: 1, duration: 0.1)]),
                    SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in node.zPosition = 0 })
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
        gameLayer.addChild(scoreLayer)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.resizeBoard(animated: true)
    }
    
    func resizeBoard(animated: Bool) {
        let size = CGSize(width: self.size.width - Theme.minSideBorder, height: self.size.height - Theme.minSideBorder)
            
        self.tileSize = min(size.width / CGFloat(board.width), size.height / CGFloat(board.height), Theme.maxTileSize)
        tileLayer.position = CGPoint(
            x: -tileSize * CGFloat(board.width) / 2,
            y: -tileSize * CGFloat(board.height) / 2)

        addSpritesForTiles(board.tiles, animated: animated)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if let _ = self.view {
            self.resizeBoard(animated: false)
        }
    }
    
    func addSpritesForTiles(_ tiles: [Tile], animated: Bool) {
        tileLayer.removeAllChildren()
        
        for tile in tiles {
            let sprite = SKSpriteNode(texture: textureForTile(tile))
            sprite.size = CGSize(width: tileSize*0.9, height: tileSize*0.9)
            tile.sprite = sprite
            sprite.position = pointForColumn(tile.x, row: tile.y)
            
            if animated {
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            
            sprite.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.25, withRange: 0.5),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.25),
                        SKAction.scale(to: 1.0, duration: 0.25)
                        ])
                    ]))
            }
            
            tileLayer.addChild(sprite)
        }
    }
    
    func changeTilesWithAnimation(_ tiles: [Tile]) {
        changeTilesWithAnimation(tiles, cliquedTile: nil, randomDelay: false, completion: nil)
    }
    
    func changeTilesWithAnimation(_ tiles: [Tile], completion: (() -> ())?) {
        changeTilesWithAnimation(tiles, cliquedTile: nil, randomDelay: false) {
            Void in
            if completion != nil {
                completion!()
            }
        }
    }
    
    func changeTilesWithAnimation(_ tiles: [Tile], cliquedTile: Tile?, completion: (() -> ())?) {
        changeTilesWithAnimation(tiles, cliquedTile: cliquedTile, randomDelay: false) {
            Void in
            if completion != nil {
                completion!()
            }
        }
    }
    
    func changeTilesWithAnimation(_ tiles: [Tile], cliquedTile: Tile?, randomDelay: Bool, completion: (() -> ())?) {
        let sortedTiles = cliquedTile != nil ? tiles.sorted(by: { (a: Tile, b: Tile) in
                return a.squareDistanceFromTile(cliquedTile!) < b.squareDistanceFromTile(cliquedTile!) }) : tiles
        
        for (index, tile) in sortedTiles.enumerated() {
            
            let timeByMine: TimeInterval = 0.8/TimeInterval(board.nbMines)
            
            let actions = SKAction.sequence([
                SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in node.zPosition = 10 }),
                SKAction.wait(forDuration: (randomDelay ? TimeInterval(timeByMine * Double(index)) : 0)) ,
                SKAction.scale(to: Theme.scaleForModifyingTile, duration: 0.05),
                SKAction.run({ (tile.sprite as! SKSpriteNode).texture = self.textureForTile(tile) }),
                SKAction.scale(to: 1, duration: 0.05),
                SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in node.zPosition = 0 })
                ])
            
            tile.sprite.run(actions, completion: {
                void in
                if completion != nil {
                    if tile == sortedTiles.last {
                        completion!()
                    }
                }
            }) 
        }
    }
    
    func markSelectedTileWithAnimation() {
        guard let selectedTile = self.selectedTile else { return }
        self.selectedTile = nil
        
        let tiles = board.mark(selectedTile)
        for tile in tiles {
            let actions = SKAction.sequence([
                SKAction.run({
                    (tile.sprite as! SKSpriteNode).texture = self.textureForTile(tile)
                    tile.sprite.zPosition = 10
                    tile.sprite.setScale(Theme.scaleForMarkingTile)
                    tile.sprite.alpha = Theme.alphaForOveredTile
                }),
                SKAction.group([
                    SKAction.scale(to: 1, duration: 0.2),
                    SKAction.fadeAlpha(to: 1, duration: 0.2)
                    ]),
                SKAction.run({
                    tile.sprite.zPosition = 0
                })
            ])
            
            tile.sprite.run(actions)
        }
    }
    
    func presentMinesWithAnimation(_ cliquedTile: Tile) {
        let minesTiles = board.tiles.filter({ (tile: Tile) in return tile.isMine })
        
        // Creating textures for win and lost
        if textures[14] == nil || textures[15] == nil {
            _ = textureForGameOver(true)
            _ = textureForGameOver(false)
        }
        
        changeTilesWithAnimation(minesTiles, cliquedTile: cliquedTile, randomDelay: !board.isGameWon) { Void in
            self.showGameOverScreen()
        }
    }
    
    func showGameOverScreen() {
        run(SKAction.wait(forDuration: 0.1), completion: {
            Void in
            if self.board.isGameWon {
                let scoreNode = SKSpriteNode(texture: self.textureForGameOver(true))
                scoreNode.alpha = 0
                
                let gameWonLabel = SKLabelNode(fontNamed: "Noteworthy")
                gameWonLabel.text = NSLocalizedString("CONGRATULATIONS!", comment: "").uppercased()
                gameWonLabel.fontColor = Theme.solvedMineTileColor
                gameWonLabel.position = CGPoint(x: 0, y: 30)
                scoreNode.addChild(gameWonLabel)
                
                let scoreLabel = SKLabelNode(fontNamed: "Noteworthy-Light")
                scoreLabel.text = NSLocalizedString("SCORE", comment: "") + ": \(self.board.score!.formattedHoursMinutesSecondsMilliseconds)"
                scoreLabel.fontColor = UIColor.black
                scoreLabel.fontSize = 16
                scoreLabel.position = CGPoint(x: 0, y: -10)
                scoreNode.addChild(scoreLabel)
                
                let playLabel = SKLabelNode(fontNamed: "Noteworthy-Light")
                playLabel.name = "play"
                playLabel.text = NSLocalizedString("PLAY_AGAIN", comment: "").uppercased()
                playLabel.fontColor = Theme.unrevealedTileColor
                playLabel.fontSize = 18
                playLabel.position = CGPoint(x: -50, y: -50)
                scoreNode.addChild(playLabel)
                
                let shareLabel = SKLabelNode(fontNamed: "Noteworthy-Light")
                shareLabel.name = "share"
                shareLabel.text = NSLocalizedString("SHARE", comment: "").uppercased()
                shareLabel.fontColor = Theme.unrevealedTileColor
                shareLabel.fontSize = 18
                shareLabel.position = CGPoint(x: 50, y: -50)
                scoreNode.addChild(shareLabel)
                
                // Make the game won layout appears
                scoreNode.setScale(0.7)
                self.scoreLayer.addChild(scoreNode)
                let fadeIn = SKAction.group([SKAction.fadeIn(withDuration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
                scoreNode.run(fadeIn)
            } else {
                let scoreNode = SKSpriteNode(texture: self.textureForGameOver(false))
                scoreNode.alpha = 0
                
                let gameLostLabel = SKLabelNode(fontNamed: "Noteworthy")
                gameLostLabel.text = NSLocalizedString("TOO_BAD!", comment: "").uppercased()
                gameLostLabel.fontColor = Theme.explodedMineTileColor
                gameLostLabel.position = CGPoint(x: 0, y: 5)
                scoreNode.addChild(gameLostLabel)
                
                let playLabel = SKLabelNode(fontNamed: "Noteworthy-Light")
                playLabel.name = "play"
                playLabel.text = NSLocalizedString("PLAY_AGAIN", comment: "").uppercased()
                playLabel.fontColor = Theme.unrevealedTileColor
                playLabel.fontSize = 18
                playLabel.position = CGPoint(x: 0, y: -30)
                scoreNode.addChild(playLabel)
                
                // Make the game over layout appears
                scoreNode.setScale(0.7)
                self.scoreLayer.addChild(scoreNode)
                let fadeIn = SKAction.group([SKAction.fadeIn(withDuration: 0.3), SKAction.scale(to: 1, duration: 0.3)])
                scoreNode.run(fadeIn)
            }
        }) 
    }
    
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*tileSize + tileSize/2,
            y: CGFloat(row)*tileSize + tileSize/2)
    }
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(board.width)*tileSize &&
            point.y >= 0 && point.y < CGFloat(board.height)*tileSize {
                return (true, Int(point.x / tileSize), Int(point.y / tileSize))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: tileLayer)
        
        if board.gameOver {
            return
        }
        
        let (success, column, row) = convertPoint(location)
        if success {
            if let tile = board.getTile(column, y: row) {
                selectedTile = tile
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: tileLayer)
        
        if board.gameOver {
            return
        }
        
        let (success, column, row) = convertPoint(location)
        if success && selectedTile != nil {
            if let tile = board.getTile(column, y: row) {
                if tile != selectedTile {
                    selectedTile = tile
                } else {
                    if Settings.sharedInstance.markWithDeepPressEnabled {
                        // Deep Press Handling
                        // If 3DTouch not available, we use majorRadius to simulate it !
                        if #available(iOS 9.0, *) {
                            if self.controller.traitCollection.forceTouchCapability == .available {
                                if touch.force > 0.8*touch.maximumPossibleForce {
                                    self.markSelectedTileWithAnimation()
                                }
                            } else {
                                if touch.majorRadius - touch.majorRadiusTolerance > 30 {
                                    self.markSelectedTileWithAnimation()
                                }
                            }
                        } else {
                            if touch.majorRadius - touch.majorRadiusTolerance > 30 {
                                self.markSelectedTileWithAnimation()
                            }
                        }
                    }
                }
            } else {
                selectedTile = nil
            }
        } else {
            selectedTile = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        if board.gameOver {
            let location = touch.location(in: scoreLayer)
            let node = scoreLayer.atPoint(location)
            guard let name = node.name else { return }
            
            switch name {
            case "play":
                controller.startGame()
            case "share":
                let pos = self.convertPoint(toView: node.position)
                let size = node.frame
                let rect = CGRect(x: pos.x - size.width/2, y: pos.y - size.height, width: size.width, height: size.height)
                
                controller.shareGame(rect)
            default:
                break
            }
            
            return
        }
        
        let location = touch.location(in: tileLayer)
        
        let (success, _, _) = convertPoint(location)
        if success && !board.gameOver {
            if let tile = selectedTile {
                let tiles: [Tile]
                if controller.playOrFlagControl.selectedSegmentIndex == 0 {
                    tiles = board.play(tile)
                } else {
                    tiles = board.mark(tile)
                }
                
                tile.sprite.run(SKAction.group([SKAction.scale(to: 1.0, duration: 0.1), SKAction.fadeAlpha(to: 1, duration: 0.1)]), completion: {
                    if self.board.gameOver {
                        if !self.board.isGameWon {
                            if Settings.sharedInstance.vibrationEnabled && UIDevice.current.model == "iPhone" {
                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                        }
                        self.changeTilesWithAnimation(tiles, cliquedTile: tile) {
                            Void in self.presentMinesWithAnimation(tile)
                        }
                    } else {
                        self.changeTilesWithAnimation(tiles)
                    }
                }) 
            }
        }
        
        selectedTile = nil
    }
    
    func textureForTile(_ tile: Tile) -> SKTexture {
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
        let size = tileSize * UIScreen.main.scale
        let sprite = SKShapeNode(rectOf: CGSize(width: size*0.9, height: size*0.9))
        sprite.lineWidth = 0
        
        switch (mineType) {
        case 0:
            sprite.fillColor = Theme.revealedTileColor
        case 1,2,3,4,5,6,7,8:
            sprite.fillColor = Theme.revealedTileColor
            let detail = SKLabelNode(text: "\(tile.nbMineAround)")
            detail.fontColor = Theme.fontColorWithMines(tile.nbMineAround)
            detail.fontSize = size*2/3
            detail.position = CGPoint(x: 0, y: -size/4)
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
        let texture = self.view!.texture(from: sprite)
        textures[mineType] = texture
        
        // Returning the texture
        return texture!
    }
    
    func textureForGameOver(_ winned: Bool) -> SKTexture {
        if let tex = textures[winned ? 14 : 15] {
            return tex
        }
        
        let node = SKShapeNode(rect: winned ? Theme.gameWonSize : Theme.gameLostSize, cornerRadius: 10)
        node.fillColor = Theme.gameOverBackgroundColor
        node.strokeColor = Theme.gameOverBorderColor
        let texture = self.view!.texture(from: node)
        textures[winned ? 14 : 15] = texture
        return texture!
    }
}

extension TimeInterval {
    var formattedHoursMinutesSecondsMilliseconds: String {
        if Int(self) > 59 {
            return String(format:"%dmin %02ds %03dms", minute , second, millisecond)
        } else {
            return String(format:"%02ds %03dms", second, millisecond)
        }
    }
    var minute: Int {
        return Int((self/60.0).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(self.truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000) )
    }
}
