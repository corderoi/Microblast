//
//  Game.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

// Game //////////////////////////////////////////////////////////////////////

class Game
{
    init()
    {
        level = 0
        stage = 0
        score = 0
        energy = [Energy]()
        charge = 0
        hasStarted = false
        field = Field(game: self)
        
        // DEBUG
        //println(numLevels)
    }
    
    func start()
    {
        delegate?.playerDidAppear(self, player: field.player!)
        field.addViruses()
        delegate?.levelDidBegin(self)
        hasStarted = true
    }
    
    func checkIfLevelIsOver()
    {
        if (field.viruses.count == 0 && field.antigens.count == 0)
        {
            delegate?.levelDidEnd(self, transition: goToNextLevel)
        }
    }
    
    func goToNextLevel()
    {
        if (++level < numLevels)
        {
            stage = 0
            score += LevelClearScore
            delegate?.scoreDidUpdate(self)
            delegate?.levelDidUpdate(self)
            field.addViruses()
            delegate?.levelDidBegin(self)
        }
        else
        {
            delegate?.gameDidEnd()
        }
    }
    
    func continueLevel()
    {
        if score != 0
        {
            score /= 2
        }
        
        delegate?.scoreDidUpdate(self)
        delegate?.levelDidBegin(self)
        field.addPlayer()
        delegate?.playerDidAppear(self, player: field.player!)
    }
    
    func addEnergy(energy: Energy)
    {
        if self.energy.count == 4
        {
            return
        }
        else if self.energy.count > 0
        {
            for storedEnergy in self.energy
            {
                if storedEnergy != energy
                {
                    self.energy = [Energy]()
                    break
                }
            }
        }
        
        self.energy.append(energy)
        delegate?.energyDidUpdate(self)
    }
    
    // Game is in progress
    var hasStarted: Bool
    
    // Level of game
    var level: Int
    
    // Player's score
    var score: Int
    
    // Energy gathered by player -- max 4
    var energy: [Energy]
    
    // Stage of 5 in each level, depends on number of viruses remaining
    var stage: Int
    
    // Represents the playing field
    var field: Field!
    
    // Responder for controlling the scene to draw on screen
    var delegate: GameDelegate?
    
    var charge: Int
}