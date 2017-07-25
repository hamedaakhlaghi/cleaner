import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    // Private GameScene Properties
    
    var contentCreated = false
    var invaderMovementDirection: InvaderMovementDirection = .right
    // 2
    var timeOfLastMove: CFTimeInterval = 0.0
    // 3
    let timePerMove: CFTimeInterval = 1.0
    var invaders=[SKSpriteNode]()

  
    
    enum InvaderMovementDirection {
        case right
        case left
        case downThenRight
        case downThenLeft
        case none
    }
    
    enum InvaderType {
        case a
        case b
        case c
        
        static var size: CGSize {
            return CGSize(width: 24, height: 16)
        }
        
        static var name: String {
            return "invader"
        }
    }
    
    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    let kShipSize = CGSize(width: 30, height: 16)
    let kShipName = "ship"
    
    let motionManager = CMMotionManager()
    
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    override func didMove(to view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            motionManager.startAccelerometerUpdates()
            
        }
    }
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func createContent() {
        
        for _ in 1...20{
            
            let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")

            let height = self.view!.frame.height
            let width = self.view!.frame.width
            
            let randomPosition = CGPoint(x:CGFloat(arc4random()).truncatingRemainder(dividingBy: width),y: CGFloat(arc4random()).truncatingRemainder(dividingBy: height))
            invader.position = randomPosition
            invaders.append(invader)
            self.addChild(invader)
        }

        
        // black space color
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        //        setupInvaders()
        setupShip()
        
        self.backgroundColor = SKColor.black
    }
    
    func makeInvader(ofType invaderType: InvaderType) -> SKNode {
        // 1
        var invaderColor: SKColor
        
        switch(invaderType) {
        case .a:
            invaderColor = SKColor.red
        case .b:
            invaderColor = SKColor.green
        case .c:
            invaderColor = SKColor.blue
        }
        
        // 2
        let invader = SKSpriteNode(color: invaderColor, size: InvaderType.size)
        invader.name = InvaderType.name
        
        return invader
    }
    
    func setupInvaders() {
        // 1
        let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
        
        for row in 0..<kInvaderRowCount {
            // 2
            var invaderType: InvaderType
            
            if row % 3 == 0 {
                invaderType = .a
            } else if row % 3 == 1 {
                invaderType = .b
            } else {
                invaderType = .c
            }
            
            // 3
            let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
            
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
            
            // 4
            for _ in 1..<kInvaderColCount {
                // 5
                let invader = makeInvader(ofType: invaderType)
                invader.position = invaderPosition
                
                addChild(invader)
                
                invaderPosition = CGPoint(
                    x: invaderPosition.x + InvaderType.size.width + kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }
    
    func setupShip() {
        // 1
        let ship = makeShip()
        
        // 2
        ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
        addChild(ship)
    }
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(color: SKColor.green, size: kShipSize)
        ship.name = kShipName
        
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
        
        // 2
        ship.physicsBody!.isDynamic = true
        
        // 3
        ship.physicsBody!.affectedByGravity = false
        
        // 4
        ship.physicsBody!.mass = 0.02
        
        return ship
    }
    
    
    // Scene Update
    
    func moveInvaders(forUpdate currentTime: CFTimeInterval) {
        // 1
        if (currentTime - timeOfLastMove < timePerMove) {
            determineInvaderMovementDirection()
            return
        }
        
        // 2
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            switch self.invaderMovementDirection {
            case .right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .downThenLeft, .downThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .none:
                break
            }
            
            // 3
            self.timeOfLastMove = currentTime
        }
    }
    
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        // 1
        if let ship = childNode(withName: kShipName) as? SKSpriteNode {
            // 2
            if let data = motionManager.accelerometerData {
                // 3
                if fabs(data.acceleration.x) > 0.2 {
                    // 4 How do you move the ship?
                    ship.physicsBody!.applyForce(CGVector(dx: 5 * CGFloat(data.acceleration.x), dy: 5 * CGFloat(data.acceleration.y)))
                    for invader in self.invaders{
                        if ship.position.x > invader.position.x - 30 && ship.position.y > invader.position.y - 30 && ship.position.x < invader.position.x + 30 && ship.position.y < invader.position.y + 30 {
                            print("GAME OVER...........")
                            invader.isHidden = true
                        }
                    }
                }
                
                print("Acceleration: \(data.acceleration.x)")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        processUserMotion(forUpdate: currentTime)
        
        //        moveInvaders(forUpdate: currentTime)
        
    }
    
    
    
    // Scene Update Helpers
    
    // Invader Movement Helpers
    func determineInvaderMovementDirection() {
        // 1
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        // 2
        enumerateChildNodes(withName: InvaderType.name) { node, stop in
            
            switch self.invaderMovementDirection {
            case .right:
                //3
                if (node.frame.maxX >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .downThenLeft
                    
                    stop.pointee = true
                }
            case .left:
                //4
                if (node.frame.minX <= 1.0) {
                    proposedMovementDirection = .downThenRight
                    
                    stop.pointee = true
                }
                
            case .downThenLeft:
                proposedMovementDirection = .left
                
                stop.pointee = true
                
            case .downThenRight:
                proposedMovementDirection = .right
                
                stop.pointee = true
                
            default:
                break
            }
            
        }
        
        //7
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
    }
    
    // Bullet Helpers
    
    // User Tap Helpers
    
    // HUD Helpers
    
    // Physics Contact Helpers
    
    // Game End Helpers
    
}


