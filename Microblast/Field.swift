//
//  Field.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation

// Field /////////////////////////////////////////////////////////////////////

class Field
{
    init(width: Int = fieldDimensions.0, height: Int = fieldDimensions.1, game: Game)
    {
        self.width = width
        self.height = height
        viruses = [Virus]()
        forwardRight = true
        self.game = game
        startingCount = 0
        self.step = SpeedConfig[0].step
        descendingDown = 0
        virusAnimationSpeed = SpeedConfig[0].virusAnimationSpeed
        antigens = [Antigen?]()
        addPlayer()
    }
    
    func addPlayer()
    {
        player = WhiteBloodCell(field: self)
    }
    
    func removePlayer()
    {
        player = nil
    }
    
    func addViruses()
    {
        startingCount = 0
        var offset: Int
        
        if let level = game?.level {
            offset = 0 + (level * numSlotsPerLevel)
        } else {
            println("Error: game.level not initialized")
            return
        }
        
        for i in offset ..< offset + numSlotsPerLevel {
            let coordinates = pointForLayout(i - offset)
            
            // DEBUG
            //println("\(gameModel[i])")
            
            switch gameModel[i] {
            case 0:
                //viruses.append(nil)
                break
            case 2:
                let newVirus = BlueStar(positionX: Int(coordinates.x), positionY: Int(coordinates.y), id: i, field: self)
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 3:
                let newVirus = GreenStar(positionX: Int(coordinates.x), positionY: Int(coordinates.y), id: i, field: self)
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 4:
                let newVirus = GoldStar(positionX: Int(coordinates.x), positionY: Int(coordinates.y), id: i, field: self)
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 5:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), name: "chicken", id: i, field: self, animationScheme: [1])
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 6:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), name: "mikewazaski", id: i, field: self, animationScheme: [1])
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 7:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), name: "amoeba", id: i, field: self, animationScheme: [1, 2, 3, 4, 3, 2, 1, 5, 6, 7, 6, 5])
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 8:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), name: "meh", id: i, field: self, animationScheme: [1])
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            case 9:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), name: "theabyss", id: i, field: self, animationScheme: [1])
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            default:
                let newVirus = Virus(positionX: Int(coordinates.x), positionY: Int(coordinates.y), id: i, field: self)
                
                // DEBUG
                //println("Virus at (\(coordinates.x), \(coordinates.y))")
                
                viruses.append(newVirus)
                startingCount++
                game.delegate?.virusDidAppear(game, virus: newVirus, afterTransition: newVirus.setZPlaneMain)
            }
        }
    }
    
    func killVirus(whichVirus: Int)
    {
        viruses.removeAtIndex(whichVirus)
    }
    
    func moveViruses()
    {
        for i in 0 ..< viruses.count {
            if let virus = viruses[i] {
                if virus.zPlane != 0 {
                    return
                }
            }
        }
        
        // DEBUG
        let directionScalar = forwardRight ? 1 : -1
        //var directionalSwitch = false
        
        // Check if it's time to change direction (if a virus hits the side of the screen)
        for i in 0 ..< viruses.count {
            if let virus = viruses[i] {
                if (virus.positionX < virusDimensionsWithMargin.0 / 2 && forwardRight == false) || (virus.positionX > fieldDimensions.0 - virusDimensionsWithMargin.0 / 2 && forwardRight == true) {
                    //directionalSwitch = true
                    descendingDown += 10
                    forwardRight = !forwardRight // !
                    game.delegate?.virusReachedEdgeOfField(game)
                    break
                }
                if virus.positionY < virusDimensionsWithMargin.1 {
                    game.delegate?.virusReachedBottomOfField(game)
                    return
                }
            }
        }
        
        if descendingDown > 0 {
            // Step down
            for i in 0 ..< viruses.count {
                if let virus = viruses[i] {
                    virus.positionY -= VerticalStep
                }
            }
            descendingDown--
            game.delegate?.virusesDidDescend(game)
        } else {
            // Move to the side
            for i in 0 ..< viruses.count {
                if let virus = viruses[i] {
                    virus.positionX += step * directionScalar
                }
            }
            game.delegate?.virusesDidMove(game)
        }
    }
    
    func tryVirusAttack()
    {
        for i in 0 ..< viruses.count {
            if let virus = viruses[i] {
                if virus.zPlane != 0 {
                    return
                }
            }
        }
        
        if antigens.count <= numCols {
            for virus in viruses {
                if random(1000) < SpeedConfig[game.stage].virusAttackChance {
                    virus?.tryShoot()
                }
            }
        }
    }
    
    func resultOfCollision()
    {
        var antibodyHitList = [Int]()
        var antibodyBlacklist = [Int]()
        var virusHitList = [Int]()
        var antigenHitList = [Int]()
        var playerHit = false
        
        if let player = player {
            // Check for collisions or antigens that landed
            for i in 0 ..< antigens.count {
                if let antigen = antigens[i] {
                    // Antigen out of screen
                    if antigen.positionX < 0 + InnerMargin || antigen.positionY < 0 || antigen.positionY > fieldDimensions.1 {
                        antigenHitList.append(i)
                    }
                    // Antigen hit player
                    if absolute(antigen.positionX - player.positionX) < Int(PlayerSize.width) / 2 && absolute(antigen.positionY - player.positionY) < Int(PlayerSize.height) / 2 {
                        antigenHitList.append(i)
                        playerHit = true
                    }
                }
            }
            
            // Check for collisions or out-of-screen antibodies
            for i in 0 ..< player.antibodies.count {
                if let antibody = player.antibodies[i] {
                    // Antibody out of screen
                    if antibody.positionX < 0 - OuterMargin || antibody.positionX > fieldDimensions.0 + OuterMargin
                        || antibody.positionY < 0 - OuterMargin || antibody.positionY > fieldDimensions.1 + OuterMargin {
                            antibodyHitList.append(i)
                    }
                    for j in 0 ..< viruses.count {
                        if let virus = viruses[j] {
                            if virus.zPlane == 0 {
                                // Antibody in contact with virus
                                if absolute(antibody.positionX - virus.positionX) < virusDimensions.0 * 2 / 3 && absolute(antibody.positionY - virus.positionY) < virusDimensions.1 * 2 / 3 {
                                    if antibody.priority <= 3 {
                                        antibodyHitList.append(i)
                                    }
                                    virusHitList.append(j)
                                    break
                                }
                            }
                        }
                    }
                    for j in 0 ..< antigens.count {
                        if let antigen = antigens[j] {
                            // Antibody vs. antigen
                            if absolute(antibody.positionX - antigen.positionX) < AntibodyDimensions.0 / 2 && absolute(antibody.positionY - antigen.positionY) < AntibodyDimensions.1 / 2 {
                                if antigen.priority < antibody.priority {
                                    antigenHitList.append(j)
                                } else if antigen.priority == antibody.priority {
                                    antigenHitList.append(j)
                                    antibodyHitList.append(i)
                                } else {
                                    antibodyHitList.append(i)
                                }
                                break
                            }
                        }
                    }
                }
            }
            
            var offset = 0
            for i in antibodyHitList {
                if contains(antibodyBlacklist, i) {
                    continue
                } else {
                    player.antibodies[i - offset]?.die()
                    player.antibodies.removeAtIndex(i - offset)
                    game.delegate?.antibodyDidDie(i - offset)
                    antibodyBlacklist.append(i)
                    offset++
                }
            }
            offset = 0
            for i in antigenHitList {
                antigens.removeAtIndex(i - offset)
                game.delegate?.antigenDidDie(i, whichAntigen: i - offset)
                offset++
            }
            offset = 0
            for i in virusHitList {
                if let virus = game.field.viruses[i - offset] {
                    virus.wasHit()
                    if virus.isDead() {
                        game.score += virus.score
                        game.addEnergy(virus.getEnergy())
                        game.delegate?.scoreDidUpdate(game)
                        killVirus(i - offset)
                        game.delegate?.virusDidDie(game, whichVirus: i - offset)
                        offset++
                    }
                }
            }
            if playerHit {
                player.wasHit()
                if player.isDead() {
                    // DEBUG
                    //println("You got destroyed!")
                    
                    // Temp restore
                    //player.HP = 1
                }
            }
        }
    }
    
    func moveProjectiles()
    {
        // Antigens
        for i in 0 ..< antigens.count {
            if let antigen = antigens[i] {
                antigen.positionX += antigen.directionX * antigen.speed
                antigen.positionY += antigen.directionY * antigen.speed
                
                // DEBUG
                //println("Antigen at (\(antigen.positionX), \(antigen.positionY))")
            }
        }
        
        game.delegate?.antigensDidMove(game)
        
        // Antibodies
        if let player = player {
            for i in 0 ..< player.antibodies.count {
                if let antibody = player.antibodies[i] {
                    // DEBUG
                    //println("Direction \(antibody.direction)")
                    //println("Speed \(antibody.speed)")
                    
                    antibody.positionX += Int(Float(antibody.direction.x) * Float(antibody.speed))
                    antibody.positionY += Int(Float(antibody.direction.y) * Float(antibody.speed))
                    
                    // DEBUG
                    //println("Antibody (\(antibody.positionX), \(antibody.positionY))")
                }
            }
        }
        
        game.delegate?.antibodiesDidMove(game)
        
        // DEBUG
        resultOfCollision()
    }
    
    var width: Int
    var height: Int
    var viruses: [Virus?]
    var player: WhiteBloodCell?
    var game: Game!
    var forwardRight: Bool
    var descendingDown: Int
    var startingCount: Int
    var step: Int
    var antigens: [Antigen?]
    var virusAnimationSpeed: NSTimeInterval
}
