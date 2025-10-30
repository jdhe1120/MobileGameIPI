//
//  GameScene.swift
//  TestGameIPI
//
//  Created by Jeffrey He on 10/28/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // MARK: - Types

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
    }

    struct GridPosition: Equatable {
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
    }

    enum GameState {
        case ready, playing, gameOver
    }

    // MARK: - Properties

    private var gridWidth: Int = 20
    private var gridHeight: Int = 30
    private var cellSize: CGFloat = 20

    private var snake: [GridPosition] = []
    private var currentDirection: Direction = .right
    private var nextDirection: Direction = .right

    private var food: GridPosition?
    private var score: Int = 0
    private var gameState: GameState = .ready

    private var lastUpdateTime: TimeInterval = 0
    private var moveInterval: TimeInterval = 0.15

    private var scoreLabel: SKLabelNode!
    private var messageLabel: SKLabelNode!
    private var gameBoard: SKShapeNode!

    private var snakeNodes: [SKShapeNode] = []
    private var foodNode: SKShapeNode?

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupScene()
        setupLabels()
        setupSwipeGestures()
        startNewGame()
    }

    private func setupScene() {
        backgroundColor = .black

        // Calculate cell size based on scene size to fill the screen
        let availableWidth = size.width * 0.95
        let availableHeight = size.height * 0.90

        let cellWidth = availableWidth / CGFloat(gridWidth)
        let cellHeight = availableHeight / CGFloat(gridHeight)
        cellSize = min(cellWidth, cellHeight)

        // Create game board border
        let boardWidth = CGFloat(gridWidth) * cellSize
        let boardHeight = CGFloat(gridHeight) * cellSize

        // Position board from bottom-left corner (SpriteKit default origin)
        let boardX = (size.width - boardWidth) / 2
        let boardY = (size.height - boardHeight) / 2 - 30  // Offset for score label

        let boardRect = CGRect(x: boardX, y: boardY, width: boardWidth, height: boardHeight)

        gameBoard = SKShapeNode(rect: boardRect)
        gameBoard.strokeColor = .darkGray
        gameBoard.lineWidth = 2
        gameBoard.position = .zero  // No offset needed, rect already positioned
        addChild(gameBoard)
    }

    private func setupLabels() {
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        // Message label
        messageLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        messageLabel.fontSize = 32
        messageLabel.fontColor = .white
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.text = "Swipe to Start!"
        addChild(messageLabel)
    }

    private func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view?.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view?.addGestureRecognizer(swipeDown)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view?.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view?.addGestureRecognizer(swipeRight)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gameState == .ready {
            gameState = .playing
            messageLabel.text = ""
        }

        if gameState != .playing { return }

        let newDirection: Direction
        switch gesture.direction {
        case .up: newDirection = .up
        case .down: newDirection = .down
        case .left: newDirection = .left
        case .right: newDirection = .right
        default: return
        }

        // Prevent reversing into itself
        if newDirection != currentDirection.opposite {
            nextDirection = newDirection
        }
    }

    // MARK: - Game Logic

    private func startNewGame() {
        score = 0
        gameState = .ready
        currentDirection = .right
        nextDirection = .right

        // Initialize snake in the center
        let centerX = gridWidth / 2
        let centerY = gridHeight / 2
        snake = [
            GridPosition(x: centerX, y: centerY),
            GridPosition(x: centerX - 1, y: centerY),
            GridPosition(x: centerX - 2, y: centerY)
        ]

        spawnFood()
        updateScore()
        renderSnake()
        renderFood()

        messageLabel.text = "Swipe to Start!"
    }

    private func spawnFood() {
        var newFoodPosition: GridPosition
        repeat {
            newFoodPosition = GridPosition(
                x: Int.random(in: 0..<gridWidth),
                y: Int.random(in: 0..<gridHeight)
            )
        } while snake.contains(newFoodPosition)

        food = newFoodPosition
    }

    private func moveSnake() {
        currentDirection = nextDirection

        // Calculate new head position
        let newHead = snake[0].moved(in: currentDirection)

        // Check wall collision
        if newHead.x < 0 || newHead.x >= gridWidth || newHead.y < 0 || newHead.y >= gridHeight {
            gameOver()
            return
        }

        // Check self collision
        if snake.contains(newHead) {
            gameOver()
            return
        }

        // Move snake
        snake.insert(newHead, at: 0)

        // Check food collision
        if newHead == food {
            score += 10
            updateScore()
            spawnFood()
            renderFood()

            // Speed up slightly
            moveInterval = max(0.08, moveInterval - 0.002)
        } else {
            // Remove tail if not eating
            snake.removeLast()
        }

        renderSnake()
    }

    private func gameOver() {
        gameState = .gameOver
        messageLabel.text = "Game Over!\nScore: \(score)\nTap to Restart"
        messageLabel.numberOfLines = 0
    }

    // MARK: - Rendering

    private func renderSnake() {
        // Remove old snake nodes
        snakeNodes.forEach { $0.removeFromParent() }
        snakeNodes.removeAll()

        // Create new snake nodes
        for (index, segment) in snake.enumerated() {
            let position = gridToScene(segment)
            let node = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 3)

            // Head is brighter green
            if index == 0 {
                node.fillColor = .green
            } else {
                node.fillColor = SKColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            }

            node.strokeColor = .clear
            node.position = position
            addChild(node)
            snakeNodes.append(node)
        }
    }

    private func renderFood() {
        foodNode?.removeFromParent()

        guard let food = food else { return }

        let position = gridToScene(food)
        let node = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 3)
        node.fillColor = .red
        node.strokeColor = .clear
        node.position = position
        addChild(node)
        foodNode = node
    }

    private func gridToScene(_ gridPos: GridPosition) -> CGPoint {
        // Calculate board dimensions and position
        let boardWidth = CGFloat(gridWidth) * cellSize
        let boardHeight = CGFloat(gridHeight) * cellSize
        let boardX = (size.width - boardWidth) / 2
        let boardY = (size.height - boardHeight) / 2 - 30

        // Convert grid position to scene coordinates
        let x = boardX + (CGFloat(gridPos.x) + 0.5) * cellSize
        let y = boardY + (CGFloat(gridPos.y) + 0.5) * cellSize
        return CGPoint(x: x, y: y)
    }

    private func updateScore() {
        scoreLabel.text = "Score: \(score)"
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .gameOver {
            startNewGame()
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        if gameState != .playing { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = currentTime - lastUpdateTime
        if deltaTime >= moveInterval {
            moveSnake()
            lastUpdateTime = currentTime
        }
    }
}
