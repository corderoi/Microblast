//
//  GameDelegate.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation

// GameDelegate

protocol GameDelegate {
    // Invoked when the current round of Swiftris ends
    //func gameDidEnd(swiftris: Swiftris)
    
    // Invoked immediately after a new game has begun
    //func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    //func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    //func gameShapeDidMove(swiftris: Swiftris)
        
    func playerDidAppear(game: Game, player: WhiteBloodCell)
    
    func antibodyDidAppear(game: Game, antibody: Antibody)
    
    func antibodiesDidMove(game: Game)
    
    func antibodyDidDie(whichAntibody: Int)
    
    func virusDidAppear(game: Game, virus: Virus, afterTransition: (() -> ()))
    
    func virusesDidMove(game: Game)
    
    func virusesDidDescend(game: Game)
    
    func virusReachedBottomOfField(game: Game)
    
    func virusReachedEdgeOfField(game: Game)
    
    func virusDidDie(game: Game, whichVirus: Int)
    
    func antigenDidAppear(virus: Virus, antigen: Antigen)
    
    func antigensDidMove(game: Game)
    
    func antigenDidDie(whichVirus: Int, whichAntigen: Int)
    
    func playerKilledAllViruses(game: Game)
    
    func levelDidEnd(game: Game, transition: (() -> ()))
    
    func levelDidBegin(game: Game)
    
    func scoreDidUpdate(game: Game)
    
    func levelDidUpdate(game: Game)
    
    func chargeDidUpdate(game: Game)
    
    func energyDidUpdate(game: Game)
    
    func gameDidEnd()
    
    // Invoked when the falling shape has changed its location after being dropped
    //func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    //func gameDidLevelUp(swiftris: Swiftris)
}
