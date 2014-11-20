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
    func playerDidAppear(game: Game, player: WhiteBloodCell)
    
    func playerDidMove(game: Game, player: WhiteBloodCell)
    
    func playerDidDie(game: Game)
    
    func antibodyDidAppear(game: Game, antibody: Antibody)
    
    func antibodiesDidMove(game: Game)
    
    func playerDidShoot(type: AntibodyType)
    
    func antibodyDidDie(whichAntibody: Int)
    
    func virusDidAppear(game: Game, virus: Virus, afterTransition: (() -> ()))
    
    func virusesDidMove(game: Game)
    
    func virusesDidDescend(game: Game)
    
    func virusReachedBottomOfField(game: Game)
    
    func virusReachedEdgeOfField(game: Game)
    
    func virusDidDie(game: Game, whichVirus: Int)
    
    func antigenDidAppear(virus: Virus, antigen: Antigen)
    
    func antigensDidMove(game: Game)
    
    func antigenDidExplode()
    
    func antigenDidDie(whichVirus: Int, whichAntigen: Int)
    
    func playerKilledAllViruses(game: Game)
    
    func levelDidEnd(game: Game, transition: (() -> ()))
    
    func levelDidBegin(game: Game)
    
    func scoreDidUpdate(game: Game)
    
    func levelDidUpdate(game: Game)
    
    func chargeDidUpdate(game: Game)
    
    func energyDidUpdate(game: Game)
    
    func gameDidEnd()
}
