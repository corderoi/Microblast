//
//  Virus.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation

// Virus /////////////////////////////////////////////////////////////////////

class Virus
{
    init(HP: Int = 1, positionX: Int, positionY: Int, speed: Int = 1, name: String = "vredstar", id: Int, field: Field, animationScheme: [Int] = [1, 2, 3, 4, 3, 2, 1, 5, 6, 7, 8, 7, 6, 5], score: Int = 90, zPlane: Int = -1)
    {
        self.HP = HP
        self.positionX = positionX
        self.positionY = positionY
        self.speed = speed
        self.name = name
        self.id = id
        self.animationScheme = animationScheme
        self.field = field
        self.score = score
        self.zPlane = zPlane
    }
    
    func wasHit()
    {
        --self.HP
    }
    
    func die()
    {
    }
    
    func isDead() -> Bool
    {
        return HP == 0
    }
    
    func attack()
    {
        // Do nothing for now!
    }
    
    func tryShoot()
    {
        var canShoot = true
        
        for i in 0 ..< field.viruses.count {
            if let virus = field.viruses[i] {
                if absolute(virus.positionX - self.positionX) < virusDimensionsWithMargin.0 / 2 {
                    if Float(self.positionY - virus.positionY) < Float(virusDimensionsWithMargin.1) * 1.5
                    && Float(self.positionY - virus.positionY) > 0 {
                        canShoot = false
                        break
                    }
                }
            }
        }
        
        if canShoot
        {
            shoot()
        }
    }
    
    func shoot()
    {
        let newAntigen = Antigen(positionX: self.positionX, positionY: self.positionY - Int(VirusSize.height) / 2, virus: self)
        field.antigens.append(newAntigen)
        field.game.delegate?.antigenDidAppear(self, antigen: newAntigen)
    }
    
    func getEnergy() -> Energy
    {
        return .RedEnergy
    }
    
    func setZPlaneMain()
    {
        zPlane = 0
    }
    
    var HP: Int
    var positionX: Int
    var positionY: Int
    var speed: Int
    var name: String
    var animationScheme: [Int]
    var id: Int
    var field: Field!
    var score: Int
    var zPlane: Int
}

class BlueStar: Virus
{
    init(positionX: Int, positionY: Int, id: Int, field: Field)
    {
        super.init(positionX: positionX, positionY: positionY, name: "vbluestar", id: id, field: field, score: 100)
    }
    
    override func shoot()
    {
        let newAntigen = Snow(positionX: self.positionX, positionY: self.positionY - Int(VirusSize.height) / 2, virus: self)
        field.antigens.append(newAntigen)
        field.game.delegate?.antigenDidAppear(self, antigen: newAntigen)
    }
    
    override func getEnergy() -> Energy {
        return .BlueEnergy
    }
}

class GreenStar: Virus
{
    init(positionX: Int, positionY: Int, id: Int, field: Field)
    {
        super.init(positionX: positionX, positionY: positionY, name: "vgreenstar", id: id, field: field, score: 100)
    }
    
    override func shoot()
    {
        let newAntigen = Slash(positionX: self.positionX, positionY: self.positionY - Int(VirusSize.height) / 2, virus: self)
        field.antigens.append(newAntigen)
        field.game.delegate?.antigenDidAppear(self, antigen: newAntigen)
    }
    
    override func getEnergy() -> Energy
    {
        return .GreenEnergy
    }
}

class GoldStar: Virus
{
    init(positionX: Int, positionY: Int, id: Int, field: Field)
    {
        super.init(positionX: positionX, positionY: positionY, name: "vgoldstar", id: id, field: field, score: 100)
    }
    
    override func shoot()
    {
        let newAntigen = Zap(positionX: self.positionX, positionY: self.positionY - Int(VirusSize.height) / 2, virus: self)
        field.antigens.append(newAntigen)
        field.game.delegate?.antigenDidAppear(self, antigen: newAntigen)
    }
    
    override func getEnergy() -> Energy
    {
        return .GoldEnergy
    }
}

class Amoeba: Virus
{
    init(positionX: Int, positionY: Int, id: Int, field: Field)
    {
        super.init(positionX: positionX, positionY: positionY, name: "amoeba", id: id, field: field, animationScheme: [1, 2, 3, 4, 3, 2, 1, 5, 6, 7, 6, 5], score: 100)
    }
    
    override func die()
    {
        
    }
    
    override func getEnergy() -> Energy
    {
        return .SilverEnergy
    }
}