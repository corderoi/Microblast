//
//  Physics.swift
//  Microblast
//
//  Created by Ian Cordero on 11/12/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import AVFoundation

// Physics ///////////////////////////////////////////////////////////////////

struct PhysicsCategory
{
    static let None       : UInt32 = 0
    static let Virus      : UInt32 = 1
    static let Antibody   : UInt32 = 1 << 1 // 0b10
    static let WCell      : UInt32 = 1 << 2 // 0b100
    static let Antigen        : UInt32 = 1 << 3 // 0b1000
    static let Shield     : UInt32 = 1 << 4 // 0b10000
    static let Ground     : UInt32 = 1 << 5 // 0b100000
    static let OuterBound : UInt32 = 1 << 6 // 0b1000000
    static let All        : UInt32 = UInt32.max
                       // UInt32   0bXXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX
                       //            1B (8b)   2B (16b)  3B (24b)  4B (32b)
                       //          1 << 31
}

// Vector math ///////////////////////////////////////////////////////////////

func +(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat
{
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint
{
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}
