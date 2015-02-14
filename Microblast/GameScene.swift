//
//  GameScene.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import SpriteKit
import Foundation

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
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("NSCoder not supported")
    }
    
    func playSound(sound:String)
    {
        runAction(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override init(size: CGSize)
    {
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
    }
    
    override func didMoveToView(view: SKView)
    {
        // Initialize field
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
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
        if (lastTick == nil)
        {
            return
        }
        
        // Frame-by-frame
        frameTick?()
        
        if spacedTicksEnabled
        {
            var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
            
            if timePassed > tickLengthMillis
            {
                lastTick = NSDate()
                tick?()
            }
        }
    }
    
    func startTicking()
    {
        lastTick = NSDate()
    }
    
    func stopTicking()
    {
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
    
    func startSpacedTicks()
    {
        spacedTicksEnabled = true
    }
    
    func stopSpacedTicks()
    {
        spacedTicksEnabled = false
    }
    
    func dissolvePreview(game: Game)
    {
        if let myPreviewNode = previewNode
        {
            myPreviewNode.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(0.5) , SKAction.removeFromParent()]))
        }
    }
    
    func addPlayer(game: Game, player: WhiteBloodCell)
    {
        let renderCoords = renderCoordinates(player.positionX, player.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        wCellNode.position = CGPoint(x: renderCoords.0, y: renderCoords.1)
        wCellNode.size = PlayerSize
        wCellNode.zRotation = 0.0
        
        initializePhysicsProperties(wCellNode, radius: PlayerSize.width / 2, category: PhysicsCategory.WCell, contact: PhysicsCategory.Antigen | PhysicsCategory.Virus)
        
        wCellNode.zPosition = 100
        addChild(wCellNode)
    }
    
    func redrawPlayer(game: Game, player: WhiteBloodCell)
    {
        let playerNode = wCellNode

        let renderCoords = renderCoordinates(player.positionX, player.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        playerNode.position = CGPoint(x: renderCoords.0, y: renderCoords.1)
        
        let angle = Double(atan(player.angle.y / player.angle.x)) + M_PI_2
        let correctedAngle = player.angle.x >= 0 ? angle + M_PI : angle
        playerNode.zRotation = CGFloat(correctedAngle)
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
    
    func addAntibody(antibody: Antibody)
    {
        let antibodyNode = SKSpriteNode(imageNamed: "antibody")
        
        antibodyNode.position = wCellNode.position
        
        let angle = Double(atan(antibody.direction.y / antibody.direction.x)) + M_PI_2
        let correctedAngle = antibody.direction.x >= 0 ? angle + M_PI : angle
        
        antibodyNode.zRotation = CGFloat(correctedAngle)
        
        initializePhysicsProperties(antibodyNode, radius: antibodyNode.size.width / 2, category: PhysicsCategory.Antibody, contact: PhysicsCategory.Virus | PhysicsCategory.Antigen | PhysicsCategory.OuterBound, precise: true)
        
        addChild(antibodyNode)
        antibodyNodes.append(antibodyNode)
    }
    
    func redrawAntibodies(game: Game)
    {
        if let player = game.field.player
        {
            for i in 0 ..< player.antibodies.count
            {
                if let antibody = game.field.player?.antibodies[i]
                {
                    let gameCoords = (antibody.positionX, antibody.positionY)
                    let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                    let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                    antibodyNodes[i].position = destination
                }
            }
        }
    }
    
    func removeAntibody(whichAntibody: Int)
    {
        antibodyNodes[whichAntibody].removeFromParent()
        antibodyNodes.removeAtIndex(whichAntibody)
    }
    
    func initializePhysicsProperties(body: SKSpriteNode, radius: CGFloat, category: UInt32, contact: UInt32, precise: Bool = false)
    {
        body.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        
        if let myPhysicsBody = body.physicsBody
        {
            myPhysicsBody.dynamic = true
            myPhysicsBody.categoryBitMask = category
            myPhysicsBody.contactTestBitMask = contact
            myPhysicsBody.collisionBitMask = PhysicsCategory.None
            
            if precise
            {
                myPhysicsBody.usesPreciseCollisionDetection = true
            }
        }
        else
        {
            println("Error initializing physics body!")
        }
    }
    
    func addVirus(game: Game, virus: Virus, completion: (() -> ()))
    {
        let virusNode = SKSpriteNode(imageNamed: virus.name)
        virusNode.size = CGSize(width: 1, height: 1)
        
        let startXY = CGPoint(x: size.width / 2, y: size.height / 2)
        let renderCoords = renderCoordinates(virus.positionX, virus.positionY, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
        let renderXY = CGPoint(x: renderCoords.0, y: renderCoords.1)
        
        virusNode.position = startXY
        
        initializePhysicsProperties(virusNode, radius: VirusSize.width / 2, category: PhysicsCategory.Virus, contact: PhysicsCategory.Antibody | PhysicsCategory.WCell)
        
        if virus.animationScheme != [1]
        {
            configureAnimationLoop(virusNode, virus.animationScheme, virus.name, game.field.virusAnimationSpeed)
        }
        
        let zoomAction = SKAction.group([SKAction.scaleTo(VirusSize.width, duration: 0.59), SKAction.moveTo(renderXY , duration: 0.59)])
        
        virusNode.runAction(SKAction.sequence([zoomAction, SKAction.runBlock(completion)]))
        
        addChild(virusNode)
        virusNodes.append(virusNode)
    }
    
    func redrawViruses(game: Game, descended: Bool = false)
    {
        for i in 0 ..< virusNodes.count
        {
            if let virus = game.field.viruses[i]
            {
                let gameCoords = (virus.positionX, virus.positionY)
                let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                virusNodes[i].position = destination
            }
        }
    }
    
    func removeVirus(game: Game, whichVirus: Int)
    {
        let explosionNode = SKSpriteNode(imageNamed: "explosion-1")
        explosionNode.position = virusNodes[whichVirus].position
        
        virusNodes[whichVirus].removeFromParent()
        addChild(explosionNode)
        
        var textures = [SKTexture]()
        
        for i in 1 ... 3
        {
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
        
        initializePhysicsProperties(antigenNode, radius: CGFloat(antigenDimensions.0 / 2), category: PhysicsCategory.Antigen, contact: PhysicsCategory.WCell & PhysicsCategory.Antibody | PhysicsCategory.Shield | PhysicsCategory.Ground | PhysicsCategory.OuterBound, precise: true)
        
        if antigen.animationSequence != [1] {
            configureAnimationLoop(antigenNode, antigen.animationSequence, antigen.name, 0.05)
        }
        
        addChild(antigenNode)
        antigenNodes.append(antigenNode)
    }
    
    func redrawAntigens(game: Game)
    {
        for i in 0 ..< game.field.antigens.count
        {
            if let antigen = game.field.antigens[i]
            {
                let gameCoords = (antigen.positionX, antigen.positionY)
                let renderCoords = renderCoordinates(gameCoords.0, gameCoords.1, deviceWidth: Int(size.width), deviceHeight: Int(size.height))
                let destination = CGPoint(x: renderCoords.0, y: renderCoords.1)
                antigenNodes[i].position = destination
            }
        }
    }
    
    func removeAntigens(whichVirus: Int, whichAntigen: Int)
    {
        antigenNodes[whichAntigen].removeFromParent()
        antigenNodes.removeAtIndex(whichAntigen)
    }
    
    func createLevelScene()
    {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        
    }
    
    func antibodyDidCollideWithVirus(antibody: SKSpriteNode, virus: SKSpriteNode)
    {
        
    }
    
    func endOfLevel(game: Game)
    {
        stopMusic?()
    }
    
    func levelTransition(game: Game, transition: (() -> ()))
    {
        // Wait for antigens to disappear
        func restart()
        {
            startMusic?()
            transition()
        }
        
        runAction(SKAction.sequence([SKAction.waitForDuration(NSTimeInterval(LevelPauseDuration))]), completion: restart)
    }
    
    func didBeginContact(contact: SKPhysicsContact)
    {
    }
    
    func redrawEnergy(game: Game)
    {
        var offset = 0
        
        for i in 0 ..< energyNodes.count
        {
            energyNodes[i - offset].removeFromParent()
            energyNodes.removeAtIndex(i - offset)
            offset++
        }
        
        for i in 0 ..< game.energy.count
        {
            var spriteName: String!
            
            switch game.energy[i]
            {
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
            newEnergyNode.position = CGPoint(x: CGFloat(21 + 43 * i), y: size.height - 46)
            newEnergyNode.size = CGSize(width: 38.0, height: 12.0)
            newEnergyNode.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeAlphaTo(0.5, duration: 1), SKAction.fadeAlphaTo(1.0, duration: 1)])))
            energyNodes.append(newEnergyNode)
            addChild(newEnergyNode)
        }
        
        if (energyNodes.count == 4)
        {
            for energyNode in energyNodes
            {
                energyNode.removeAllActions()
                energyNode.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeAlphaTo(0.5, duration: 0.25), SKAction.fadeAlphaTo(1.0, duration: 0.25)])))
            }
        }
    }
    
    func redrawCharge(game: Game)
    {
    }
}