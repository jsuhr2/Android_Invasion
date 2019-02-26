//
//  GameScene.swift
//  CS441Project3
//
//  Created by Jasper Suhr on 2/26/19.
//  Copyright © 2019 Jasper Suhr. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "space")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        let madden = SKSpriteNode(imageNamed: "Madden_Glasses")
        madden.setScale(3)
        madden.position = CGPoint(x: self.size.width/2, y: self.size.height/5)
        madden.zPosition = 2
        self.addChild(madden)
    }
    
}
