//
//  GameViewController.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameDelegate {
    var scene: GameScene!
    var game: Game!
    var acceptUserInput = false
    var touchDown: NSDate? = nil
    var touchDuration = 0
    var previewViewLabelText = ["", "", "", ""]
    
    var previewTicks = 0

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewViewLabel1: UILabel!
    @IBOutlet weak var previewViewLabel2: UILabel!
    @IBOutlet weak var previewViewLabel3: UILabel!
    @IBOutlet weak var previewViewLabel4: UILabel!
    
    @IBOutlet weak var statusBarView: UIView!
        
    @IBOutlet weak var levelNumberDisplay: UILabel!
    
    @IBOutlet weak var scoreNumberDisplay: UILabel!
    
    @IBOutlet weak var specialNameDisplay: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createGame()
        
        startTitleScreen()
        
        // Start preview scene
        
        startPreviewScreen()
    }
    
    func createGame()
    {
        game = Game()
        game.delegate = self
    }
    
    func startTitleScreen()
    {
        let skView = view as SKView
        
        // DEBUG
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        
        // ***
    }
    
    func startPreviewScreen()
    {
        let skView = view as SKView
        
        // DEBUG
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        
        skView.ignoresSiblingOrder = true
        skView.multipleTouchEnabled = false
        
        let previewScene = PreviewScene(size: skView.bounds.size, labels: [previewViewLabel1, previewViewLabel2, previewViewLabel3, previewViewLabel4], callback: startGameScreen)
        previewScene.scaleMode = .ResizeFill
        
        previewView.hidden = false
        
        skView.presentScene(previewScene)
    }
    
    func startGameScreen()
    {
        // Start game scene
        
        let skView = view as SKView
        
        // DEBUG
        skView.showsFPS = true
        skView.showsDrawCount = true
        skView.showsNodeCount = true
        
        //skView.ignoresSiblingOrder = true
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .ResizeFill
        scene.tick = didTick
        scene.frameTick = didFrameTick
        scene.startTicking()
        scene.collisionHappened = game.field.resultOfCollision
        
        startNewCampaign()
        
        skView.presentScene(scene, transition: SKTransition.crossFadeWithDuration(0.5))
    }
    
    func startNewCampaign()
    {
        // DEBUG
        //println("startNewGame()")
        
        scene.setUpCampaign()
        
        startGame()
    }
    
    func startGame()
    {
        acceptUserInput = true
        statusBarView.hidden = false
        previewView.hidden = true
        previewTicks = 0
        previewIsDone(game)
        game.start()
    }
    
    func gameDidEnd()
    {
        statusBarView.hidden = true
        acceptUserInput = false
        game.hasStarted = false
        game.score = 0
        game.level = 0
        scoreDidUpdate(game)
        levelDidUpdate(game)
        previewViewLabel1.text = ""
        previewViewLabel2.text = ""
        previewViewLabel3.text = ""
        previewViewLabel4.text = ""
        createGame()
        startPreviewScreen()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if !acceptUserInput {
            return
        }
        
        if !game.hasStarted {
            return
        } else {
            touchDown = NSDate()
            
            /*if lastTick == nil {
            return
            }
            var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
            if timePassed > tickLengthMillis {
            lastTick = NSDate()
            tick?()
            }*/
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        if !acceptUserInput {
            return
        }
        
        if !game.hasStarted {
            
        } else {
            let myTouchDuration = touchDuration
            touchDuration = 0
            game.charge = 0
            chargeDidUpdate(game)
            
            if touchDown == nil {
                return
            }
            
            touchDown = nil
            
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(scene)
            
            if myTouchDuration >= PowerThreshold {
                // DEBUG
                //println("\(myTouchDuration) time passed: power shot!")
                
                if game.field.player.hasSpecial() {
                    game.field.player.trySpecial(touchLocation)
                    game.energy = [Energy]()
                    energyDidUpdate(game)
                    return
                }
            }
            
            // DEBUG
            //println("Touch location \(touchLocation)")
            
            game.field.player.tryShoot(touchLocation)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func didTick()
    {
        // DEBUG
        //println("didTick()")
        
        if !game.hasStarted {
            // DEBUG
            println("!!!!!!!!!!!game.hasStarted")
            
            return
        } else {
            // DEBUG
            //println("Tick...")
            game.field.moveViruses()
            game.field.tryVirusAttack()
            game.checkIfLevelIsOver()
        }
    }
    
    func didFrameTick()
    {
        // DEBUG
        //println("didFrameTick()")
        
        if !game.hasStarted {
            // DEBUG
            println("!!!!!!!!!!!game.hasStarted")
            
            return
            
            // DEBUG
            //println(PreviewText)
            //println(previewTicks)
            
            //previewTicks++
        } else {
            game.field.moveProjectiles()
            if touchDown != nil {
                touchDuration++
                game.charge++
                chargeDidUpdate(game)
                // DEBUG
                //println("Touched for \(touchDuration) frame ticks")
            }
        }
    }
    
    func previewIsDone(game: Game)
    {
        scene.dissolvePreview(game)
    }
    
    func playerDidAppear(game: Game, player: WhiteBloodCell)
    {
        scene.addPlayer(game, player: player)
    }
    
    func antibodyDidAppear(game: Game, antibody: Antibody)
    {
        // DEBUG
        //println("Antibody did appear")
        
        scene.addAntibody(antibody)
    }
    
    func antibodiesDidMove(game: Game)
    {
        scene.redrawAntibodies(game)
    }
    
    func antibodyDidDie(whichAntibody: Int)
    {
        scene.removeAntibody(whichAntibody)
    }
    
    func virusDidAppear(game: Game, virus: Virus, afterTransition: (() -> ())) {
        // DEBUG
        //println("Virus did appear")
        
        scene.addVirus(game, virus: virus, completion: afterTransition)
    }
    
    func virusesDidMove(game: Game) {
        scene.redrawViruses(game)
    }
    
    func virusesDidDescend(game: Game) {
        scene.redrawViruses(game, descended: true)
    }
    
    func virusReachedBottomOfField(game: Game) {
        // DEBUG
        println("Game over!")
        scene.stopTicking()
    }
    
    func virusReachedEdgeOfField(game: Game) {
        
    }
    
    func virusDidDie(game: Game, whichVirus: Int)
    {
        scene.removeVirus(game, whichVirus: whichVirus)
        
        if game.field.viruses.count == 0 {
            playerKilledAllViruses(game)
            //levelDidEnd(game, game.goToNextLevel)
        } else if game.field.viruses.count <= 1 {
            // DEBUG
            //println("Speedy 5!")
            
            scene.tickLengthMillis = SpeedConfig[4].tickLength
            scene.virusMoveDuration = SpeedConfig[4].moveDuration
            game.field.step = SpeedConfig[4].step
            game.field.virusAnimationSpeed = SpeedConfig[4].virusAnimationSpeed
        } else if game.field.viruses.count <= 2 {
            // DEBUG
            //println("Speedy 4!")
            
            scene.tickLengthMillis = SpeedConfig[3].tickLength
            scene.virusMoveDuration = SpeedConfig[3].moveDuration
            game.field.step = SpeedConfig[3].step
            game.field.virusAnimationSpeed = SpeedConfig[3].virusAnimationSpeed
        } else if game.field.viruses.count <= game.field.startingCount / 4 {
            // DEBUG
            //println("Speedy 3!")
            
            scene.tickLengthMillis = SpeedConfig[2].tickLength
            scene.virusMoveDuration = SpeedConfig[2].moveDuration
            game.field.step = SpeedConfig[2].step
            game.field.virusAnimationSpeed = SpeedConfig[2].virusAnimationSpeed
        } else if game.field.viruses.count <= game.field.startingCount / 2 {
            // DEBUG
            //println("Speedy 2!")
            
            scene.tickLengthMillis = SpeedConfig[1].tickLength
            scene.virusMoveDuration = SpeedConfig[1].moveDuration
            game.field.step = SpeedConfig[1].step
            game.field.virusAnimationSpeed = SpeedConfig[4].virusAnimationSpeed
        }
    }
    
    func antigenDidAppear(virus: Virus, antigen: Antigen)
    {
        scene.addAntigen(virus, antigen: antigen)
    }
    
    func antigensDidMove(game: Game)
    {
        scene.redrawAntigens(game)
    }
    
    func antigenDidDie(whichVirus: Int, whichAntigen: Int)
    {
        scene.removeAntigens(whichVirus, whichAntigen: whichAntigen)
    }
    
    func playerKilledAllViruses(game: Game)
    {
        scene.endOfLevel(game)
    }
    
    func levelDidEnd(game: Game, transition: (() -> ())) {
        scene.stopSpacedTicks()
        scene.tickLengthMillis = SpeedConfig[0].tickLength
        scene.virusMoveDuration = SpeedConfig[0].moveDuration
        game.field.step = SpeedConfig[0].step
        game.field.virusAnimationSpeed = SpeedConfig[0].virusAnimationSpeed
        scene.levelTransition(game, transition)
    }
    
    func levelDidBegin(game: Game)
    {
        scene.startSpacedTicks()
    }
    
    func levelDidUpdate(game: Game)
    {
        levelNumberDisplay.text = "\(game.level+1)"
    }
    
    func scoreDidUpdate(game: Game)
    {
        scoreNumberDisplay.text = "\(game.score)"
    }
    
    func energyDidUpdate(game: Game)
    {
        if game.energy.count == 4 {
            switch game.energy[0] {
            case .RedEnergy:
                specialNameDisplay.text = "Piercing Shot"
            case Energy.BlueEnergy:
                specialNameDisplay.text = "Left Hook Shot"
            case .GreenEnergy:
                specialNameDisplay.text = "Right Hook Shot"
            case .GoldEnergy:
                specialNameDisplay.text = "Diagonal Burst"
            default:
                break
            }
        } else {
            specialNameDisplay.text = ""
        }
        
        scene.redrawEnergy(game)
    }
    
    func chargeDidUpdate(game: Game) {
        scene.redrawCharge(game)
    }
}