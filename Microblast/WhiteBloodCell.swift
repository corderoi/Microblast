//
//  WhiteBloodCell.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import AVFoundation

// WhiteBloodCell ////////////////////////////////////////////////////////////

class WhiteBloodCell
{
    init(HP: Int = 1, positionX: Int = fieldDimensions.0 / 2, positionY: Int = virusDimensionsWithMargin.1 / 2, field: Field)
    {
        self.HP = HP
        self.positionX = positionX
        self.positionY = positionY
        self.angle = CGPointMake(0.0, 1.0)
        self.field = field
        maxAntibodies = 1
        antibodies = [Antibody]()
    }
    
    func tryShoot()
    {
        if antibodies.count < maxAntibodies {
            shoot()
        }
    }
    
    func trySpecial(aimTowards: CGPoint)
    {
        if let energyType = specialType() {
            var newAntibody: Antibody
            
            let renderSelfVector = renderCoordinates(self.positionX, self.positionY)
            let selfDirectionVector = CGPoint(x: renderSelfVector.0, y: renderSelfVector.1)
            let direction = aimTowards - selfDirectionVector
            
            switch energyType {
            case .BlueEnergy:
                newAntibody = HorizontalLeft(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
            case .GreenEnergy:
                newAntibody = HorizontalRight(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
            case .GoldEnergy:
                newAntibody = DiagonalShot(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
            default:
                newAntibody = Piercing(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
            }
            
            antibodies.append(newAntibody)
            field?.game?.delegate?.antibodyDidAppear(field!.game!, antibody: newAntibody)
        }
    }
    
    func hasSpecial() -> Bool
    {
        if field?.game.energy.count == 4 {
            return true
        } else {
            return false
        }
    }
    
    func specialType() -> Energy?
    {
        if field?.game.energy.count > 0 {
            return field?.game.energy[0]
        } else {
            return nil
        }
    }
    
    func wasHit()
    {
        HP--
    }
    
    func isDead() -> Bool
    {
        return HP == 0
    }
    
    // DEBUG
    func tryShoot(aimTowards: CGPoint)
    {
        //if antibodies.count < maxAntibodies {
            shoot(aimTowards)
        //}
    }
    
    // DEBUG
    func shoot(aimTowards: CGPoint)
    {
        // DEBUG
        //println("Aim towards \(aimTowards)")
        
        let renderSelfVector = renderCoordinates(self.positionX, self.positionY)
        let selfDirectionVector = CGPoint(x: renderSelfVector.0, y: renderSelfVector.1)
        let direction = aimTowards - selfDirectionVector
        
        let newAntibody = Antibody(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
        
        antibodies.append(newAntibody)
        field?.game?.delegate?.antibodyDidAppear(field!.game!, antibody: newAntibody)
    }
    
    func shoot()
    {
        // DEBUG
        //println("Pew!")
        
        let newAntibody = Antibody(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self)
        
        // DEBUG
        //println("Antibody (\(self.positionX), \(self.positionY))")
        
        antibodies.append(newAntibody)
        field?.game?.delegate?.antibodyDidAppear(field!.game!, antibody: newAntibody)
    }
    
    var HP: Int
    var positionX: Int
    var positionY: Int
    var angle: CGPoint
    var field: Field?
    var antibodies: [Antibody?]
    var maxAntibodies: Int
}
