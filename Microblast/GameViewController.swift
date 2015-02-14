//
//  GameViewController.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import CoreMotion

class GameViewController: UIViewController, GameDelegate
{
    var scene: GameScene!
    var game: Game!
    var acceptUserInput = false
    var touchDown: NSDate? = nil
    var touchDuration = 0
    var previewViewLabelText = ["", "", "", ""]
    let motionManager: CMMotionManager = CMMotionManager()
    
    var previewTicks = 0
    var time = 0.0
    
    @IBOutlet weak var previewView: UIView! // does the job
    @IBOutlet weak var previewViewLabel1: UILabel!
    @IBOutlet weak var previewViewLabel2: UILabel!
    @IBOutlet weak var previewViewLabel3: UILabel!
    @IBOutlet weak var previewViewLabel4: UILabel!
    
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var levelNumberDisplay: UILabel!
    @IBOutlet weak var scoreNumberDisplay: UILabel!
    @IBOutlet weak var specialNameDisplay: UILabel!
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createGame()
        
        startTitleScreen()
        
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
        //skView.showsFPS = true
        //skView.showsDrawCount = true
        //skView.showsNodeCount = true
    }
    
    func startPreviewScreen()
    {
        let skView = view as SKView
        
        // DEBUG
        //skView.showsFPS = false
        //skView.showsDrawCount = false
        //skView.showsNodeCount = false
        
        skView.ignoresSiblingOrder = true
        skView.multipleTouchEnabled = false
        
        let previewScene = PreviewScene(size: skView.bounds.size, labels: [previewViewLabel1, previewViewLabel2, previewViewLabel3, previewViewLabel4], callback: startGameScreen)
        previewScene.scaleMode = .ResizeFill
        
        previewView.hidden = false
        
        playBackgroundMusic()
        
        skView.presentScene(previewScene)
    }
    
    func startGameScreen()
    {
        // Start game scene
        
        let skView = view as SKView
        
        // DEBUG
        //skView.showsFPS = false
        //skView.showsDrawCount = false
        //skView.showsNodeCount = false
        
        //skView.ignoresSiblingOrder = true
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .ResizeFill
        scene.tick = didTick
        scene.frameTick = didFrameTick
        scene.startMusic = playBackgroundMusic
        scene.stopMusic = stopBackgroundMusic
        scene.startTicking()
        scene.collisionHappened = game.field.resultOfCollision
        
        startNewCampaign()
        
        motionManager.startAccelerometerUpdates()
        
        skView.presentScene(scene, transition: SKTransition.crossFadeWithDuration(0.5))
    }
    
    func startNewCampaign()
    {
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
        game.energy = [Energy]()
        previewViewLabel1.text = ""
        previewViewLabel2.text = ""
        previewViewLabel3.text = ""
        previewViewLabel4.text = ""
        createGame()
        startPreviewScreen()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent)
    {
        if !acceptUserInput
        {
            return
        }
        
        if !game.hasStarted
        {
            return
        }
        else
        {
            touchDown = NSDate()
            
            let touch = touches.anyObject() as UITouch
            let touchLocation = touch.locationInNode(scene)
            
            if touchLocation.x > view.bounds.size.width - PauseButtonSize.width && touchLocation.y > view.bounds.size.height - PauseButtonSize.height
            {
                touchDown = nil
                if !scene.paused {
                    statusBarView.alpha = 0.3
                    scene.pauseScene()
                    scene.stopTicking()
                    backgroundMusicPlayer.volume = 0.25
                }
                else
                {
                    backgroundMusicPlayer.volume = 1.0
                    scene.unpauseScene()
                    statusBarView.alpha = 0.75
                    scene.startTicking()
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
    {
        if !acceptUserInput || !game.hasStarted
        {
            return
        }
        
        if touchDown == nil
        {
            return
        }
        
        touchDown = nil
        
        let myTouchDuration = touchDuration
        touchDuration = 0
        game.charge = 0
        chargeDidUpdate(game)
        
        if myTouchDuration >= PowerThreshold
        {
            if let player = game.field.player
            {
                if player.hasSpecial()
                {
                    player.trySpecial()
                    game.energy = [Energy]()
                    energyDidUpdate(game)
                    return
                }
            }
        }
        
        if let player = game.field.player
        {
            player.tryShoot()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    func didFrameTick()
    {
        if !acceptUserInput || !game.hasStarted
        {
            return
        }
        
        game.field.moveProjectiles()
        
        // Move player
        if let player = game.field.player {
            if let data = motionManager.accelerometerData
            {
                player.move(data.acceleration.x)
            }
            else
            {
                // Uncomment for sample sinusoidal movement when no accelerometer
                // data is available
                //let sampleData = sin(time++ / 10.0) / 2.0
                //player.move(sampleData)
            }
        }
        
        // Charge power
        if touchDown != nil
        {
            touchDuration++
            game.charge++
            chargeDidUpdate(game)
        }
    }
    
    func didTick()
    {
        if !game.hasStarted
        {
            return
        }
        else
        {
            game.field.moveViruses()
            game.field.tryVirusAttack()
            game.checkIfLevelIsOver()
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
    
    func playerDidMove(game: Game, player: WhiteBloodCell)
    {
        scene.redrawPlayer(game, player: player)
    }
    
    func playerDidShoot(type: AntibodyType)
    {
        switch type
        {
        case AntibodyType.Special1:
            scene.playSound("special.wav")
        default:
            scene.playSound("laser.wav")
        }
    }
    
    func playerDidDie(game: Game)
    {
        var offset = 0
        for i in 0 ..< game.field.player!.antibodies.count {
            scene.removeAntibody(i - offset++)
        }
        scene.removePlayer(game.continueLevel)
        game.field.removePlayer()
    }
    
    func antibodyDidAppear(game: Game, antibody: Antibody)
    {
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
    
    func virusDidAppear(game: Game, virus: Virus, afterTransition: (() -> ()))
    {
        scene.addVirus(game, virus: virus, completion: afterTransition)
    }
    
    func virusesDidMove(game: Game)
    {
        scene.redrawViruses(game)
    }
    
    func virusesDidDescend(game: Game)
    {
        scene.redrawViruses(game, descended: true)
    }
    
    func virusReachedBottomOfField(game: Game)
    {
        // DEBUG
        println("Game over!")
        scene.stopTicking()
    }
    
    func virusReachedEdgeOfField(game: Game)
    {
        
    }
    
    func virusDidDie(game: Game, whichVirus: Int)
    {
        scene.removeVirus(game, whichVirus: whichVirus)
        
        // (Number of viruses left, index to access in [SpeedConfig])
        let stageProgression = [
            (1, 4), (2, 3), (game.field.startingCount / 4, 2), (game.field.startingCount / 2, 1)
        ]
        
        if game.field.viruses.count == 0
        {
            playerDidKillAllViruses(game)
            game.stage = 0
        }
        else
        {
            for (limit, stage) in stageProgression
            {
                if game.field.viruses.count == limit
                {
                    scene.tickLengthMillis = SpeedConfig[stage].tickLength
                    scene.virusMoveDuration = SpeedConfig[stage].moveDuration
                    game.field.step = SpeedConfig[stage].step
                    game.field.virusAnimationSpeed = SpeedConfig[stage].virusAnimationSpeed
                    break
                }
            }
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
    
    func antigenDidExplode()
    {
        scene.playSound("boom.wav")
    }
    
    func playerDidKillAllViruses(game: Game)
    {
        scene.endOfLevel(game)
    }
    
    func levelDidEnd(game: Game, transition: (() -> ()))
    {
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
        if game.energy.count == 4
        {
            switch game.energy[0]
            {
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
        }
        else
        {
            specialNameDisplay.text = ""
        }
        
        scene.redrawEnergy(game)
    }
    
    func chargeDidUpdate(game: Game)
    {
        scene.redrawCharge(game)
    }
    
    func playBackgroundMusic()
    {
        let filename = "theme.mp3"
        
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        
        if (url == nil)
        {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        
        if backgroundMusicPlayer == nil
        {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    func stopBackgroundMusic()
    {
        backgroundMusicPlayer = nil
    }
}