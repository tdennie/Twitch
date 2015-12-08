//
//  GameOverScene.swift
//  Twitch
//
//  Created by Trevor Dennie on 11/27/15.
//  Copyright © 2015 Trevor Dennie. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var Highscore : Int!
    var scoreLabel: SKLabelNode!
    var highScoreLabel : SKLabelNode!
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
        
        let background = SKSpriteNode(imageNamed:"GameOver")
        background.position = CGPoint(x:self.size.width/2, y:self.size.height/2)
        self.addChild(background)
        
        let ScoreDefault = NSUserDefaults.standardUserDefaults()
        let Score = ScoreDefault.valueForKey("Score") as! NSInteger
        NSLog("\(Score)")
        
        let HighscoreDefault = NSUserDefaults.standardUserDefaults()
        Highscore = HighscoreDefault.valueForKey("Highscore") as! NSInteger
        
        
        //HighScoreLbl = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width / 3, height: 30))
        //HighScoreLbl.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.width / 2)
        //HighScoreLbl.text = "\(Highscore)"
        //self.view?.addSubview(HighScoreLbl)
        
        highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        highScoreLabel.fontSize = 45
        highScoreLabel.text = "Your HighScore: \(Highscore)"
        highScoreLabel.horizontalAlignmentMode = .Center
        highScoreLabel.verticalAlignmentMode = .Top
        highScoreLabel.zPosition = 100
        highScoreLabel.fontColor = SKColor.whiteColor()
        highScoreLabel.position = CGPoint(x: playableRect.width/2, y: playableRect.height + 50)
        addChild(highScoreLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 45
        scoreLabel.text = "Your Score: \(Score)"
        scoreLabel.horizontalAlignmentMode = .Center
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.zPosition = 100
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: playableRect.width/2, y: playableRect.height + 100)
        addChild(scoreLabel)

        NSLog("\(Highscore)")

        
    }
    
    func sceneTapped() {
        let myScene = GameScene(size:self.size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(myScene, transition: reveal)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    
    
}
