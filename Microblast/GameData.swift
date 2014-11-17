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
        if count == whichLetter {
            return letter
        }
        count++
    }
    return nil
}

let PreviewTextSize = count(PreviewText[0]) + count(PreviewText[1]) + count(PreviewText[2]) + count(PreviewText[3])

let SpeedConfig: [(tickLength: NSTimeInterval, moveDuration: NSTimeInterval, step: Int, virusAnimationSpeed: NSTimeInterval)] = [
    (600, 0.25, 50, 0.12),
    (300, 0.125, 50, 0.10),
    (100, 0.0625, 50, 0.08),
    (12.5, 0.005, 50, 0.06),
    (12.5, 0.0025, 100, 0.04)
]

let LevelPauseDuration = NSTimeInterval(1.5)

let VirusSize = CGSize(width: 55, height: 55)
let VirusGridSpacing = CGSize(width: 30, height: 30)
let PlayerSize = CGSize(width: 55, height: 55)

let fieldDimensions = (900, 1600) // (newWidth: oldWidth * 375 / 900, newHeight: oldHeight * 667 / 1600)
let virusDimensionsWithMargin = (100, 100)
let virusDimensions = (55, 55)
let antigenDimensions = (20, 40)
let AntibodyDimensions = (40, 45)
let numCols = 8
let numRows = 5
let numSlotsPerLevel = numCols * numRows
let numLevels = 11 // same as (gameModel.count / numSlotsPerLevel)

let OuterMargin = virusDimensionsWithMargin.0 * 2
let InnerMargin = virusDimensionsWithMargin.0

let StatusMargin = 50

let LevelClearScore = 1000

enum Energy: Printable
{
    case RedEnergy, BlueEnergy, GreenEnergy, GoldEnergy, BlackEnergy
    
    var description: String {
        switch self {
        case .RedEnergy:
            return "RedEnergy"
        case .BlueEnergy:
            return "BlueEnergy"
        case .GreenEnergy:
            return "GreenEnergy"
        case .GoldEnergy:
            return "GoldEnergy"
        case .BlackEnergy:
            return "BlackEnergy"
        }
    }
}

let PowerThreshold = 15

// [gameModel]
// The enemy layout of each level. 0 for empty, 1-9 for virus enemies.

// 1: vredstar
// 2: vbluestar
// 3: vgreenstar
// 4: vgoldstar
// 5:
// 6:
// 7: amoeba
// 8: 
// 9:

let gameModel = [
    /*1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,*/
    
    /*0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 0, 1, 1, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,*/
    
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    1, 1, 0, 1, 1, 0, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    /*0, 0, 0, 2, 2, 0, 0, 0,
    0, 0, 0, 2, 2, 0, 0, 0,
    0, 0, 0, 2, 2, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,*/
    
    2, 2, 2, 0, 0, 2, 2, 2,
    2, 2, 0, 2, 2, 0, 2, 2,
    2, 0, 2, 2, 2, 2, 0, 2,
    0, 2, 2, 0, 0, 2, 2, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    3, 3, 3, 3, 3, 3, 3, 3,
    0, 3, 3, 3, 3, 3, 3, 0,
    0, 3, 3, 3, 3, 3, 3, 0,
    3, 0, 3, 0, 0, 3, 0, 3,
    0, 0, 0, 0, 0, 0, 0, 0,
    
    4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4, 4, 4,
    0, 4, 0, 4, 4, 0, 4, 0,
    0, 0, 0, 0, 0, 0, 0, 0,

    1, 2, 3, 4, 1, 2, 3, 4,
    2, 3, 4, 1, 2, 3, 4, 1,
    3, 4, 1, 2, 3, 4, 1, 2,
    4, 1, 2, 3, 4, 1, 2, 3,
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
