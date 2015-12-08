//
//  GameViewController.swift
//  Twitch
//
//  Created by Trevor Dennie on 11/26/15.
//  Copyright (c) 2015 Trevor Dennie. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size:CGSize(width: 2048, height: 1538))
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
