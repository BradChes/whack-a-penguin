//
//  WhackSlot.swift
//  whack-a-penguin
//
//  Created by Bradley Chesworth on 26/03/2020.
//  Copyright © 2020 Brad Chesworth. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    var sprite: SKSpriteNode!
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        guard let mudNode = SKEmitterNode(fileNamed: "mud.sks") else { return }
        mudNode.position = sprite.position
        sprite.addChild(mudNode)
        
        let delay = SKAction.wait(forDuration: 0.25)
        let notVisible = SKAction.run {
            mudNode.removeFromParent()
        }
        
        let sequence = SKAction.sequence([delay, notVisible])
        charNode.run(sequence)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }

        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        guard let smokeNode = SKEmitterNode(fileNamed: "smoke.sks") else { return }
        smokeNode.position = charNode.position
        addChild(smokeNode)
       
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in
            self?.isVisible = false
            smokeNode.removeFromParent()
        }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
}
