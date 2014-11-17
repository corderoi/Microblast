//
//  PreviewScene.swift
//  Microblast
//
//  Created by Ian Cordero on 11/16/14.
//  Copyright (c) 2014 Ian Cordero. All rights reserved.
//

import Foundation
import SpriteKit

class PreviewScene: SKScene
{
    var previewTicks = 0
    var previewViewLabelText = ["", "", "", ""]
    var labels = [UILabel]()
    var executeThisWhenDone: (() -> ())!
    
    init(size: CGSize, labels: [UILabel], callback: (() -> ()))
    {
        super.init(size: size)
        
        for i in 0 ..< labels.count {
            self.labels.append(labels[i])
        }
        
        backgroundColor = SKColor.greenColor()
        drawPreview()
        view?.presentScene(self)
        
        executeThisWhenDone = callback
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        // Update preview text
        if previewTicks < count(PreviewText[0]) {
            if let myLetter = getLetter(previewTicks, PreviewText[0]) {
                previewViewLabelText[0].append(myLetter)
            }
            labels[0].text = previewViewLabelText[0]
        } else if previewTicks < count(PreviewText[0]) + count(PreviewText[1]) {
            if let myLetter = getLetter(previewTicks - count(PreviewText[0]), PreviewText[1]) {
                previewViewLabelText[1].append(myLetter)
            }
            labels[1].text = previewViewLabelText[1]
        } else if previewTicks < count(PreviewText[0]) + count(PreviewText[1]) + count(PreviewText[2]) {
            if let myLetter = getLetter(previewTicks - count(PreviewText[0]) - count(PreviewText[1]), PreviewText[2]) {
                previewViewLabelText[2].append(myLetter)
            }
            labels[2].text = previewViewLabelText[2]
        } else if previewTicks < PreviewTextSize {
            if let myLetter = getLetter(previewTicks - count(PreviewText[0]) - count(PreviewText[1]) - count(PreviewText[2]), PreviewText[3]) {
                previewViewLabelText[3].append(myLetter)
            }
            labels[3].text = previewViewLabelText[3]
        }
        
        previewTicks++
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        executeThisWhenDone()
    }
    
    func drawPreview()
    {
        let centerPoint = CGPoint(x: size.width / 2, y: size.height / 2)
        let headsUpPoint = CGPoint(x: 0, y: size.height / 6)
        
        let previewNode = SKSpriteNode(imageNamed: "levelpreview")
        previewNode.size = size
        previewNode.position = centerPoint
        previewNode.zPosition = -998
        
        let previewGridNode = SKSpriteNode(imageNamed: "previewgrid")
        previewGridNode.size = CGSize(width: 200, height: 200)
        previewGridNode.position = headsUpPoint
        //previewGridNode.zPosition = -997
        
        let silhouetteNode = SKSpriteNode(imageNamed: "vredstar-silhouette")
        silhouetteNode.size = CGSize(width: 124, height: 124)
        silhouetteNode.position = headsUpPoint
        //silhouetteNode.zPosition = -996
        configureAnimationLoop(silhouetteNode, [1, 2, 3, 4, 3, 2, 1, 5, 6, 7, 8, 7, 6, 5], "vredstar-silhouette", SpeedConfig[0].virusAnimationSpeed)
        
        addChild(previewNode)
        previewNode.addChild(previewGridNode)
        previewNode.addChild(silhouetteNode)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}