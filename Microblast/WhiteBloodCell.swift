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
        self.angle = CGPoint(x: 0.0, y: 1.0)
        self.field = field
        self.velocity = 0
        maxAntibodies = 1
        accelerationArray = [Double]()
        antibodies = [Antibody]()
    }
    
    func tryShoot()
    {
        if antibodies.count < maxAntibodies {
            shoot()
        }
    }
    
    /*func trySpecial(aimTowards: CGPoint)
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
    }*/
    
    func trySpecial()
    {
        if let energyType = specialType() {
            var newAntibody: Antibody
            
            let direction = angle
            
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
            field!.game!.delegate!.playerDidShoot(AntibodyType.Special1)
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
        if --HP == 0 {
            field!.game.delegate!.playerDidDie(field!.game)
        }
    }
    
    func isDead() -> Bool
    {
        return HP == 0
    }
    
    // DEBUG
    /*func tryShoot(aimTowards: CGPoint)
    {
        if antibodies.count < maxAntibodies {
            shoot(aimTowards)
        }
    }*/
    
    func move(acceleration: Double)
    {
        var newPositionX: Int
        
        /* 
        let maxTilt = 0.5
        
        var tilt = data.acceleration.x
        if tilt > maxTilt {
        tilt = maxTilt
        } else if tilt < -maxTilt {
        tilt = -maxTilt
        }
        
        let maxDistance = fieldDimensions.0 / 2
        let centerPoint = fieldDimensions.0 / 2
        player.positionX = Int(Double(centerPoint) + Double(tilt / maxTilt) * Double(maxDistance))
        player.move(0)
        */
        
        accelerationArray.append(acceleration)
        
        if accelerationArray.count < NumberOfAccelerationSamples {
            return
        } else {
            var averageAcceleration = 0.0
            for value in accelerationArray {
                averageAcceleration += value
            }
            averageAcceleration /= Double(NumberOfAccelerationSamples)
            
            let maxTilt = 0.4
            var tilt = averageAcceleration
            if tilt > maxTilt {
                tilt = maxTilt
            } else if tilt < -maxTilt {
                tilt = -maxTilt
            }
            
            let maxDistance = fieldDimensions.0 / 2
            let centerPoint = fieldDimensions.0 / 2
            
            //let moveLimit = 5
            newPositionX = Int(Double(centerPoint) + Double(tilt / maxTilt) * Double(maxDistance) + 0.5)
            /*if newPositionX - positionX > moveLimit {
                newPositionX = positionX + moveLimit
            } else if positionX - newPositionX > moveLimit {
                newPositionX = positionX - moveLimit
            }*/
            
            positionX = newPositionX
            
            accelerationArray.removeAtIndex(0)
        }
        
        //let distance = 0
        
        /*positionX += distance + velocity
        velocity += distance*/
        angle = angle + CGPoint(x: newPositionX - positionX, y: 0)
        angle = angle.normalized()/*
        
        // Adjust position for boundary
        if positionX < 0 {
            positionX = 0
            velocity = 0
        } else if self.positionX > fieldDimensions.0 {
            positionX = fieldDimensions.0
            velocity = 0
        }*/
        
        // Adjust angle for maximum tilt
        if angle.x < -sqrt(2.0) / 2.0 {
            angle = CGPointMake(-1, 1).normalized()
        } else if angle.x > sqrt(2.0) / 2.0 {
            angle = CGPointMake(1, 1).normalized()
        }
        
        // DEBUG
        //println("Angle is \(angle)")
        
        field?.game.delegate?.playerDidMove(field!.game, player: self)
    }
    
    // DEBUG
    /*func shoot(aimTowards: CGPoint)
    {
        // DEBUG
        //println("Aim towards \(aimTowards)")
        
        let renderSelfVector = renderCoordinates(self.positionX, self.positionY)
        let selfDirectionVector = CGPoint(x: renderSelfVector.0, y: renderSelfVector.1)
        let direction = aimTowards - selfDirectionVector
        
        let newAntibody = Antibody(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self, direction: direction.normalized())
        
        antibodies.append(newAntibody)
        field?.game?.delegate?.antibodyDidAppear(field!.game!, antibody: newAntibody)
    }*/
    
    func shoot()
    {
        // DEBUG
        //println("Pew!")
        let newAntibody = Antibody(positionX: self.positionX, positionY: self.positionY + Int(PlayerSize.height) / 2, wCell: self/*, direction: angle*/)
        
        // DEBUG
        //println("Shot in direction \(angle)")
        
        // DEBUG
        //println("Antibody (\(self.positionX), \(self.positionY))")
        
        antibodies.append(newAntibody)
        field!.game!.delegate!.playerDidShoot(AntibodyType.Regular)
        field!.game!.delegate!.antibodyDidAppear(field!.game!, antibody: newAntibody)
    }
    
    var HP: Int
    var positionX: Int
    var positionY: Int
    var velocity: Int
    var angle: CGPoint
    var field: Field?
    var antibodies: [Antibody?]
    var maxAntibodies: Int
    var accelerationArray: [Double]
}
