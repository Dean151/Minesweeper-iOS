//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SpriteKit

enum GameDifficulty {
    case Easy, Medium, Hard
    
    var description: String {
        switch self {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
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
        }
    }
    
    var nbMines: Int {
        switch self {
        case .Easy:
            return 10
        case .Medium:
            return 25
        case .Hard:
            return 40
        }
    }
    
    static var allValues: [GameDifficulty] {
        return [.Easy, .Medium, .Hard]
    }
}

class GameViewController: UIViewController {
    var scene: GameScene!
    var board: Board!
    
    @IBOutlet weak var playOrFlagControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newGame(.Easy)
    }
    
    func newGame(difficulty: GameDifficulty) {
        board = Board(width: difficulty.size.width, height: difficulty.size.height, nbMines: difficulty.nbMines)
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.frame.size, controller: self)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene, transition: SKTransition.pushWithDirection(.Left, duration: 1))
    }
    
    @IBAction func GameButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "New game", message: nil, preferredStyle: .ActionSheet)
        
        for difficulty in GameDifficulty.allValues {
            let opt = UIAlertAction(title: difficulty.description, style: .Default) {
                Void in
                self.newGame(difficulty)
            }
            alert.addAction(opt)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) {
            Void in
        }
        
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        scene.resizeBoard()
    }
}