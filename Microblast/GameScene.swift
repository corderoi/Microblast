//
//  GameScene.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import SpriteKit
import Foundation

// GameScene /////////////////////////////////////////////////////////////////

class GameScene : SKScene, SKPhysicsContactDelegate
{
    let wCellNode = SKSpriteNode(imageNamed: "wcell")
    
    var tick: (() -> ())?
    var frameTick: (() -> ())?
    var collisionHappened: (() -> ())?
    
    var startMusic: (() -> ())?
    var stopMusic: (() -> ())?
    
    var lastTick: NSDate?
    var tickLengthMillis: NSTimeInterval!
    
    var previewNode: SKSpriteNode?
    var pauseOverlay: SKSpriteNode!
    
    var virusNodes: [SKSpriteNode]!
    var antibodyNodes: [SKSpriteNode]!
    var antigenNodes: [SKSpriteNode]!
    var energyNodes: [SKSpriteNode]!
    var chargeNode: SKSpriteNode?
    var lNode: SKSpriteNode!
    
    var spacedTicksEnabled: Bool = false
    
    var virusMoveDuration: NSTimeInterval!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    func playSound(sound:String) {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        virusNodes = [SKSpriteNode]()
        antibodyNodes = [SKSpriteNode]()
        antigenNodes = [SKSpriteNode]()
        energyNodes = [SKSpriteNode]()
        lNode = SKSpriteNode()
        chargeNode = nil
        lastTick = nil
        pauseOverlay = SKSpriteNode()
        
        virusMoveDuration = SpeedConfig[0].moveDuration
        tickLengthMillis = SpeedConfig[0].tickLength
        
        /*let bgOverlayNode = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: size.width, height: size.height))
        bgOverlayNode.alpha = 0.1
        bgOverlayNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgOverlayNode.zPosition = bgNode.zPosition + 1*/
        
        /*let alphaFade = SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeAlphaTo(0.0, duration: 5), SKAction.fadeAlphaTo(0.1, duration: 5)]))
        
        bgOverlayNode.runAction(alphaFade)*/
        //addChild(bgOverlayNode)
    }
    
    override func didMoveToView(view: SKView)
    {
        // DEBUG
        //println("titleScreen()")
        
        //titleScreen()
        
        // Initialize field
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        /*runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(createLevelScene),
                SKAction.waitForDuration(5.0)])))*/
    }
    
    func setUpCampaign()
    {
        backgroundColor = SKColor.redColor()
        let bgNode = SKSpriteNode(imageNamed: "bg.jpg")
        bgNode.size = size
        bgNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bgNode.zPosition = -999
        addChild(bgNode)
    }
    
    func endCampaign()
    {
        self.removeAllChildren()
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        if (lastTick == nil) {
            return
        }
        
        // Frame-by-frame
        frameTick?()
        
        if spacedTicksEnabled {
            var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
            
            // DEBUG
            //println("timePassed: \(timePassed)")
            
            if timePassed > tickLengthMillis {
                lastTick = NSDate()
                tick?()
            }
        }
    }
    
    func startTicking() {
        // DEBUG
        //println("Starting ticking")
        
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func pauseScene()
    {
        pauseOverlay = SKSpriteNode(color: SKColor.blackColor(), size: size)
        pauseOverlay.alpha = 0.5
        pauseOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseOverlay.zPosition = 899
        addChild(pauseOverlay)
        paused = true
    }
    
    func unpauseScene()
    {
        pauseOverlay.removeFromParent()
        paused = false
    }
    
    func startSpacedTicks() {
        spacedTicksEnabled = true
    }
    
    func stopSpacedTicks() {
        spacedTicksEnabled = false
    }
    
    func dissolvePreview(game: Game)
    {
        if let myPreviewNode = previewNode {
            myPreviewNode.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.5) , SKAction.removeFromParent()]))
        }
    }
    
    func addPlayer(game: Game, player: WhiteBloodCell)
    {
        let renderCoords = renderCoordinates(player.positionX, player.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        wCellNode.position = CGPoint(x: renderCoords.0, y: renderCoords.1)
        wCellNode.size = PlayerSize
        wCellNode.zRotation = 0.0
        
        bestowPhysics(wCellNode, radius: PlayerSize.width / 2, category: PhysicsCategory.WCell, contact: PhysicsCategory.Antigen | PhysicsCategory.Virus)
        
        // DEBUG
        //println("Player position: \(wCellNode.position)")
        
        wCellNode.zPosition = 100
        addChild(wCellNode)
        
        /*lNode = SKSpriteNode(imageNamed: "line")
        lNode.position = wCellNode.position
        lNode.zPosition = wCellNode.zPosition + 1
        lNode.zRotation = wCellNode.zRotation
        lNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        lNode.alpha = 0.25
        
        addChild(lNode)*/
    }
    
    func redrawPlayer(game: Game, player: WhiteBloodCell)
    {
        let playerNode = wCellNode

        let renderCoords = renderCoordinates(player.positionX, player.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        playerNode.position = CGPoint(x: renderCoords.0, y: renderCoords.1)
        //lNode.position = playerNode.position
        
        let angle = Double(atan(player.angle.y / player.angle.x)) + M_PI_2
        let correctedAngle = player.angle.x >= 0 ? angle + M_PI : angle
        playerNode.zRotation = CGFloat(correctedAngle)
        //lNode.zRotation = playerNode.zRotation
    }
    
    func removePlayer(callback: (() -> ()))
    {
        let rumbleNode = SKSpriteNode(imageNamed: "rumble-1")
        rumbleNode.position = wCellNode.position
        
        wCellNode.removeFromParent()
        addChild(rumbleNode)
        playSound("rumble.wav")
        
        var textures = [SKTexture]()
        
        for i in 1 ... 3 {
            textures.append(SKTexture(imageNamed: "rumble-\(i)"))
        }
        
        rumbleNode.runAction(SKAction.sequence([SKAction.animateWithTextures(textures, timePerFrame: SpeedConfig[0].virusAnimationSpeed), SKAction.fadeOutWithDuration(0), SKAction.waitForDuration(LevelPauseDuration), SKAction.removeFromParent()]), callback)
    }
    
    func addAntibody(antibody: Antibody) {
        // DEBUG
        //println("Adding antibody")

        let antibodyNode = SKSpriteNode(imageNamed: "antibody")
        
        antibodyNode.position = wCellNode.position
        
        let angle = Double(atan(antibody.direction.y / antibody.direction.x)) + M_PI_2
        let correctedAngle = antibody.direction.x >= 0 ? angle + M_PI : angle
        /*if antibody.direction.x >= 0 {
            angle = M_PI_2 * 3
        }*/
        
        antibodyNode.zRotation = CGFloat(correctedAngle)
        
        bestowPhysics(antibodyNode, radius: antibodyNode.size.width / 2, category: PhysicsCategory.Antibody, contact: PhysicsCategory.Virus | PhysicsCategory.Antigen | PhysicsCategory.OuterBound, precise: true)
        
        // DEBUG
        //antibodyNode.zPosition = 1000
        //println("\(antibodyNode.physicsBody)")
        
        addChild(antibodyNode)
        antibodyNodes.append(antibodyNode)
        
        // DEBUG
        /*let direction = antibody.direction.normalized()
        
        let shootAmount = direction * 1000
        
        let destination = shootAmount + antibodyNode.position
        
        let actionMove = SKAction.moveTo(destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        antibodyNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))*/
        
        //playSound("laser.wav") // todo
    }
    
    func redrawAntibodies(game: Game) {
        if let player = game.field.player {
            for i in 0 ..< player.antibodies.count {
                if let antibody = game.field.player?.antibodies[i] {
                    let gameCoords = (antibody.positionX, antibody.positionY)
                    let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                    let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                    antibodyNodes[i].position = destination
                    // DEBUG
                    //let actionMove = SKAction.moveTo(destination, duration: 0.05)
                    //antibodyNodes[i].runAction(SKAction.sequence([actionMove]))
                }
            }
        }
    }
    
    func removeAntibody(whichAntibody: Int)
    {
        // DEBUG
        //println("Removing antibody at index \(whichAntibody)")
        
        antibodyNodes[whichAntibody].removeFromParent()
        antibodyNodes.removeAtIndex(whichAntibody)
    }
    
    func bestowPhysics(body: SKSpriteNode, radius: CGFloat, category: UInt32, contact: UInt32, precise: Bool = false)
    {
        body.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        if let myPhysicsBody = body.physicsBody {
            myPhysicsBody.dynamic = true
            myPhysicsBody.categoryBitMask = category
            myPhysicsBody.contactTestBitMask = contact
            myPhysicsBody.collisionBitMask = PhysicsCategory.None
            if precise {
                myPhysicsBody.usesPreciseCollisionDetection = true
            }
            // DEBUG
            //println("Physics bestowed! Radius \(radius)")
        } else {
            println("Error initializing physics body!")
        }
    }
    
    func addVirus(game: Game, virus: Virus, completion: (() -> ())) {
        let virusNode = SKSpriteNode(imageNamed: virus.name)
        virusNode.size = CGSize(width: 1, height: 1)
        
        let startXY = CGPoint(x: size.width / 2, y: size.height / 2)
        let renderCoords = renderCoordinates(virus.positionX, virus.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        let renderXY = CGPoint(x: renderCoords.0, y: renderCoords.1)
        
        virusNode.position = startXY
        
        // DEBUG
        //println("Adding virus at \(virusNode.position)/(\(size.width), \(size.height))")
        
        bestowPhysics(virusNode, radius: VirusSize.width / 2, category: PhysicsCategory.Virus, contact: PhysicsCategory.Antibody | PhysicsCategory.WCell)
        
        if virus.animationScheme != [1] {
            configureAnimationLoop(virusNode, virus.animationScheme, virus.name, game.field.virusAnimationSpeed)
        }
        
        let zoomAction = SKAction.group([SKAction.scaleTo(VirusSize.width, duration: 0.59), SKAction.moveTo(renderXY , duration: 0.59)])
        
        virusNode.runAction(SKAction.sequence([zoomAction, SKAction.runBlock(completion)]))
        
        addChild(virusNode)
        virusNodes.append(virusNode)
        
        // DEBUG
        /*let destination = virusNode.position - CGPoint(x: 0, y: 1000)
        
        let actionMove = SKAction.moveTo(destination, duration: 60.0)
        let actionMoveDone = SKAction.removeFromParent()
        virusNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))*/
    }
    
    func redrawViruses(game: Game, descended: Bool = false) {
        // DEBUG
        //println("Redrawing viruses")
        
        for i in 0 ..< virusNodes.count {
            if let virus = game.field.viruses[i] {
                let gameCoords = (virus.positionX, virus.positionY)
                let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                /*let duration = descended ? virusMoveDuration * 1000 : virusMoveDuration
                let actionMove = SKAction.moveTo(destination, duration: NSTimeInterval(virusMoveDuration))
                virusNodes[i].runAction(SKAction.sequence([actionMove]))*/
                virusNodes[i].position = destination
            }
        }
    }
    
    func removeVirus(game: Game, whichVirus: Int)
    {
        // DEBUG
        //println("Removing virus at index \(whichVirus)")
        
        let explosionNode = SKSpriteNode(imageNamed: "explosion-1")
        explosionNode.position = virusNodes[whichVirus].position
        
        virusNodes[whichVirus].removeFromParent()
        addChild(explosionNode)
        
        var textures = [SKTexture]()
        
        for i in 1 ... 3 {
            textures.append(SKTexture(imageNamed: "explosion-\(i)"))
        }
        
        explosionNode.runAction(SKAction.sequence([SKAction.animateWithTextures(textures, timePerFrame: SpeedConfig[0].virusAnimationSpeed), SKAction.removeFromParent()]))
        playSound("explosion.wav")
        
        virusNodes.removeAtIndex(whichVirus)
    }
    
    func addAntigen(virus: Virus, antigen: Antigen)
    {
        let antigenNode = SKSpriteNode(imageNamed: antigen.name)
        
        let renderPosition = renderCoordinates(virus.positionX, virus.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        antigenNode.position = CGPoint(x: renderPosition.0, y: renderPosition.1)
        
        bestowPhysics(antigenNode, radius: CGFloat(antigenDimensions.0 / 2), category: PhysicsCategory.Antigen, contact: PhysicsCategory.WCell & PhysicsCategory.Antibody | PhysicsCategory.Shield | PhysicsCategory.Ground | PhysicsCategory.OuterBound, precise: true)
        
        if antigen.animationSequence != [1] {
            configureAnimationLoop(antigenNode, antigen.animationSequence, antigen.name, 0.05)
        }
        
        addChild(antigenNode)
        antigenNodes.append(antigenNode)
        
        // DEBUG
        /*let direction = CGPoint(x: 0, y: -1)
        
        let shootAmount = direction * 1000
        
        let destination = shootAmount + antigenNode.position
        
        let actionMove = SKAction.moveTo(destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        antigenNode.runAction(SKAction.sequence([actionMove, actionMoveDone]))*/
    }
    
    func redrawAntigens(game: Game) {
        for i in 0 ..< game.field.antigens.count {
            if let antigen = game.field.antigens[i] {
                let gameCoords = (antigen.positionX, antigen.positionY)
                let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                antigenNodes[i].position = destination
                /*let actionMove = SKAction.moveTo(destination, duration: 0.05)
                antigenNodes[j].runAction(SKAction.sequence([actionMove]))*/
            }
        }
    }
    
    func removeAntigens(whichVirus: Int, whichAntigen: Int)
    {
        // DEBUG
        //println("Removing antibody at index \(whichAntibody)")
        
        antigenNodes[whichAntigen].removeFromParent()
        antigenNodes.removeAtIndex(whichAntigen)
    }
    
    func createLevelScene()
    {
        /*var virusNodes = [SKSpriteNode]()
        var numViruses = 0
        
        if let field = game.field
        {
            for (id, virus) in field.viruses
            {
                virusNodes.append(SKSpriteNode(imageNamed: "vredstar"))
                virusNodes[numViruses].physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(virusDimensions.0 / 2))
                virusNodes[numViruses].physicsBody?.dynamic = true
                virusNodes[numViruses].physicsBody?.categoryBitMask = PhysicsCategory.Virus
                virusNodes[numViruses].physicsBody?.contactTestBitMask = PhysicsCategory.Antibody
                virusNodes[numViruses].physicsBody?.collisionBitMask = PhysicsCategory.None
                
                virusNodes[numViruses].position = CGPoint(x: Double(virus.positionX) * (Double(size.width) / Double(fieldDimensions.0)), y: Double(virus.positionY) * (Double(size.height) / Double(fieldDimensions.1)))
                
                // DEBUG
                //println("Width: \(size.width)\nHeight: \(size.height)\nVirus Coordinate X:\(virus.positionX)\nVirus Coordinate Y:\(virus.positionY)\n")
                
                addChild(virusNodes[numViruses])
                
                let duration = 15.0
                
                let actionMove = SKAction.moveTo(CGPoint(x: Double(virus.positionX) * (Double(size.width) / Double(fieldDimensions.0)), y: Double(virus.positionY) * (Double(size.height) / Double(fieldDimensions.1)) - Double(fieldDimensions.1)), duration: NSTimeInterval(duration))
                
                let actionMoveDone = SKAction.removeFromParent()
                
                let loseAction = SKAction.runBlock()
                {
                    //let reveal = SKTransition.flipHorizontalWithDuration(1)
                    //let finalResultsScene = FinalResultsScene(size: self.size, won: false)
                    //self.view?.presentScene(finalResultsScene, transition: reveal)
                }
                
                virusNodes[numViruses].runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
                
                numViruses++
            }
            
            field.game?.goToNextLevel()
        }*/
    }
    
    /*func addMonster()
    {
        let monster = SKSpriteNode(imageNamed: "monster")
        
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.width / 2) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
        monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
        addChild(monster)
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width / 2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }*/
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        /*// 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        // Play sound effect
        runAction(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))*/
    }
    
    func antibodyDidCollideWithVirus(antibody: SKSpriteNode, virus: SKSpriteNode)
    {
        /*let distance = antibody.position.length() - virus.position.length()
        let absDistance = distance < 0 ? -distance : distance
        if Int(absDistance) < Int(virusDimensions.0 / 2) {*/
        
        //println("Boom!")
        //antibody.removeFromParent()
        //virus.removeFromParent()
        
        /*}*/
        
        /*println("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
        
        if (++monstersDestroyed >= 3) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }*/
    }
    
    func endOfLevel(game: Game)
    {
        stopMusic?()
    }
    
    func levelTransition(game: Game, transition: (() -> ()))
    {
        // DEBUG
        //println("Crumple!")
        
        /*for antigenNode in antigenNodes {
            antigenNode.removeFromParent()
        }*/
        
        /*virusNodes = [SKSpriteNode]()
        antibodyNodes = [SKSpriteNode]()
        antigenNodes = [SKSpriteNode]()*/
        
        // Wait for antigens to disappear
        
        func restart() {
            // DEBUG
            //println("Wham!")
            
            startMusic?()
            transition()
        }
        
        runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(LevelPauseDuration))]), completion: restart)
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
        // DEBUG
        //println("WHAM!")
        
        //collisionHappened?()
        
        /*var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Virus != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Antibody != 0)) {
                antibodyDidCollideWithVirus(firstBody.node as SKSpriteNode, virus: secondBody.node as SKSpriteNode)
        }*/
    }
    
    func redrawEnergy(game: Game)
    {
        var offset = 0
        for i in 0 ..< energyNodes.count {
            energyNodes[i - offset].removeFromParent()
            energyNodes.removeAtIndex(i - offset)
            offset++
        }
        for i in 0 ..< game.energy.count {
            var spriteName: String!
            switch game.energy[i] {
            case .BlueEnergy:
                spriteName = "blue"
            case .GreenEnergy:
                spriteName = "green"
            case .GoldEnergy:
                spriteName = "gold"
            default:
                spriteName = "red"
            }
            
            var newEnergyNode = SKSpriteNode(imageNamed: "power\(spriteName)")
            newEnergyNode.position = CGPoint(x: CGFloat(18 + 37 * i), y: size.height - 39)
            newEnergyNode.size = CGSize(width: 35.0, height: 10.0)
            newEnergyNode.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeAlphaTo(0.5, duration: 1), SKAction.fadeAlphaTo(1.0, duration: 1)])))
            energyNodes.append(newEnergyNode)
            addChild(newEnergyNode)
        }
        if energyNodes.count == 4 {
            // DEBUG
            //println("Combo!")
            for energyNode in energyNodes {
                energyNode.removeAllActions()
                energyNode.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeAlphaTo(0.5, duration: 0.25), SKAction.fadeAlphaTo(1.0, duration: 0.25)])))
            }
        }
    }
    
    func redrawCharge(game: Game)
    {
        /*if let myChargeNode = chargeNode {
            myChargeNode.removeFromParent()
            chargeNode = nil
        }
        
        var chargeScalar: Float = Float(game.charge) / Float(PowerThreshold)
        if chargeScalar > 1.0 {
            chargeScalar = 1.0
        }
        
        chargeNode = SKSpriteNode()
        chargeNode!.color = SKColor.whiteColor()
        chargeNode!.position = CGPoint(x: 0, y: size.height - 60)
        chargeNode!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        chargeNode!.alpha = CGFloat(0.25 + chargeScalar / 2.0)
        chargeNode!.size = CGSize(width: Int(180.0 * chargeScalar), height: 4)
        addChild(chargeNode!)*/
    }
}