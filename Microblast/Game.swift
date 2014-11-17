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
    }
    
    func start()
    {
        delegate?.playerDidAppear(self, player: field.player)
        field.addViruses()
        delegate?.levelDidBegin(self)
        hasStarted = true
    }
    
    func checkIfLevelIsOver()
    {
        if (field.viruses.count == 0 && field.antigens.count == 0) {
            delegate?.levelDidEnd(self, transition: goToNextLevel)
        }
    }
    
    func goToNextLevel() -> ()
    {
        if (++level < numLevels) {
            score += LevelClearScore
            delegate?.scoreDidUpdate(self)
            delegate?.levelDidUpdate(self)
            field.addViruses()
            delegate?.levelDidBegin(self)
        } else {
            delegate?.gameDidEnd()
        }
    }
    
    func addEnergy(energy: Energy)
    {
        if self.energy.count == 4 {
            return
        } else if self.energy.count > 0 {
            for storedEnergy in self.energy {
                if storedEnergy != energy {
                    self.energy = [Energy]()
                    break
                }
            }
        }
        self.energy.append(energy)
        delegate?.energyDidUpdate(self)
        
        // DEBUG
        //println("Got \(energy) -> \(self.energy)")
    }
    
    var hasStarted: Bool
    var level: Int
    var score: Int
    var energy: [Energy]
    var stage: Int
    var field: Field!
    var delegate: GameDelegate?
    var special: Bool = false
    var charge: Int
}