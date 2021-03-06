//
//  GameData.swift
//  Microblast
//
//  Created by Ian Cordero on 11/13/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import AVFoundation

// Constants

let PreviewText = [
    "Profile Name: Common",
    "Size: 24 nm",
    "Projectile: Standard",
    "Threat: Low"
]

func count(string: String) -> Int
{
    var count = 0
    for char in string {
        count++
    }
    return count
}

func getLetter(whichLetter: Int, string: String) -> Character?
{
    var count = 0
    for letter in string {
        if count == whichLetter
        {
            return letter
        }
        count++
    }
    return nil
}

let PreviewTextSize = count(PreviewText[0]) + count(PreviewText[1]) + count(PreviewText[2]) + count(PreviewText[3])

let VerticalStep = 4

let SpeedConfig: [(tickLength: NSTimeInterval, moveDuration: NSTimeInterval, step: Int, virusAnimationSpeed: NSTimeInterval, virusAttackChance: Int)] = [
    (50, 0.25, 1, 0.12, 8),
    (40, 0.125, 4, 0.10, 16),
    (30, 0.0625, 8, 0.08, 64),
    (20, 0.005, 16, 0.06, 256),
    (20, 0.0025, 32, 0.04, 512)
]

let LevelPauseDuration = NSTimeInterval(1.5)

let VirusSize = CGSize(width: 55, height: 55)
let PlayerSize = CGSize(width: 55, height: 55)

let fieldDimensions = (900, 1600) // (newWidth: oldWidth * 375 / 900, newHeight: oldHeight * 667 / 1600)
let virusDimensionsWithMargin = (100, 100)
let virusDimensions = (Int(VirusSize.width), Int(VirusSize.height))
let antigenDimensions = (20, 40)
let AntibodyDimensions = (40, 45)
let numCols = 8
let numRows = 5
let numSlotsPerLevel = numCols * numRows

let NumberOfAccelerationSamples = 30

// [gameModel]
// The enemy layout of each level. 0 for empty, 1-9 for virus enemies.

let gameModel = [
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2,
    2, 0, 2, 2, 2, 2, 0, 2,
    2, 0, 0, 0, 0, 0, 0, 2,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    3, 3, 3, 3, 3, 3, 3, 3,
    0, 3, 3, 3, 3, 3, 3, 0,
    0, 0, 3, 3, 3, 3, 0, 0,
    0, 0, 3, 3, 3, 3, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    4, 4, 0, 0, 0, 0, 4, 4,
    0, 4, 4, 0, 0, 4, 4, 0,
    0, 0, 4, 4, 4, 4, 0, 0,
    0, 0, 0, 4, 4, 0, 0, 0,
    4, 4, 4, 4, 4, 4, 4, 4,
    
    3, 3, 3, 3, 2, 3, 3, 3,
    1, 1, 2, 2, 3, 4, 1, 0,
    2, 4, 2, 4, 4, 4, 4, 0,
    1, 2, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    1, 3, 4, 5, 5, 4, 3, 1,
    2, 2, 5, 5, 5, 5, 2, 2,
    5, 1, 3, 2, 2, 3, 1, 5,
    1, 3, 2, 4, 4, 2, 3, 1,
    1, 2, 0, 0, 1, 0, 1, 0,
    
    6, 5, 4, 3, 2, 1, 2, 3,
    3, 2, 1, 2, 3, 4, 5, 6,
    1, 6, 2, 3, 2, 3, 6, 4,
    6, 1, 3, 6, 6, 3, 1, 6,
    4, 2, 3, 4, 1, 0, 0, 4,
    
    7, 0, 7, 0, 7, 0, 7, 0,
    0, 7, 0, 7, 0, 7, 0, 7,
    7, 0, 7, 0, 7, 0, 7, 0,
    0, 7, 0, 7, 0, 7, 0, 7,
    7, 0, 7, 0, 7, 0, 7, 0,
    
    1, 8, 3, 4, 2, 8, 8, 8,
    8, 7, 8, 2, 8, 7, 8, 8,
    3, 1, 8, 8, 8, 1, 8, 8,
    8, 8, 7, 3, 4, 5, 7, 3,
    7, 8, 8, 8, 8, 7, 8, 8,
    
    9, 9, 9, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 9,
    1, 2, 3, 4, 5, 6, 7, 8,
    
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 10, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
]

let numLevels = gameModel.count / numSlotsPerLevel

let OuterMargin = virusDimensionsWithMargin.0 * 2
let InnerMargin = virusDimensionsWithMargin.0

let StatusMargin = 50

let LevelClearScore = 1000

let PowerThreshold = 30

enum AntibodyType
{
    case Regular, Special1
}

enum Energy: Printable
{
    case RedEnergy, BlueEnergy, GreenEnergy, GoldEnergy, SilverEnergy, BlackEnergy
    
    var description: String {
        switch self
        {
        case .RedEnergy:
            return "RedEnergy"
        case .BlueEnergy:
            return "BlueEnergy"
        case .GreenEnergy:
            return "GreenEnergy"
        case .GoldEnergy:
            return "GoldEnergy"
        case .SilverEnergy:
            return "SilverEnergy"
        case .BlackEnergy:
            return "BlackEnergy"
        }
    }
}

let PauseButtonSize = CGSize(width: 50.0, height: 35.0)

