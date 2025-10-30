//
//  GameScene.swift
//  TestGameIPI
//
//  Created by Jeffrey He on 10/28/25.
//  Revamped with professional design patterns and beautiful visuals
//

import SpriteKit
import GameplayKit

// MARK: - Protocol-Oriented Architecture

/// Core game entity protocol
protocol GameEntity: AnyObject {
    var position: GridPosition { get set }
    func update(deltaTime: TimeInterval)
}

/// Renderable protocol for visual components
protocol Renderable: AnyObject {
    var node: SKNode { get }
    func render()
    func cleanup()
}

/// Observable protocol for event handling
protocol GameEventObserver: AnyObject {
    func onScoreChanged(_ newScore: Int)
    func onGameStateChanged(_ newState: GameState)
    func onFoodEaten(position: GridPosition, value: Int)
    func onPowerUpCollected(_ powerUp: PowerUpType)
}

// MARK: - Core Types

enum Direction {
    case up, down, left, right

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var vector: CGVector {
        switch self {
        case .up: return CGVector(dx: 0, dy: 1)
        case .down: return CGVector(dx: 0, dy: -1)
        case .left: return CGVector(dx: -1, dy: 0)
        case .right: return CGVector(dx: 1, dy: 0)
        }
    }
}

struct GridPosition: Equatable, Hashable {
    var x: Int
    var y: Int

    func moved(in direction: Direction) -> GridPosition {
        switch direction {
        case .up: return GridPosition(x: x, y: y + 1)
        case .down: return GridPosition(x: x, y: y - 1)
        case .left: return GridPosition(x: x - 1, y: y)
        case .right: return GridPosition(x: x + 1, y: y)
        }
    }

    func distance(to other: GridPosition) -> Double {
        let dx = Double(x - other.x)
        let dy = Double(y - other.y)
        return sqrt(dx * dx + dy * dy)
    }
}

enum GameState {
    case ready, playing, paused, gameOver
}

enum PowerUpType: CaseIterable {
    case speedBoost
    case slowMotion
    case doublePoints
    case shield

    var displayName: String {
        switch self {
        case .speedBoost: return "⚡"
        case .slowMotion: return "🐌"
        case .doublePoints: return "2️⃣"
        case .shield: return "🛡"
        }
    }

    var color: UIColor {
        switch self {
        case .speedBoost: return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case .slowMotion: return UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)
        case .doublePoints: return UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        case .shield: return UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        }
    }

    var duration: TimeInterval {
        switch self {
        case .speedBoost: return 5.0
        case .slowMotion: return 7.0
        case .doublePoints: return 10.0
        case .shield: return 8.0
        }
    }
}

// MARK: - Game Configuration

struct GameConfig {
    static let gridWidth: Int = 20
    static let gridHeight: Int = 30
    static let initialSpeed: TimeInterval = 0.15
    static let minSpeed: TimeInterval = 0.08
    static let speedIncrement: TimeInterval = 0.002
    static let basePoints: Int = 10
    static let powerUpSpawnChance: Double = 0.15

    // Visual constants
    static let cellGap: CGFloat = 2
    static let cornerRadius: CGFloat = 4
    static let glowRadius: CGFloat = 8
}

// MARK: - Visual Theme System

struct VisualTheme {
    // Modern color palette
    static let background = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
    static let boardBackground = UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.8)
    static let boardBorder = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)

    static let snakeHead = UIColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1.0)
    static let snakeBody = UIColor(red: 0.15, green: 0.7, blue: 0.3, alpha: 1.0)
    static let snakeGlow = UIColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 0.6)

    static let food = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
    static let foodGlow = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.8)

    static let gridLines = UIColor(red: 0.15, green: 0.15, blue: 0.22, alpha: 0.3)

    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(white: 0.8, alpha: 1.0)
}

// MARK: - Entity-Component System

/// Snake entity with smooth movement interpolation
class Snake: GameEntity {
    var position: GridPosition
    var segments: [GridPosition]
    var direction: Direction
    var targetPositions: [GridPosition]

    init(initialPosition: GridPosition, length: Int = 3) {
        self.position = initialPosition
        self.direction = .right
        self.segments = (0..<length).map { GridPosition(x: initialPosition.x - $0, y: initialPosition.y) }
        self.targetPositions = segments
    }

    func update(deltaTime: TimeInterval) {
        // Smooth interpolation handled by renderer
    }

    func move(in direction: Direction) {
        let newHead = segments[0].moved(in: direction)
        segments.insert(newHead, at: 0)
        targetPositions.insert(newHead, at: 0)
    }

    func removeTail() {
        segments.removeLast()
        targetPositions.removeLast()
    }

    func contains(_ position: GridPosition) -> Bool {
        segments.contains(position)
    }
}

/// Food entity with class information
class Food: GameEntity {
    var position: GridPosition
    let className: String
    let value: Int

    init(position: GridPosition, className: String, value: Int = GameConfig.basePoints) {
        self.position = position
        self.className = className
        self.value = value
    }

    func update(deltaTime: TimeInterval) {}
}

/// Power-up entity
class PowerUp: GameEntity {
    var position: GridPosition
    let type: PowerUpType
    var lifetime: TimeInterval

    init(position: GridPosition, type: PowerUpType) {
        self.position = position
        self.type = type
        self.lifetime = 15.0
    }

    func update(deltaTime: TimeInterval) {
        lifetime -= deltaTime
    }

    var isExpired: Bool { lifetime <= 0 }
}

// MARK: - Visual Components

/// Advanced particle system for visual effects
class ParticleEffectSystem {
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    func emitFoodCollectionEffect(at position: CGPoint, color: UIColor) {
        guard let scene = scene else { return }

        let particleCount = 12
        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = color
            particle.strokeColor = .clear
            particle.position = position
            particle.alpha = 1.0

            let distance: CGFloat = 30
            let endPosition = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )

            let moveAction = SKAction.move(to: endPosition, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(to: 0.1, duration: 0.5)

            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
            scene.addChild(particle)
        }
    }

    func emitPowerUpEffect(at position: CGPoint, color: UIColor) {
        guard let scene = scene else { return }

        // Radial burst effect
        for i in 0..<20 {
            let angle = (CGFloat(i) / 20.0) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = color
            particle.strokeColor = .white
            particle.lineWidth = 1
            particle.position = position
            particle.alpha = 1.0

            let distance: CGFloat = 60
            let endPosition = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )

            let moveAction = SKAction.move(to: endPosition, duration: 0.8)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.8)
            let scaleAction = SKAction.scale(to: 0.5, duration: 0.8)

            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
            scene.addChild(particle)
        }
    }

    func emitGameOverEffect(at positions: [CGPoint]) {
        guard let scene = scene else { return }

        for position in positions {
            let particle = SKShapeNode(rectOf: CGSize(width: 8, height: 8), cornerRadius: 2)
            particle.fillColor = VisualTheme.snakeBody
            particle.strokeColor = .clear
            particle.position = position
            particle.alpha = 1.0

            let randomX = CGFloat.random(in: -100...100)
            let randomY = CGFloat.random(in: -100...100)
            let endPosition = CGPoint(x: position.x + randomX, y: position.y + randomY)

            let moveAction = SKAction.move(to: endPosition, duration: 1.5)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 1.5)
            let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 1.5)

            let group = SKAction.group([moveAction, fadeAction, rotateAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
            scene.addChild(particle)
        }
    }
}

/// Snake renderer with smooth interpolation and glow effects
class SnakeRenderer: Renderable {
    private(set) var node: SKNode
    private var segments: [SKShapeNode] = []
    private var glowNodes: [SKEffectNode] = []
    private let cellSize: CGFloat
    private let gridToSceneConverter: (GridPosition) -> CGPoint
    private var interpolationProgress: CGFloat = 0

    init(cellSize: CGFloat, gridToSceneConverter: @escaping (GridPosition) -> CGPoint) {
        self.node = SKNode()
        self.cellSize = cellSize
        self.gridToSceneConverter = gridToSceneConverter
    }

    func render(snake: Snake, interpolation: CGFloat = 1.0) {
        // Update or create segments
        while segments.count < snake.segments.count {
            addSegment()
        }
        while segments.count > snake.segments.count {
            removeSegment()
        }

        // Render each segment with smooth interpolation
        for (index, segment) in snake.segments.enumerated() {
            let targetPosition = gridToSceneConverter(segment)
            let segmentNode = segments[index]

            // Smooth position interpolation
            if interpolation < 1.0 {
                let currentPos = segmentNode.position
                let newPos = CGPoint(
                    x: currentPos.x + (targetPosition.x - currentPos.x) * interpolation,
                    y: currentPos.y + (targetPosition.y - currentPos.y) * interpolation
                )
                segmentNode.position = newPos
            } else {
                segmentNode.position = targetPosition
            }

            // Color gradient from head to tail
            if index == 0 {
                segmentNode.fillColor = VisualTheme.snakeHead
                glowNodes[index].shouldEnableEffects = true
            } else {
                let alpha = 1.0 - (CGFloat(index) / CGFloat(snake.segments.count)) * 0.3
                segmentNode.fillColor = VisualTheme.snakeBody.withAlphaComponent(alpha)
                glowNodes[index].shouldEnableEffects = index < 3
            }
        }
    }

    private func addSegment() {
        let size = CGSize(width: cellSize - GameConfig.cellGap, height: cellSize - GameConfig.cellGap)
        let segmentNode = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        segmentNode.fillColor = VisualTheme.snakeBody
        segmentNode.strokeColor = .clear
        segmentNode.lineWidth = 0

        // Add glow effect
        let glowNode = SKEffectNode()
        glowNode.shouldEnableEffects = true
        glowNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": GameConfig.glowRadius])

        let glowShape = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        glowShape.fillColor = VisualTheme.snakeGlow
        glowShape.strokeColor = .clear
        glowNode.addChild(glowShape)
        glowNode.alpha = 0.6

        node.addChild(glowNode)
        node.addChild(segmentNode)

        glowNodes.append(glowNode)
        segments.append(segmentNode)
    }

    private func removeSegment() {
        segments.last?.removeFromParent()
        segments.removeLast()
        glowNodes.last?.removeFromParent()
        glowNodes.removeLast()
    }

    func render() {}

    func cleanup() {
        segments.forEach { $0.removeFromParent() }
        segments.removeAll()
        glowNodes.forEach { $0.removeFromParent() }
        glowNodes.removeAll()
    }
}

/// Food renderer with pulsing animation and glow
class FoodRenderer: Renderable {
    private(set) var node: SKNode
    private var foodNode: SKShapeNode?
    private var labelNode: SKLabelNode?
    private var glowNode: SKEffectNode?
    private let cellSize: CGFloat

    init(cellSize: CGFloat) {
        self.node = SKNode()
        self.cellSize = cellSize
    }

    func render(food: Food?, at position: CGPoint) {
        cleanup()

        guard let food = food else { return }

        let size = CGSize(width: cellSize - GameConfig.cellGap, height: cellSize - GameConfig.cellGap)

        // Glow effect
        let glowEffect = SKEffectNode()
        glowEffect.shouldEnableEffects = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": GameConfig.glowRadius])

        let glowShape = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        glowShape.fillColor = VisualTheme.foodGlow
        glowShape.strokeColor = .clear
        glowEffect.addChild(glowShape)
        glowEffect.position = position

        // Pulsing animation
        let pulseUp = SKAction.scale(to: 1.2, duration: 0.6)
        pulseUp.timingMode = .easeInEaseOut
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.6)
        pulseDown.timingMode = .easeInEaseOut
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        glowEffect.run(SKAction.repeatForever(pulse))

        node.addChild(glowEffect)
        glowNode = glowEffect

        // Food shape
        let foodShape = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        foodShape.fillColor = VisualTheme.food
        foodShape.strokeColor = .white
        foodShape.lineWidth = 1
        foodShape.position = position
        node.addChild(foodShape)
        foodNode = foodShape

        // Class label
        let label = SKLabelNode(fontNamed: "Avenir-Heavy")
        label.text = food.className
        label.fontSize = max(8, cellSize * 0.4)
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = position
        node.addChild(label)
        labelNode = label

        // Gentle rotation
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 8.0)
        foodShape.run(SKAction.repeatForever(rotateAction))
    }

    func render() {}

    func cleanup() {
        foodNode?.removeFromParent()
        foodNode = nil
        labelNode?.removeFromParent()
        labelNode = nil
        glowNode?.removeFromParent()
        glowNode = nil
    }
}

/// Power-up renderer with special effects
class PowerUpRenderer: Renderable {
    private(set) var node: SKNode
    private var powerUpNodes: [GridPosition: SKNode] = [:]
    private let cellSize: CGFloat

    init(cellSize: CGFloat) {
        self.node = SKNode()
        self.cellSize = cellSize
    }

    func render(powerUps: [PowerUp], gridToScene: @escaping (GridPosition) -> CGPoint) {
        // Remove expired power-ups
        let currentPositions = Set(powerUps.map { $0.position })
        for (position, powerUpNode) in powerUpNodes where !currentPositions.contains(position) {
            powerUpNode.removeFromParent()
            powerUpNodes.removeValue(forKey: position)
        }

        // Add new power-ups
        for powerUp in powerUps {
            if powerUpNodes[powerUp.position] == nil {
                addPowerUp(powerUp, at: gridToScene(powerUp.position))
            }
        }
    }

    private func addPowerUp(_ powerUp: PowerUp, at position: CGPoint) {
        let size = CGSize(width: cellSize - GameConfig.cellGap, height: cellSize - GameConfig.cellGap)
        let container = SKNode()
        container.position = position

        // Glow
        let glowEffect = SKEffectNode()
        glowEffect.shouldEnableEffects = true
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10.0])

        let glowShape = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        glowShape.fillColor = powerUp.type.color
        glowShape.strokeColor = .clear
        glowEffect.addChild(glowShape)
        container.addChild(glowEffect)

        // Main shape
        let shape = SKShapeNode(rectOf: size, cornerRadius: GameConfig.cornerRadius)
        shape.fillColor = powerUp.type.color
        shape.strokeColor = .white
        shape.lineWidth = 2
        container.addChild(shape)

        // Icon
        let label = SKLabelNode(text: powerUp.type.displayName)
        label.fontSize = cellSize * 0.6
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        container.addChild(label)

        // Animations
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 3.0)
        container.run(SKAction.repeatForever(rotate))

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        glowEffect.run(SKAction.repeatForever(pulse))

        node.addChild(container)
        powerUpNodes[powerUp.position] = container
    }

    func render() {}

    func cleanup() {
        powerUpNodes.values.forEach { $0.removeFromParent() }
        powerUpNodes.removeAll()
    }
}

// MARK: - MVVM Architecture

/// ViewModel managing game state and logic
class SnakeGameViewModel {
    // Game entities
    private(set) var snake: Snake
    private(set) var food: Food?
    private(set) var powerUps: [PowerUp] = []
    private(set) var activePowerUps: [PowerUpType: TimeInterval] = [:]

    // Game state
    private(set) var gameState: GameState = .ready
    private(set) var score: Int = 0
    private(set) var highScore: Int = 0
    private(set) var combo: Int = 0

    // Configuration
    private let gridWidth: Int
    private let gridHeight: Int
    private let classes = ["ES 101", "IP4I", "IP: GM", "IP: HC", "NEG", "VCPE"]
    private var currentClassIndex = 0

    // Speed management
    private(set) var moveInterval: TimeInterval = GameConfig.initialSpeed
    private var baseInterval: TimeInterval = GameConfig.initialSpeed

    // Observers
    private var observers: [GameEventObserver] = []

    init(gridWidth: Int = GameConfig.gridWidth, gridHeight: Int = GameConfig.gridHeight) {
        self.gridWidth = gridWidth
        self.gridHeight = gridHeight

        let centerX = gridWidth / 2
        let centerY = gridHeight / 2
        self.snake = Snake(initialPosition: GridPosition(x: centerX, y: centerY), length: 3)

        loadHighScore()
    }

    func addObserver(_ observer: GameEventObserver) {
        observers.append(observer)
    }

    func startNewGame() {
        score = 0
        combo = 0
        gameState = .ready
        moveInterval = GameConfig.initialSpeed
        baseInterval = GameConfig.initialSpeed
        activePowerUps.removeAll()
        powerUps.removeAll()

        let centerX = gridWidth / 2
        let centerY = gridHeight / 2
        snake = Snake(initialPosition: GridPosition(x: centerX, y: centerY), length: 3)
        snake.direction = .right

        spawnFood()
        notifyStateChanged()
        notifyScoreChanged()
    }

    func startPlaying() {
        guard gameState == .ready else { return }
        gameState = .playing
        notifyStateChanged()
    }

    func changeDirection(_ direction: Direction) {
        guard gameState == .playing else { return }

        // Prevent reversing
        if direction != snake.direction.opposite {
            snake.direction = direction
        }
    }

    func update(deltaTime: TimeInterval) {
        guard gameState == .playing else { return }

        // Update power-ups
        updatePowerUps(deltaTime: deltaTime)

        // Update entities
        snake.update(deltaTime: deltaTime)
        powerUps.forEach { $0.update(deltaTime: deltaTime) }
        powerUps.removeAll { $0.isExpired }
    }

    func moveSnake() -> Bool {
        guard gameState == .playing else { return false }

        // Calculate new head position
        let newHead = snake.segments[0].moved(in: snake.direction)

        // Check wall collision (unless shield is active)
        if !hasActivePowerUp(.shield) {
            if newHead.x < 0 || newHead.x >= gridWidth || newHead.y < 0 || newHead.y >= gridHeight {
                endGame()
                return false
            }
        } else {
            // Wrap around with shield
            var wrappedHead = newHead
            if wrappedHead.x < 0 { wrappedHead.x = gridWidth - 1 }
            if wrappedHead.x >= gridWidth { wrappedHead.x = 0 }
            if wrappedHead.y < 0 { wrappedHead.y = gridHeight - 1 }
            if wrappedHead.y >= gridHeight { wrappedHead.y = 0 }

            return moveToPosition(wrappedHead)
        }

        return moveToPosition(newHead)
    }

    private func moveToPosition(_ newHead: GridPosition) -> Bool {
        // Check self collision (unless shield is active)
        if !hasActivePowerUp(.shield) && snake.contains(newHead) {
            endGame()
            return false
        }

        // Move snake
        snake.move(in: snake.direction)

        // Check food collision
        if newHead == food?.position {
            handleFoodCollection()
        } else {
            // Check power-up collision
            if let powerUpIndex = powerUps.firstIndex(where: { $0.position == newHead }) {
                handlePowerUpCollection(powerUps[powerUpIndex])
                powerUps.remove(at: powerUpIndex)
            } else {
                snake.removeTail()
            }
        }

        return true
    }

    private func handleFoodCollection() {
        guard let food = food else { return }

        combo += 1
        let points = hasActivePowerUp(.doublePoints) ? food.value * 2 : food.value
        let bonusPoints = min(combo - 1, 5) * 5 // Combo bonus up to +25
        score += points + bonusPoints

        // Speed up
        if !hasActivePowerUp(.slowMotion) {
            baseInterval = max(GameConfig.minSpeed, baseInterval - GameConfig.speedIncrement)
            moveInterval = baseInterval
        }

        notifyScoreChanged()
        observers.forEach { $0.onFoodEaten(position: food.position, value: points + bonusPoints) }

        spawnFood()

        // Maybe spawn power-up
        if Double.random(in: 0...1) < GameConfig.powerUpSpawnChance {
            spawnPowerUp()
        }
    }

    private func handlePowerUpCollection(_ powerUp: PowerUp) {
        activePowerUps[powerUp.type] = powerUp.type.duration
        applyPowerUpEffect(powerUp.type)
        observers.forEach { $0.onPowerUpCollected(powerUp.type) }
    }

    private func applyPowerUpEffect(_ type: PowerUpType) {
        switch type {
        case .speedBoost:
            moveInterval = baseInterval * 0.5
        case .slowMotion:
            moveInterval = baseInterval * 1.8
        case .doublePoints:
            break // Applied during food collection
        case .shield:
            break // Applied during collision detection
        }
    }

    private func updatePowerUps(deltaTime: TimeInterval) {
        var expiredPowerUps: [PowerUpType] = []

        for (type, timeRemaining) in activePowerUps {
            let newTime = timeRemaining - deltaTime
            if newTime <= 0 {
                expiredPowerUps.append(type)
            } else {
                activePowerUps[type] = newTime
            }
        }

        // Remove expired power-ups
        for type in expiredPowerUps {
            activePowerUps.removeValue(forKey: type)
            removePowerUpEffect(type)
        }
    }

    private func removePowerUpEffect(_ type: PowerUpType) {
        switch type {
        case .speedBoost, .slowMotion:
            // Reset to base speed if no other speed power-ups are active
            if !hasActivePowerUp(.speedBoost) && !hasActivePowerUp(.slowMotion) {
                moveInterval = baseInterval
            }
        case .doublePoints, .shield:
            break
        }
    }

    private func hasActivePowerUp(_ type: PowerUpType) -> Bool {
        activePowerUps[type] != nil
    }

    private func spawnFood() {
        var newPosition: GridPosition
        repeat {
            newPosition = GridPosition(
                x: Int.random(in: 0..<gridWidth),
                y: Int.random(in: 0..<gridHeight)
            )
        } while snake.contains(newPosition) || powerUps.contains { $0.position == newPosition }

        currentClassIndex = (currentClassIndex + 1) % classes.count
        food = Food(position: newPosition, className: classes[currentClassIndex])
    }

    private func spawnPowerUp() {
        guard powerUps.count < 2 else { return }

        var newPosition: GridPosition
        repeat {
            newPosition = GridPosition(
                x: Int.random(in: 0..<gridWidth),
                y: Int.random(in: 0..<gridHeight)
            )
        } while snake.contains(newPosition) ||
                food?.position == newPosition ||
                powerUps.contains { $0.position == newPosition }

        let type = PowerUpType.allCases.randomElement()!
        let powerUp = PowerUp(position: newPosition, type: type)
        powerUps.append(powerUp)
    }

    private func endGame() {
        gameState = .gameOver
        combo = 0

        if score > highScore {
            highScore = score
            saveHighScore()
        }

        notifyStateChanged()
    }

    private func notifyScoreChanged() {
        observers.forEach { $0.onScoreChanged(score) }
    }

    private func notifyStateChanged() {
        observers.forEach { $0.onGameStateChanged(gameState) }
    }

    private func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "SnakeHighScore")
    }

    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "SnakeHighScore")
    }
}

// MARK: - Main Game Scene

class GameScene: SKScene, GameEventObserver {

    // MARK: - MVVM Components
    private var viewModel: SnakeGameViewModel!

    // MARK: - Visual Components
    private var snakeRenderer: SnakeRenderer!
    private var foodRenderer: FoodRenderer!
    private var powerUpRenderer: PowerUpRenderer!
    private var particleSystem: ParticleEffectSystem!

    // MARK: - UI Elements
    private var gameBoard: SKShapeNode!
    private var gridLinesNode: SKNode!
    private var scoreLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var comboLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    private var powerUpStatusNode: SKNode!

    // MARK: - Configuration
    private var cellSize: CGFloat = 20
    private var boardOffset: CGPoint = .zero

    // MARK: - Timing
    private var lastUpdateTime: TimeInterval = 0
    private var accumulatedTime: TimeInterval = 0
    private var interpolationProgress: CGFloat = 0

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupViewModel()
        setupScene()
        setupVisualComponents()
        setupUI()
        setupGestures()

        viewModel.startNewGame()
    }

    private func setupViewModel() {
        viewModel = SnakeGameViewModel()
        viewModel.addObserver(self)
    }

    private func setupScene() {
        // Modern gradient background
        let backgroundNode = SKShapeNode(rect: frame)
        backgroundNode.fillColor = VisualTheme.background
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -100
        addChild(backgroundNode)

        // Calculate cell size
        let availableWidth = size.width * 0.95
        let availableHeight = size.height * 0.85

        let cellWidth = availableWidth / CGFloat(GameConfig.gridWidth)
        let cellHeight = availableHeight / CGFloat(GameConfig.gridHeight)
        cellSize = min(cellWidth, cellHeight)

        // Create game board with glassmorphism effect
        let boardWidth = CGFloat(GameConfig.gridWidth) * cellSize
        let boardHeight = CGFloat(GameConfig.gridHeight) * cellSize

        let boardX = (size.width - boardWidth) / 2
        let boardY = (size.height - boardHeight) / 2 - 30
        boardOffset = CGPoint(x: boardX, y: boardY)

        let boardRect = CGRect(x: boardX, y: boardY, width: boardWidth, height: boardHeight)

        // Board background
        let boardBackground = SKShapeNode(rect: boardRect, cornerRadius: 12)
        boardBackground.fillColor = VisualTheme.boardBackground
        boardBackground.strokeColor = .clear
        boardBackground.zPosition = -50
        addChild(boardBackground)

        // Grid lines
        gridLinesNode = SKNode()
        gridLinesNode.zPosition = -45
        addChild(gridLinesNode)

        for i in 1..<GameConfig.gridWidth {
            let x = boardX + CGFloat(i) * cellSize
            let line = SKShapeNode(rect: CGRect(x: x, y: boardY, width: 1, height: boardHeight))
            line.fillColor = VisualTheme.gridLines
            line.strokeColor = .clear
            gridLinesNode.addChild(line)
        }

        for i in 1..<GameConfig.gridHeight {
            let y = boardY + CGFloat(i) * cellSize
            let line = SKShapeNode(rect: CGRect(x: boardX, y: y, width: boardWidth, height: 1))
            line.fillColor = VisualTheme.gridLines
            line.strokeColor = .clear
            gridLinesNode.addChild(line)
        }

        // Board border with glow
        gameBoard = SKShapeNode(rect: boardRect, cornerRadius: 12)
        gameBoard.strokeColor = VisualTheme.boardBorder
        gameBoard.lineWidth = 3
        gameBoard.fillColor = .clear
        gameBoard.glowWidth = 2
        gameBoard.zPosition = 100
        addChild(gameBoard)
    }

    private func setupVisualComponents() {
        snakeRenderer = SnakeRenderer(cellSize: cellSize, gridToSceneConverter: gridToScene)
        snakeRenderer.node.zPosition = 10
        addChild(snakeRenderer.node)

        foodRenderer = FoodRenderer(cellSize: cellSize)
        foodRenderer.node.zPosition = 5
        addChild(foodRenderer.node)

        powerUpRenderer = PowerUpRenderer(cellSize: cellSize)
        powerUpRenderer.node.zPosition = 5
        addChild(powerUpRenderer.node)

        particleSystem = ParticleEffectSystem(scene: self)
    }

    private func setupUI() {
        // Score label with modern styling
        scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = VisualTheme.textPrimary
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        scoreLabel.text = "Score: 0"
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        // High score label
        highScoreLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        highScoreLabel.fontSize = 18
        highScoreLabel.fontColor = VisualTheme.textSecondary
        highScoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        highScoreLabel.text = "Best: \(viewModel.highScore)"
        highScoreLabel.zPosition = 100
        addChild(highScoreLabel)

        // Combo label
        comboLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        comboLabel.fontSize = 20
        comboLabel.fontColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        comboLabel.position = CGPoint(x: size.width / 2, y: size.height - 110)
        comboLabel.text = ""
        comboLabel.zPosition = 100
        addChild(comboLabel)

        // Message label with modern typography
        messageLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        messageLabel.fontSize = 36
        messageLabel.fontColor = VisualTheme.textPrimary
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.text = "Swipe to Start!"
        messageLabel.numberOfLines = 0
        messageLabel.zPosition = 100
        addChild(messageLabel)

        // Power-up status indicators
        powerUpStatusNode = SKNode()
        powerUpStatusNode.position = CGPoint(x: 20, y: size.height - 50)
        powerUpStatusNode.zPosition = 100
        addChild(powerUpStatusNode)
    }

    private func setupGestures() {
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, .left, .right]

        for direction in directions {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipe.direction = direction
            view?.addGestureRecognizer(swipe)
        }
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if viewModel.gameState == .ready {
            viewModel.startPlaying()
            return
        }

        guard viewModel.gameState == .playing else { return }

        let direction: Direction
        switch gesture.direction {
        case .up: direction = .up
        case .down: direction = .down
        case .left: direction = .left
        case .right: direction = .right
        default: return
        }

        viewModel.changeDirection(direction)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        viewModel.update(deltaTime: deltaTime)

        if viewModel.gameState == .playing {
            accumulatedTime += deltaTime

            // Move snake at fixed intervals
            if accumulatedTime >= viewModel.moveInterval {
                accumulatedTime -= viewModel.moveInterval
                _ = viewModel.moveSnake()
            }

            // Calculate interpolation for smooth rendering
            interpolationProgress = CGFloat(accumulatedTime / viewModel.moveInterval)
        }

        // Render
        renderGame()
    }

    private func renderGame() {
        // Render snake with smooth interpolation
        snakeRenderer.render(snake: viewModel.snake, interpolation: interpolationProgress)

        // Render food
        if let food = viewModel.food {
            foodRenderer.render(food: food, at: gridToScene(food.position))
        }

        // Render power-ups
        powerUpRenderer.render(powerUps: viewModel.powerUps, gridToScene: gridToScene)

        // Update combo display
        if viewModel.gameState == .playing {
            updateComboDisplay()
            updatePowerUpStatus()
        }
    }

    private func updateComboDisplay() {
        // Show combo after 2+ consecutive food items
        if viewModel.score > 0 && (viewModel.score / 10) > 1 {
            let comboCount = min((viewModel.score / 10), 10)
            comboLabel.text = "🔥 x\(comboCount) Combo!"
            comboLabel.alpha = 1.0
        } else {
            comboLabel.alpha = 0.0
        }
    }

    private func updatePowerUpStatus() {
        powerUpStatusNode.removeAllChildren()

        var yOffset: CGFloat = 0
        for (type, timeRemaining) in viewModel.activePowerUps.sorted(by: { $0.value > $1.value }) {
            let container = SKNode()
            container.position = CGPoint(x: 0, y: yOffset)

            // Icon
            let icon = SKLabelNode(text: type.displayName)
            icon.fontSize = 24
            icon.horizontalAlignmentMode = .left
            icon.verticalAlignmentMode = .center
            container.addChild(icon)

            // Timer
            let timer = SKLabelNode(fontNamed: "Avenir-Medium")
            timer.text = String(format: "%.1fs", timeRemaining)
            timer.fontSize = 16
            timer.fontColor = VisualTheme.textSecondary
            timer.horizontalAlignmentMode = .left
            timer.verticalAlignmentMode = .center
            timer.position = CGPoint(x: 35, y: 0)
            container.addChild(timer)

            powerUpStatusNode.addChild(container)
            yOffset -= 35
        }
    }

    // MARK: - GameEventObserver

    func onScoreChanged(_ newScore: Int) {
        scoreLabel.text = "Score: \(newScore)"
        highScoreLabel.text = "Best: \(viewModel.highScore)"

        // Score increase animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scoreLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }

    func onGameStateChanged(_ newState: GameState) {
        switch newState {
        case .ready:
            messageLabel.text = "Swipe to Start!"
            messageLabel.alpha = 1.0
            accumulatedTime = 0
            comboLabel.alpha = 0.0

        case .playing:
            messageLabel.alpha = 0.0

        case .paused:
            messageLabel.text = "Paused"
            messageLabel.alpha = 1.0

        case .gameOver:
            messageLabel.text = "Game Over!\n\nScore: \(viewModel.score)\nBest: \(viewModel.highScore)\n\nTap to Restart"
            messageLabel.alpha = 1.0
            comboLabel.alpha = 0.0

            // Game over effects
            let positions = viewModel.snake.segments.map { gridToScene($0) }
            particleSystem.emitGameOverEffect(at: positions)

            // Pulse animation
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.5),
                SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            ])
            messageLabel.run(SKAction.repeatForever(pulse), withKey: "pulse")
        }
    }

    func onFoodEaten(position: GridPosition, value: Int) {
        let scenePosition = gridToScene(position)
        particleSystem.emitFoodCollectionEffect(at: scenePosition, color: VisualTheme.food)

        // Show floating score
        let floatingScore = SKLabelNode(fontNamed: "Avenir-Heavy")
        floatingScore.text = "+\(value)"
        floatingScore.fontSize = 20
        floatingScore.fontColor = VisualTheme.food
        floatingScore.position = scenePosition
        floatingScore.zPosition = 50
        addChild(floatingScore)

        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()

        floatingScore.run(SKAction.sequence([group, remove]))
    }

    func onPowerUpCollected(_ powerUp: PowerUpType) {
        if let position = viewModel.powerUps.first(where: { $0.type == powerUp })?.position {
            let scenePosition = gridToScene(position)
            particleSystem.emitPowerUpEffect(at: scenePosition, color: powerUp.color)
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if viewModel.gameState == .gameOver {
            messageLabel.removeAction(forKey: "pulse")
            viewModel.startNewGame()
        }
    }

    // MARK: - Coordinate Conversion

    private func gridToScene(_ gridPos: GridPosition) -> CGPoint {
        let x = boardOffset.x + (CGFloat(gridPos.x) + 0.5) * cellSize
        let y = boardOffset.y + (CGFloat(gridPos.y) + 0.5) * cellSize
        return CGPoint(x: x, y: y)
    }
}
