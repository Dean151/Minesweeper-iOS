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
    @IBOutlet weak var skView: SKView!
    
    @IBOutlet weak var playOrFlagControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canDisplayBannerAds = true
        
        startGame()
    }
    
    func startGame() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let difficulty = userDefault.stringForKey("difficulty") {
            if let gameDifficulty = GameDifficulty(rawValue: difficulty) {
                newGame(gameDifficulty)
            } else {
                newGame(.Easy)
            }
        } else {
            newGame(.Easy)
        }
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
    
    func chooseDifficulty() {
        let alert = UIAlertController(title: "New game", message: nil, preferredStyle: .ActionSheet)
        
        for difficulty in GameDifficulty.allValues {
            let opt = UIAlertAction(title: difficulty.description, style: .Default) {
                Void in
                // Saving difficulty
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(difficulty.rawValue, forKey: "difficulty")
                // Loading new game
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
    
    @IBAction func GameButtonPressed(sender: AnyObject) {
        chooseDifficulty()
    }
    
    override func viewWillLayoutSubviews() {
        scene.resizeBoard()
    }
}