//
//  GameScene.swift
//  ZombieConga
//
//  Created by Admin on 24/01/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let playableRect: CGRect
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let background = SKSpriteNode(imageNamed: "background1")
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombieMovePointsPersec:CGFloat = 480.0
    var velocity = CGPoint.zero
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    var lastTouchLocation: CGPoint?
    
    override init(size: CGSize) {
      let maxAspectRatio:CGFloat = 16.0/9.0 // 1
      let playableHeight = size.width / maxAspectRatio // 2
      let playableMargin = (size.height-playableHeight)/2.0 // 3
      playableRect = CGRect(x: 0, y: playableMargin,
        width: size.width,
        height: playableHeight) // 4
      super.init(size: size) // 5
    }
    
    
    required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented") // 6
    }
    
    func debugDrawPlayableArea() {
      let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
      shape.path = path
        shape.strokeColor = SKColor.red
      shape.lineWidth = 4.0
      addChild(shape)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
      if zombie.position.x <= bottomLeft.x {
        zombie.position.x = bottomLeft.x
        velocity.x = -velocity.x
      }
      if zombie.position.x >= topRight.x {
        zombie.position.x = topRight.x
        velocity.x = -velocity.x
      }
      if zombie.position.y <= bottomLeft.y {
        zombie.position.y = bottomLeft.y
        velocity.y = -velocity.y
      }
      if zombie.position.y >= topRight.y {
        zombie.position.y = topRight.y
        velocity.y = -velocity.y
      }
    }
    fileprivate func addBackground() {
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5,y:0.5)
        background.zPosition = -1
        addChild(background)
    }
    
    fileprivate func addZombie() {
        zombie.position = CGPoint(x: 300, y: 300)
        addChild(zombie)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt =  currentTime - lastUpdateTime
        }else{
            dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
        //moveSprite(sprite: zombie, velocity: CGPoint(x: zombieMovePointsPersec, y: 0))
        if let lastTouchLocation = lastTouchLocation{
            let diff = lastTouchLocation - zombie.position
            if (diff.length() <= zombieMovePointsPersec * CGFloat(dt)){
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
            } else{
                moveSprite(sprite: zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
    }
    func rotateSprite(_ sprite: SKSpriteNode, direction: CGPoint,
                         rotateRadiansPerSec: CGFloat) {
           let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2:
               velocity.angle)
           let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt),
                                    abs(shortest))
           sprite.zRotation += shortest.sign() * amountToRotate
       }
    
    
    override func didMove(to view: SKView) {
        
        addBackground()
        addZombie()
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(spawnEnemy),
                               SKAction.wait(forDuration: 2)])))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(spawnCat),
                               SKAction.wait(forDuration: 1)])))
        //debugDrawPlayableArea() To see the playable area.
        
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x:velocity.x * CGFloat(dt), y:velocity.y * CGFloat(dt))
        print("Amount to move:\(amountToMove)")
        sprite.position = CGPoint(x:sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
        
    }
    
    func moveZombieToward(location:CGPoint) {
        let offset = CGPoint(x:location.x - zombie.position.x , y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y*offset.y))
        let direction = CGPoint(x:offset.x/CGFloat(length), y:offset.y/CGFloat(length))
        velocity = CGPoint(x: direction.x*zombieMovePointsPersec, y: direction.y*zombieMovePointsPersec)
        
    }
    fileprivate func HandleTouches(_ touch: UITouch) {
        let touchLocation = touch.location(in: self)
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            
            return
        }
        HandleTouches(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            
            return
        }
        HandleTouches(touch)
    }
    
    
}

extension GameScene{
    func spawnEnemy() {
      let enemy = SKSpriteNode(imageNamed: "enemy")
      enemy.position = CGPoint(
                  x: size.width + enemy.size.width/2,
                  y: size.height/2)
        let actionMove = SKAction.move(to: CGPoint(
            x: -enemy.size.width/2, y: enemy.position.y),
            duration: 2.0)
        enemy.run(actionMove)
      addChild(enemy)
    }
    
    func spawnCat(){
          let cat = SKSpriteNode(imageNamed: "cat")
          cat.position = CGPoint(
              x: CGFloat.random(
                  min: playableRect.minX,
                  max: playableRect.maxX),
              y: CGFloat.random(
                  min: playableRect.minY,
                  max: playableRect.maxY)
          )
        

          cat.setScale(0)
          self.addChild(cat)
          
          let appear = SKAction.scale(to: 1, duration: 0.5)
          cat.zRotation = -π/16
          
          let leftWiggle = SKAction.rotate(byAngle: π/8, duration: 0.5)
          let rightWiggle = leftWiggle.reversed()
          let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
          
          
          let scaleUp = SKAction.scale(to: 1.2, duration: 0.25)
          let scaleDown = scaleUp.reversed()
          let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
          
          let group = SKAction.group([fullWiggle, fullScale])
          let groupWait = SKAction.repeat(group, count: 10)
          
          let disappear = SKAction.scale(to: 0, duration: 0.5)
          let removeFromParent = SKAction.removeFromParent()
          let actions = [appear, groupWait, disappear, removeFromParent]
          cat.run(SKAction.sequence(actions))
      }
      
}
