//
//  GameScene.swift
//  Twitch
//
//  Created by Trevor Dennie on 11/26/15.
//  Copyright (c) 2015 Trevor Dennie. All rights reserved.
//

import SpriteKit
import GameKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let Enemy   : UInt32 = 1
        static let Projectile: UInt32 = 2
        static let Player: UInt32 = 3
    }
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var possibleEnemies = ["meteorSmall.png","meteorBig.png"]
    var gameTimer: NSTimer!
    var bulletTimer: NSTimer!
    var transitionTimer:NSTimer!
    var gameOver = false
    var playerEmitter:SKEmitterNode!
    let playableRect:CGRect
    let playerAnimation: SKAction
    var shootProjectile: SKSpriteNode!
    var projectileSize :CGSize!
    var joystick: Joystick!
    var pauseButton: SKSpriteNode!
    var pauseText: SKLabelNode!
    //var projectileSound: SKAction = SKAction.playSoundFileNamed("Laser.mp3", waitForCompletion: false)
    
    var Highscore = Int()
    
    var score: Int = 0 {
        
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        var playerTextures:[SKTexture] = []
        
        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
        print(playableRect)
        
        for i in 1...6 {
            playerTextures.append(SKTexture(imageNamed: "powerup01_\(i)"))
        }
        
        playerAnimation = SKAction.animateWithTextures(playerTextures, timePerFrame: 0.1)
        
        super.init(size:size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView) {
        
        playBackgroundMusic("04 - The Blinded Forest.mp3")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("pauseGameScene"), name: "PauseGameScene", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPauseText"), name: "ShowPauseText", object: nil)
        
        let HighscoreDefault = NSUserDefaults.standardUserDefaults()
        if (HighscoreDefault.valueForKey("Highscore") != nil){
            
            Highscore = HighscoreDefault.valueForKey("Highscore") as! NSInteger
        }
        else {
            
            Highscore = 0
        }
        
        backgroundColor = UIColor.blackColor()
        
        starfield = SKEmitterNode(fileNamed: "Starfield.sks")!
        //starfield.position = CGPoint(x: CGRectGetMaxX(playableRect) + 500, y: CGRectGetMaxY(playableRect) / 2)
        starfield.position = CGPoint(x: playableRect.width, y: playableRect.height - 200)
        starfield.advanceSimulationTime(30)
        addChild(starfield)
        starfield.zPosition = -1
        
        
        player = SKSpriteNode(imageNamed: "powerup01_1")
        player.name = "thePlayer"
        player.position = CGPoint(x: 150, y: 700)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        //player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.mass = 0.02
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.Projectile
        
        //shootProjectile = SKSpriteNode(imageNamed: "Bullet.png")
        //shootProjectile.size = CGSize(width: player.size.width * 2, height: player.size.height * 2)
        //projectileSize = shootProjectile.size
        //shootProjectile.name = "Projectile"
        //shootProjectile.position = CGPoint(x: CGRectGetMaxX(playableRect) - CGFloat(150), y: CGRectGetMinY(playableRect) + CGFloat(150))
        
        //addChild(shootProjectile)
        
        
        addChild(player)
                
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.verticalAlignmentMode = .Bottom
        scoreLabel.zPosition = 100
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.position = CGPoint(x: CGRectGetMinX(playableRect) + CGFloat(20), y: CGRectGetMinY(playableRect) + CGFloat(20))
        addChild(scoreLabel)
        
        score = 0
        
        pauseButton = SKSpriteNode(imageNamed: "Pause")
        pauseButton.size = CGSize(width: 100.0, height: 100.0)
        pauseButton.name = "Pause"
        pauseButton.position = CGPoint(x: CGRectGetMaxX(playableRect) - CGFloat(150), y: CGRectGetMaxY(playableRect) - CGFloat(80))
        pauseButton.hidden = false
        addChild(pauseButton)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        //gameTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "createEnemy", userInfo: nil, repeats: true)
        
        let waitBeforeSpawn = SKAction.waitForDuration(0.2)
        let runCreateEnemy = SKAction.runBlock { () -> Void in
            self.createEnemy()
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence([waitBeforeSpawn,runCreateEnemy])))
        
        
//        let waitBeforePowerup = SKAction.waitForDuration(5.0)
//        let runSpawnPowerup = SKAction.runBlock { () -> Void in
//            self.spawnPowerup()
//        }
//        
//        runAction(SKAction.repeatActionForever(SKAction.sequence([waitBeforePowerup,runSpawnPowerup])))
        
        
        
        startPlayerAnimation()
        
        playerEmitter = SKEmitterNode(fileNamed: "PlayerTrail")!
        playerEmitter.targetNode = scene
        player.addChild(playerEmitter)
        
        joystick = Joystick()
        joystick.zPosition = 3.0
        //joystick.position = CGPoint(x: CGRectGetMinX(playableRect) + CGFloat(200), y: CGRectGetMinY(playableRect) + CGFloat(150))
        joystick.shouldFadeOut = true
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        print(player.size)
        self.addChild(joystick)
        
        pauseText = SKLabelNode(fontNamed: "Chalkduster")
        //pauseText.horizontalAlignmentMode = .Center
        //pauseText.verticalAlignmentMode = .Center
        pauseText.name = "PauseText"
        pauseText.text = "Game Paused"
        pauseText.fontSize = 50
        pauseText.position = CGPoint(x: playableRect.width/2, y: playableRect.height/2)
        pauseText.hidden = true
        addChild(pauseText)
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.locationInNode(self)
        let node = self.nodeAtPoint(location)
        
        if self.paused {
            self.view!.paused = false
            if pauseText.hidden == false {
                pauseText.hidden = true
                pauseButton.hidden = false
            }
        }
        else {
        
        if location.x < playableRect.size.width / 2 {
            joystick.position = location
        }
        if (node.name == "Pause") {
            
            let pauseTheGame = SKAction.runBlock({ () -> Void in
                self.pauseButton.hidden = true
                self.pauseGame(true)
                self.pauseText.hidden = false
            })
            runAction(pauseTheGame)
            //pauseGame(true)
        }
//        if (node.name == "PauseText") {
//            
//            let resumeTheGame = SKAction.runBlock({ () -> Void in
//                self.pauseText.hidden = true
//                self.pauseGame(false)
//                self.pauseButton.hidden = false
//                
//            })
//            runAction(resumeTheGame)
//        }
        if (location.x > playableRect.size.width / 2) {
            
            spawnBullets()
            
        }
        else if location.x < playableRect.size.width / 2 {
            let bottomLeft = CGPoint(x: CGRectGetMinX(playableRect) , y: CGRectGetMinY(playableRect))
            let topRight = CGPoint(x: CGRectGetMaxX(playableRect), y: CGRectGetMaxY(playableRect))
            
            if location.x <= bottomLeft.x + 300 / 2 {
                joystick.position.x = bottomLeft.x + player.size.width / 2
            }
            if location.x >= topRight.x - 300 / 2{
                joystick.position.x = topRight.x -  player.size.width / 2
            }
            if location.y <= bottomLeft.y + 300 / 2 {
                joystick.position.y = bottomLeft.y + player.size.height / 2
            }
            if location.y >= topRight.y  - 300 / 2 {
                joystick.position.y = topRight.y  - player.size.height / 2
            }
            
            joystick.position = location
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//
        //let location = touch.locationInNode(self)
        
//        if location.x < playableRect.size.width / 2 {
//            let bottomLeft = CGPoint(x: CGRectGetMinX(playableRect) , y: CGRectGetMinY(playableRect))
//            let topRight = CGPoint(x: CGRectGetMaxX(playableRect), y: CGRectGetMaxY(playableRect))
//            
//            if location.x <= bottomLeft.x + 300 / 2 {
//                joystick.position.x = bottomLeft.x + player.size.width / 2
//            }
//            if location.x >= topRight.x - 300 / 2{
//                joystick.position.x = topRight.x -  player.size.width / 2
//            }
//            if location.y <= bottomLeft.y + 300 / 2 {
//                joystick.position.y = bottomLeft.y + player.size.height / 2
//            }
//            if location.y >= topRight.y  - 300 / 2 {
//                joystick.position.y = topRight.y  - player.size.height / 2
//            }
//            
//            joystick.position = location
//        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if joystick.velocity.x != 0 || joystick.velocity.y != 0 {
            
            let proposedPosition = CGPointMake(player.position.x + 0.2 * joystick.velocity.x, player.position.y + 0.2 * joystick.velocity.y)
            
            let bottomLeft = CGPoint(x: CGRectGetMinX(playableRect) , y: CGRectGetMinY(playableRect))
            let topRight = CGPoint(x: CGRectGetMaxX(playableRect), y: CGRectGetMaxY(playableRect))
                
            if proposedPosition.x <= bottomLeft.x + player.size.width/2 {
                    //player.position.x = bottomLeft.x + 0.1 * joystick.velocity.x + player.size.width / 2
                player.position.x = bottomLeft.x + player.size.width/2
            }
            if proposedPosition.x >= topRight.x - player.size.width/2{
                    //player.position.x = topRight.x + 0.1 * joystick.velocity.x -  player.size.width / 2
                player.position.x = topRight.x  - player.size.width/2
            }
            if proposedPosition.y <= bottomLeft.y + player.size.height/2 {
                    //player.position.y = bottomLeft.y + 0.1 * joystick.velocity.y + player.size.height / 2
                player.position.y = bottomLeft.y  + player.size.height/2
            }
            if proposedPosition.y >= topRight.y  - player.size.height/2 {
                    //player.position.y = topRight.y + 0.1 * joystick.velocity.y - player.size.height / 2
                player.position.y = topRight.y  - player.size.height/2
            }
            
            player.position = CGPointMake(player.position.x + 0.2 * joystick.velocity.x, player.position.y + 0.2 * joystick.velocity.y)
            
        }
        
        for node in children {
            if node.position.x < -300 || node.position.x > CGRectGetMaxX(playableRect) + 20 {
                node.removeFromParent()
            }
        }
        
        if !gameOver {
            score += 1
        }
        
    }
    
    func createEnemy() {
        
        let speed: CGFloat
        
        speed = CGFloat(score) / CGFloat(20.0)
        
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: Int(CGRectGetMinY(playableRect)) + 20, highestValue:Int(CGRectGetMaxY(playableRect)) - 20)
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        
        sprite.name = "sprite"
        let randomSize = CGFloat.random(min: 70.0, max: 100.0)
        sprite.size = CGSize(width: randomSize, height: randomSize)
        sprite.position = CGPoint(x: CGRectGetMaxX(playableRect) + 20, y: CGFloat(randomDistribution.nextInt()))
        
        let targetPosition = player.position

        let actionDuration = 5.0
        let offset = targetPosition - sprite.position
        let direction = offset.normalized()
        //let amountToMovePerSec = direction * CGFloat(3000.0)
        let amountToMovePerSec = direction * CGFloat(speed)
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
        sprite.runAction(moveAction)
        
        addChild(sprite)
        
        //sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        
        let speedOfEnemy = GKRandomDistribution(lowestValue: 5, highestValue: 8)
        //sprite.physicsBody?.velocity = CGVector(dx: -2000, dy: 0)
        sprite.physicsBody?.angularVelocity = CGFloat(speedOfEnemy.nextInt())
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        //let rangeToSprite = SKRange(lowerLimit: 1, upperLimit: 10)
        //var distanceConstraint: SKConstraint
        //distanceConstraint = SKConstraint.distance(rangeToSprite, toNode: player)
        //distanceConstraint = SKConstraint.distance(rangeToSprite, toPoint: CGPoint(x: player.position.x + 10, y: player.position.y), inNode: player)
        
        //let rangeForOrientation = SKRange(constantValue:CGFloat(M_2_PI*7))
        //let orientConstraint = SKConstraint.orientToNode(player, offset: rangeForOrientation)
        //sprite.constraints = [orientConstraint, distanceConstraint]
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        print("--------------------------")
        print(contact.bodyA)
        print("**************************")
        print(contact.bodyB)
        
        if (((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.Projectile)) ||
            ((firstBody.categoryBitMask == PhysicsCategory.Projectile) && (secondBody.categoryBitMask == PhysicsCategory.Enemy))){
                
                if (((firstBody.node?.name == "Bullet") && (secondBody.node?.name == "sprite")) ||
                    ((firstBody.node?.name == "sprite") && (secondBody.node?.name == "Bullet"))) {
                        
                        projectileDidCollideWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
                }
        }
        else if ((firstBody.categoryBitMask == PhysicsCategory.Enemy) && (secondBody.categoryBitMask == PhysicsCategory.Player) ||
            (firstBody.categoryBitMask == PhysicsCategory.Player) && (secondBody.categoryBitMask == PhysicsCategory.Enemy)){
                
                if (((firstBody.node?.name == "thePlayer") && (secondBody.node?.name == "sprite")) ||
                    ((firstBody.node?.name == "sprite") && (secondBody.node?.name == "thePlayer"))) {
                        
                        playerDidCollideWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
                }
        }
        
    }
    
    func startPlayerAnimation() {
        player.runAction(SKAction.repeatActionForever(playerAnimation), withKey: "animation")
    }
    
    func projectileDidCollideWithEnemy(projectile:SKSpriteNode, enemy:SKSpriteNode) {
        
        let projectileExplosion = SKEmitterNode(fileNamed: "explosion.sks")!
        projectileExplosion.position = enemy.position
        addChild(projectileExplosion)
        
        projectile.removeFromParent()
        enemy.removeFromParent()
        
        score += 100
    }
    
    func playerDidCollideWithEnemy(player:SKSpriteNode, enemy:SKSpriteNode) {
        
        let ScoreDefault = NSUserDefaults.standardUserDefaults()
        ScoreDefault.setValue(score, forKey: "Score")
        ScoreDefault.synchronize()
        backgroundMusicPlayer.stop()
        
        
        if (score > Highscore){
            
            let HighscoreDefault = NSUserDefaults.standardUserDefaults()
            HighscoreDefault.setValue(score, forKey: "Highscore")
            
        }
        
        let explosion = SKEmitterNode(fileNamed: "explosion.sks")!
        explosion.position = player.position
        addChild(explosion)
        
        transitionTimer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: "transitionScenes", userInfo: nil, repeats: false)
        
        player.removeFromParent()
        enemy.removeFromParent()
        
        gameOver = true
        
    }
    
    func spawnBullets(){
        //runAction(projectileSound)
        
        let Bullet = SKSpriteNode(imageNamed: "Fireball_1_1.png")
        Bullet.name = "Bullet"
        
        var bulletTextures:[SKTexture] = []
        
        for i in 1...6 {
            bulletTextures.append(SKTexture(imageNamed: "Fireball_1_\(i)"))
        }
        
        let bulletAnimation: SKAction
    
        bulletAnimation = SKAction.animateWithTextures(bulletTextures, timePerFrame: 0.1)
        
        Bullet.runAction(SKAction.repeatActionForever(bulletAnimation), withKey: "Bulletanimation")

        
        //Bullet.zPosition = -5
        
        Bullet.position = player.position + CGPoint(x: 105, y: -10)
        Bullet.size = CGSize(width: player.size.width / 2 + 30 , height: player.size.height / 2 + 30)
        
        let action = SKAction.moveToX(playableRect.size.width + 300, duration: 1.0)
        let actionDone = SKAction.removeFromParent()
        Bullet.runAction(SKAction.sequence([action, actionDone]))
        
        //Bullet.physicsBody = SKPhysicsBody(texture: Bullet.texture!, size: CGSize(width: player.size.width / 2, height: player.size.height / 2))
        //Bullet.physicsBody = SKPhysicsBody(texture: Bullet.texture!, size: Bullet.size)
        Bullet.physicsBody = SKPhysicsBody(rectangleOfSize: Bullet.size)
        Bullet.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        Bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        Bullet.physicsBody?.collisionBitMask = PhysicsCategory.Player
        Bullet.physicsBody?.affectedByGravity = false
        Bullet.physicsBody?.dynamic = false
        addChild(Bullet)
        
    }

    
    func transitionScenes() {
        let gameOverScene = GameOverScene(size:size)
        gameOverScene.scaleMode = scaleMode        
        let reveal = SKTransition.fadeWithDuration(0.5)
        view?.presentScene(gameOverScene, transition: reveal)
        
    }
    
    func pauseGame(paused:Bool)
    {
        self.view!.paused = paused
    }
    
    func pauseGameScene() {
        print("pause game")
        self.view?.paused = true
    }
    
    func showPauseText() {
        if self.view?.paused == true {
            pauseText.hidden = false
            print("show text")
        }
    }
    
    
//    func spawnPowerup() {
//        
//    }
    
}

    public extension SKAction {
        
        public class func afterDelay(delay: NSTimeInterval, performAction action: SKAction) -> SKAction {
        return SKAction.sequence([SKAction.waitForDuration(delay), action])
        }
        
        /**
         * Performs a block after the specified delay.
         */
        public class func afterDelay(delay: NSTimeInterval, runBlock block: dispatch_block_t) -> SKAction {
        return SKAction.afterDelay(delay, performAction: SKAction.runBlock(block))
        }
        
        /**
         * Removes the node from its parent after the specified delay.
         */
        public class func removeFromParentAfterDelay(delay: NSTimeInterval) -> SKAction {
            return SKAction.afterDelay(delay, performAction: SKAction.removeFromParent())
        }
        
        /**
         * Creates an action to perform a parabolic jump.
         */
        public class func jumpToHeight(height: CGFloat, duration: NSTimeInterval, originalPosition: CGPoint) -> SKAction {
            return SKAction.customActionWithDuration(duration) {(node, elapsedTime) in
            let fraction = elapsedTime / CGFloat(duration)
            let yOffset = height * 4 * fraction * (1 - fraction)
            node.position = CGPoint(x: originalPosition.x, y: originalPosition.y + yOffset)
            }
        }
}
