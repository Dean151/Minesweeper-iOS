//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var board: Board!
    
    @IBOutlet weak var playOrFlagControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        board = Board(width: 8, height: 12, nbMines: 10)
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.frame.size, controller: self)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
    }
    
    override func viewWillLayoutSubviews() {
        scene.resizeBoard()
    }
}