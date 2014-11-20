//
//  Antigen.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation

// Antigen ///////////////////////////////////////////////////////////////////////

class Antigen
{
    init(positionX: Int, positionY: Int, virus: Virus, speed: Int = 8, name: String = "pin", animationSequence: [Int] = [1], priority: Int = 1)
    {
        self.positionX = positionX
        self.positionY = positionY
        self.virus = virus
        directionX = 0
        directionY = -1
        self.speed = speed
        self.priority = priority
        self.animationSequence = animationSequence
        self.name = name
    }
    
    var directionX: Int
    var directionY: Int
    var positionX: Int
    var positionY: Int
    var speed: Int
    var virus: Virus?
    var priority: Int
    var name: String
    var animationSequence: [Int]
}

class Snow: Antigen
{
    init(positionX: Int, positionY: Int, virus: Virus)
    {
        super.init(positionX: positionX, positionY: positionY, virus: virus, speed: 4, name: "snow", animationSequence: [1, 2, 3, 2])
    }
}

class Slash: Antigen
{
    init(positionX: Int, positionY: Int, virus: Virus)
    {
        super.init(positionX: positionX, positionY: positionY, virus: virus, speed: 3, name: "slash", animationSequence: [1, 2, 3, 2], priority: 2)
    }
}

class Zap: Antigen
{
    init(positionX: Int, positionY: Int, virus: Virus)
    {
        super.init(positionX: positionX, positionY: positionY, virus: virus, speed: 14, name: "zap", animationSequence: [1, 2, 3, 2])
    }
}