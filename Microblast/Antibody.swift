//
//  Antibody.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import AVFoundation

// Antibody //////////////////////////////////////////////////////////////////

class Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1), priority: Int = 1)
    {
        self.positionX = positionX
        self.positionY = positionY
        self.wCell = wCell
        self.direction = direction
        speed = 25
        self.priority = priority
    }
    
    func die()
    {
        // DEBUG
        //println("Antibody self-destructing")
        //wCell?.antibodies = [Antibody]()
    }
    
    var positionX: Int
    var positionY: Int
    var wCell: WhiteBloodCell?
    var direction: CGPoint
    var speed: Int
    var priority: Int
}

class Piercing: Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1))
    {
        super.init(positionX: positionX, positionY: positionY, wCell: wCell, direction: direction, priority: 4)
    }
}

class HorizontalLeft: Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1))
    {
        super.init(positionX: positionX, positionY: positionY, wCell: wCell, direction: direction, priority: 3)
    }
    
    override func die()
    {
        if let whiteBloodCell = wCell {
            let newAntibody = Piercing(positionX: positionX, positionY: positionY, wCell: whiteBloodCell, direction: CGPoint(x: -1, y: 0))
            whiteBloodCell.antibodies.append(newAntibody)
            
            whiteBloodCell.field?.game?.delegate?.antibodyDidAppear(whiteBloodCell.field!.game, antibody: newAntibody)
        }
    }
}

class HorizontalRight: Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1))
    {
        super.init(positionX: positionX, positionY: positionY, wCell: wCell, direction: direction, priority: 3)
    }
    
    override func die()
    {
        if let whiteBloodCell = wCell {
            let newAntibody = Piercing(positionX: positionX, positionY: positionY, wCell: whiteBloodCell, direction: CGPoint(x: 1, y: 0))
            whiteBloodCell.antibodies.append(newAntibody)
            
            whiteBloodCell.field?.game?.delegate?.antibodyDidAppear(whiteBloodCell.field!.game, antibody: newAntibody)
        }
    }
}

class DiagonalShot: Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1))
    {
        super.init(positionX: positionX, positionY: positionY, wCell: wCell, direction: direction, priority: 3)
    }
    
    override func die()
    {
        if let whiteBloodCell = wCell {
            let newAntibodyLeft = DiagonalSplit(positionX: positionX, positionY: positionY, wCell: whiteBloodCell, direction: CGPoint(x: -1, y: 1))
            whiteBloodCell.antibodies.append(newAntibodyLeft)
            
            whiteBloodCell.field?.game?.delegate?.antibodyDidAppear(whiteBloodCell.field!.game, antibody: newAntibodyLeft)
            
            let newAntibodyRight = DiagonalSplit(positionX: positionX, positionY: positionY, wCell: whiteBloodCell, direction: CGPoint(x: 1, y: 1))
            whiteBloodCell.antibodies.append(newAntibodyRight)
            
            whiteBloodCell.field?.game?.delegate?.antibodyDidAppear(whiteBloodCell.field!.game, antibody: newAntibodyRight)
        }
    }
}

class DiagonalSplit: Antibody
{
    init(positionX: Int, positionY: Int = 0, wCell: WhiteBloodCell, direction: CGPoint = CGPoint(x: 0, y: 1))
    {
        super.init(positionX: positionX, positionY: positionY, wCell: wCell, direction: direction, priority: 4)
    }
}