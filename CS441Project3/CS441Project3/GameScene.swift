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
    
    let madden = SKSpriteNode(imageNamed: "Madden_Glasses")
    
    let gameArea: CGRect
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {

        let background = SKSpriteNode(imageNamed: "space")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
 
        backgroundColor = SKColor.white
        madden.setScale(2.5)
        madden.position = CGPoint(x: size.width/2, y: size.height/5)
        madden.zPosition = 2
        addChild(madden)
    }
    
    func fire(){
        let blast = SKSpriteNode(imageNamed: "apple")
        blast.setScale(0.023)
        blast.position = madden.position
        blast.zPosition = 1
        self.addChild(blast)
        
        let moveBlast = SKAction.moveTo(y: self.size.height+blast.size.height, duration: 1)
        let deleteBlast = SKAction.removeFromParent()
        let blastSequence = SKAction.sequence([moveBlast, deleteBlast])
        blast.run(blastSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            madden.position.x += amountDragged
            
            if madden.position.x > gameArea.maxX - madden.size.width/2{
                madden.position.x = gameArea.maxX - madden.size.width/2
            }
            if madden.position.x < gameArea.minX + madden.size.width/2{
                madden.position.x = gameArea.minX + madden.size.width/2
            }
        }
    }
    
}
