//
//  MainMenuScene.swift
//  Twitch
//
//  Created by Trevor Dennie on 11/26/15.
//  Copyright © 2015 Trevor Dennie. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    var Highscore : Int!
    var shootLabel: SKLabelNode!
    var movementLabel : SKLabelNode!
    var readyLabel:SKLabelNode!
    let playableRect:CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        print(playableRect)
        
        super.init(size:size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        let background = SKSpriteNode(imageNamed:"Ready")
        background.position = CGPoint(x:self.size.width/2 , y:self.size.height/2 - 200)
        self.addChild(background)
        
        shootLabel = SKLabelNode(fontNamed: "Chalkduster")
        shootLabel.fontSize = 45
        shootLabel.text = "Move or tap your finger on the left half of the screen to move your ship"
        shootLabel.horizontalAlignmentMode = .Center
        shootLabel.verticalAlignmentMode = .Top
        shootLabel.zPosition = 100
        shootLabel.fontColor = SKColor.whiteColor()
        shootLabel.position = CGPoint(x: playableRect.width/2, y: playableRect.height - 100)
        addChild(shootLabel)
        
        movementLabel = SKLabelNode(fontNamed: "Chalkduster")
        movementLabel.fontSize = 45
        movementLabel.text = "Tap on the right half of the screen to shoot a projectile"
        movementLabel.horizontalAlignmentMode = .Center
        movementLabel.verticalAlignmentMode = .Top
        movementLabel.zPosition = 100
        movementLabel.fontColor = SKColor.whiteColor()
        movementLabel.position = CGPoint(x: playableRect.width/2, y: playableRect.height - 200)
        addChild(movementLabel)
        
        readyLabel = SKLabelNode(fontNamed: "Chalkduster")
        readyLabel.fontSize = 45
        readyLabel.text = "Tap to begin"
        readyLabel.horizontalAlignmentMode = .Center
        readyLabel.verticalAlignmentMode = .Top
        readyLabel.zPosition = 100
        readyLabel.fontColor = SKColor.whiteColor()
        readyLabel.position = CGPoint(x:self.size.width/2 , y:self.size.height/2 - 300)
        addChild(readyLabel)

        
    }
    
    func sceneTapped() {
        let myScene = GameScene(size:self.size)
        myScene.scaleMode = scaleMode
        //let reveal = SKTransition.doorwayWithDuration(1.5)
        
        let reveal = SKTransition.fadeWithDuration(1.0)
        self.view?.presentScene(myScene, transition: reveal)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    
    
}
