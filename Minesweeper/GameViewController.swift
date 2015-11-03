//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Thomas Durand on 23/07/2015.
//  Copyright (c) 2015 Thomas Durand. All rights reserved.
//

import Foundation
import SnapKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene?
    
    var skView: SKView!
    var playOrFlagControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.backgroundColor
        
        // Creating SKView
        skView = SKView(frame: self.view.frame)
        skView.backgroundColor = Theme.backgroundColor
        self.view.addSubview(skView)
        skView.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
        
        self.navigationItem.title = NSLocalizedString("MINESWEEPER", comment: "")
        
        // Creating Top bar buttons
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NEW_GAME", comment: ""), style: .Plain, target: self, action: "gameButtonPressed:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: "showSettings:")
        
        // Creating segmented toolbar
        playOrFlagControl = UISegmentedControl(items: [NSLocalizedString("DIG", comment: ""), NSLocalizedString("MARK", comment: "")])
        playOrFlagControl.setWidth(100, forSegmentAtIndex: 0)
        playOrFlagControl.setWidth(100, forSegmentAtIndex: 1)
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        let segmItem = UIBarButtonItem(customView: playOrFlagControl)
        
        self.toolbarItems = [space, segmItem, space]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.performSettingsChanges()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.performDifficultyChanges()
    }
    
    func performSettingsChanges() {
        if (Settings.sharedInstance.markWithLongPressEnabled || Settings.sharedInstance.markWithDeepPressEnabled) && Settings.sharedInstance.bottomBarHidden {
            self.playOrFlagControl.selectedSegmentIndex = 0
            self.navigationController!.toolbarHidden = true
        } else {
            self.navigationController!.toolbarHidden = false
        }
    }
    
    func performDifficultyChanges() {
        if (scene != nil) {
            if (Settings.sharedInstance.difficulty != self.scene!.board.difficulty) {
                startGame()
            }
        } else {
            startGame()
        }
    }
    
    func startGame() {
        if (!Settings.sharedInstance.difficulty.difficultyAvailable) {
            Settings.sharedInstance.difficulty = .Easy
        }
        newGame( Settings.sharedInstance.difficulty )
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
    
    func shareGame(rect: CGRect) {
        if let board = scene?.board {
            let shareText: String = String.localizedStringWithFormat(NSLocalizedString("SHARE_TEXT", comment: ""), board.score!.formattedHoursMinutesSecondsMilliseconds, board.difficulty.shortDescription)
            let shareView = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            if let popover = shareView.popoverPresentationController {
                popover.sourceView = skView
                popover.sourceRect = skView.convertRect(rect, fromView: self.view)
            }
            self.presentViewController(shareView, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        performSettingsChanges()
        
        if let scene = self.scene {
            scene.size = self.skView.frame.size
        }
    }
    
    func showSettings(sender: UIBarButtonItem) {
        let viewController = SettingsViewController()
        viewController.parentVC = self
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .Popover
        
        if let popover = navController.popoverPresentationController {
            popover.barButtonItem = sender
        }
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
}