//
//  Utilities.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import AVFoundation
import SpriteKit

// Auxiliary /////////////////////////////////////////////////////////////////

// random()
// Return a random number from 0 to number-1, inclusive.

func random(number: Int) -> Int
{
    return Int(arc4random_uniform(UInt32(number)))
}

// absolute()
// Returns positive magnitude for signed integers

func absolute(number: Int) -> Int
{
    return number < 0 ? -number : number
}

func renderCoordinates(x: Int, y: Int, deviceWidth: Int = 375, deviceHeight: Int = 667) -> (Int, Int)
{
    return (x * deviceWidth / 900, y * deviceHeight / 1600)
}

// pointForLayout()
// Convert an object's array-style JI ([J][I]) coordinates, which are relative
// to the objects themselves, to the (X, Y) coordinate system of a rendering
// map.

func pointForLayout(JI: Int) -> CGPoint
{
    let renderWidth = fieldDimensions.0
    let renderHeight = fieldDimensions.1
    let objectCols = numCols
    let spacingX = virusDimensionsWithMargin.0
    let spacingY = virusDimensionsWithMargin.1
    
    let I = JI % numCols
    let J = JI / numCols
    
    let startingX = (renderWidth - objectCols * spacingX) / 2 + spacingX / 2
    let startingY = renderHeight - spacingY - InnerMargin - StatusMargin
    
    let x = startingX + spacingX * I
    let y = startingY - spacingY * J
    
    // DEBUG
    //println("Point \(JI) to (\(x), \(y))")
    
    return CGPointMake(CGFloat(x), CGFloat(y))
}

func intArrayContains(item: Int, array: [Int]) -> Bool
{
    for i in 0 ..< array.count {
        if item == array[i] {
            return true
        }
    }
    
    return false
}

func configureAnimationLoop(node: SKSpriteNode, scheme: [Int], name: String, interval: NSTimeInterval)
{
    var textures: [SKTexture]!
    textures = [SKTexture]()
    for i in scheme {
        textures.append(SKTexture(imageNamed: "\(name)-\(i)"))
    }
    node.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: interval)))
}