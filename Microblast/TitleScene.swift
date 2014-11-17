//
//  TitleScene.swift
//  Microblast
//
//  Created by Ian Cordero on 11/16/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene
{
    override init(size: CGSize)
    {
        super.init(size: size)
        
        backgroundColor = SKColor.blackColor()
        view?.presentScene(self)
    }
    
    override func update(currentTime: NSTimeInterval)
    {
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}