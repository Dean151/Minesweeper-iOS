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
    var scene: GameScene?
    
    @IBOutlet weak var skView: SKView!
    @IBOutlet weak var playOrFlagControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .Plain, target: self, action: "gameButtonPressed:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "showSettings:")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Settings.isMarkWithLongPressEnabled && Settings.isBottomBarHidden {
            self.playOrFlagControl.selectedSegmentIndex = 0
            self.navigationController!.toolbarHidden = true
        } else {
            self.navigationController!.toolbarHidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (scene != nil) {
            if (Settings.difficulty != self.scene!.board.difficulty) {
                startGame()
            } else {
                scene!.resizeBoard(animated: false)
            }
        } else {
            startGame()
        }
    }
    
    func startGame() {
        if (!Settings.difficulty.difficultyAvailable) {
            Settings.setDifficulty(.Easy)
        }
        newGame( Settings.difficulty )
    }
    
    func newGame(difficulty: GameDifficulty) {
        // Reinit segmented control
        self.playOrFlagControl.selectedSegmentIndex = 0
        
        // Configure the view.
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        let newScene = GameScene(size: skView.frame.size, controller: self, difficulty: difficulty)
        newScene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(newScene)
        scene = newScene
    }
    
    func gameButtonPressed(sender: AnyObject) {
        startGame()
    }
    
    func showSettings(sender: UIBarButtonItem) {
        let viewController = SettingsViewController()
        let navController = UINavigationController(rootViewController: viewController)
        
        if (UI_USER_INTERFACE_IDIOM() == .Pad) {
            let popover = UIPopoverController(contentViewController: navController)
            popover.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: .Any, animated: true)
        } else {
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
}