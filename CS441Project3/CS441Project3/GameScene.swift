//
//  GameScene.swift
//  CS441Project3
//
//  Created by Jasper Suhr on 2/14/19.
//  Copyright © 2019 Jasper Suhr. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    let madden = SKSpriteNode(imageNamed: "Madden_Glasses")
    
    let gameArea: CGRect
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Madden : UInt32 = 0b1 //1
        static let Blast : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //3
    }
    
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
        
        self.physicsWorld.contactDelegate = self

        let background = SKSpriteNode(imageNamed: "space")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
 
        backgroundColor = SKColor.white
        madden.setScale(2.5)
        madden.position = CGPoint(x: self.size.width/2, y: self.size.height/5)
        madden.zPosition = 2
        madden.physicsBody = SKPhysicsBody(rectangleOf: madden.size)
        madden.physicsBody!.affectedByGravity = false
        madden.physicsBody!.categoryBitMask = PhysicsCategories.Madden
        madden.physicsBody!.collisionBitMask = PhysicsCategories.None
        madden.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(madden)
        
        start()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var num1 = SKPhysicsBody()
        var num2 = SKPhysicsBody()
        if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            num1 = contact.bodyA
            num2 = contact.bodyB
        }else{
            num1 = contact.bodyB
            num2 = contact.bodyA
        }
        if(num1.categoryBitMask == PhysicsCategories.Madden && num2.categoryBitMask == PhysicsCategories.Enemy){
            if(num1.node != nil){
                explode(spawnPosition: num1.node!.position)
            }
            if(num2.node != nil){
                explode(spawnPosition: num2.node!.position)
            }
            num1.node?.removeFromParent()
            num2.node?.removeFromParent()
        } else if num2.node != nil{
            if(num1.categoryBitMask == PhysicsCategories.Blast && num2.categoryBitMask == PhysicsCategories.Enemy && (num2.node?.position.y)! < self.size.height){
                explode(spawnPosition: num2.node!.position)
                num1.node?.removeFromParent()
                num2.node?.removeFromParent()
            }
        }
    }
    
    func explode(spawnPosition: CGPoint){
        let e = SKSpriteNode(imageNamed: "explosion")
        e.position = spawnPosition
        e.zPosition = 3
        e.setScale(0)
        self.addChild(e)
        
        let scaleIn = SKAction.scale(to: 0.1, duration: 0.1)
        let fade = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fade, delete])
        e.run(explosionSequence)
    }
    
    func start(){
        let spawn = SKAction.run(spawnEnemy)
        let wait = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([wait, spawn])
        let spawnContinuous = SKAction.repeatForever(spawnSequence)
        self.run(spawnContinuous)
    }
    
    func spawnEnemy(){
        let startX = random(min: gameArea.minX, max: gameArea.maxX)
        let endX = random(min: gameArea.minX, max: gameArea.maxX)
        
        let start = CGPoint(x: startX, y: self.size.height * 1.1)
        let end = CGPoint(x: endX, y: -self.size.height * 0.1)
        
        let enemy = SKSpriteNode(imageNamed: "Android_Studio_icon")
        enemy.setScale(0.1)
        enemy.position = start
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Madden | PhysicsCategories.Blast
        self.addChild(enemy)
        
        let dx = end.x - start.x
        let dy = end.y - start.y
        let rotate = atan2(dy, dx) + 3.141659/2
        enemy.zRotation = rotate
        
        let moveEnemy = SKAction.move(to: end, duration: 4)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
    }
    
    func fire(){
        let blast = SKSpriteNode(imageNamed: "apple")
        blast.setScale(0.023)
        blast.position = madden.position
        blast.zPosition = 1
        blast.physicsBody = SKPhysicsBody(rectangleOf: blast.size)
        blast.physicsBody!.affectedByGravity = false
        blast.physicsBody!.categoryBitMask = PhysicsCategories.Blast
        blast.physicsBody!.collisionBitMask = PhysicsCategories.None
        blast.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
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
            let horizontalDragged = pointOfTouch.x - previousPointOfTouch.x
            madden.position.x += horizontalDragged

            let verticalDragged = pointOfTouch.y - previousPointOfTouch.y
            madden.position.y += verticalDragged

            if madden.position.x > gameArea.maxX - madden.size.width/2{
                madden.position.x = gameArea.maxX - madden.size.width/2
            }
            if madden.position.x < gameArea.minX + madden.size.width/2{
                madden.position.x = gameArea.minX + madden.size.width/2
            }

            if madden.position.y > gameArea.maxY - madden.size.height/2{
                madden.position.y = gameArea.maxY - madden.size.height/2
            }
            if madden.position.y < gameArea.minY + madden.size.height/2{
                madden.position.y = gameArea.minY + madden.size.height/2
            }
        }
    }
    
}
