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
    
    var skView: SKView!
    var playOrFlagControl: UISegmentedControl!
    
    
    
    // FIXME: should layout subview to change sizes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating SKView
        skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        
        // Creating Top bar buttons
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Game", style: .Plain, target: self, action: "gameButtonPressed:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "showSettings:")
        
        // Creating segmented toolbar
        playOrFlagControl = UISegmentedControl(items: ["Dig", "Flag"])
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let segmItem = UIBarButtonItem(customView: playOrFlagControl)
        
        self.toolbarItems = [space, segmItem, space]
    }
    
    // FIXME: On iPad, these two functions are not triggered
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Settings.markWithLongPressEnabled && Settings.bottomBarHidden {
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
            Settings.difficulty = .Easy
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