# TestGameIPI - Snake Game 🐍

A beautifully designed Snake game for iOS built with SpriteKit, featuring modern architecture patterns, smooth animations, and an educational twist.

## Overview

This is a professional implementation of the classic Snake game with a modern visual design and advanced features. The food items are themed around university courses, adding an educational element to the gameplay.

## Features

### Core Gameplay
- **Classic Snake Mechanics**: Navigate the snake to collect food and grow longer
- **Smooth Animations**: Interpolated movement for fluid gameplay
- **Combo System**: Build combos by collecting consecutive food items for bonus points
- **High Score Tracking**: Persistent storage of your best score using UserDefaults
- **Dynamic Difficulty**: Game speed increases as you progress

### Power-Ups
The game includes four unique power-ups that spawn randomly:
- **⚡ Speed Boost** (5s): Move faster for quick navigation
- **🐌 Slow Motion** (7s): Slowed movement for precise control
- **2️⃣ Double Points** (10s): Earn 2x points for each food item
- **🛡 Shield** (8s): Pass through walls and yourself without dying

### Visual Features
- **Modern UI Design**: Dark theme with glassmorphism effects
- **Particle Effects**: Collection animations and game over effects
- **Glow Effects**: Beautiful glowing elements using Core Image filters
- **Smooth Interpolation**: Animations between grid movements
- **Color Gradients**: Snake segments fade from head to tail
- **Pulsing Animations**: Food and power-ups have attention-grabbing animations

## Architecture

This project demonstrates professional iOS development patterns:

### Design Patterns
- **MVVM (Model-View-ViewModel)**: Separation of game logic from presentation
- **Protocol-Oriented Programming**: Flexible entity and component system
- **Observer Pattern**: Event-driven architecture for game state changes
- **Entity-Component System**: Modular game entities with rendering components

### Key Components

#### Protocols
- `GameEntity`: Core protocol for all game objects
- `Renderable`: Visual component rendering interface
- `GameEventObserver`: Event handling for score, state, and power-up changes

#### Core Systems
- **SnakeGameViewModel**: Manages all game state and logic
- **Snake/Food/PowerUp**: Game entity classes
- **SnakeRenderer/FoodRenderer/PowerUpRenderer**: Visual rendering components
- **ParticleEffectSystem**: Advanced particle effects for visual feedback
- **VisualTheme**: Centralized color and styling system

## Game Configuration

Configurable constants in `GameConfig`:
- Grid size: 20×30 cells
- Initial speed: 0.15s per move
- Minimum speed: 0.08s per move
- Base points: 10 per food item
- Power-up spawn chance: 15%

## Course Themes

Food items cycle through these course names:
- ES 101
- IP4I
- IP: GM
- IP: HC
- NEG
- VCPE

## Controls

- **Swipe Up/Down/Left/Right**: Change snake direction
- **Tap Screen**: Restart game after game over
- **Swipe Any Direction**: Start game from ready state

## Technical Details

### Platform
- iOS
- Built with SpriteKit
- Swift programming language
- Xcode project

### Performance Optimizations
- Efficient grid-based collision detection
- Smooth interpolation between discrete movements
- Object pooling for particle effects
- Minimal scene node count

### File Structure
```
TestGameIPI/
├── AppDelegate.swift          # Application lifecycle management
├── GameViewController.swift   # View controller setup
├── GameScene.swift           # Main game scene with all logic
├── GameScene.sks             # SpriteKit scene file
├── Actions.sks               # SpriteKit actions
├── Assets.xcassets/          # Image and color assets
└── Base.lproj/               # Storyboards and localization
```

## Building and Running

### Requirements
- Xcode 14.0 or later
- iOS 14.0 or later
- macOS for development

### Steps
1. Open `TestGameIPI.xcodeproj` in Xcode
2. Select a target device or simulator
3. Press Cmd+R to build and run
4. Swipe to start playing!

## Code Highlights

### Clean Architecture
The game uses a clear separation of concerns:
- **ViewModel** handles all game logic and state
- **Renderers** handle visual presentation
- **GameScene** coordinates between systems

### Smooth Movement
Unlike traditional Snake implementations, this version uses interpolation:
```swift
if interpolation < 1.0 {
    let currentPos = segmentNode.position
    let newPos = CGPoint(
        x: currentPos.x + (targetPosition.x - currentPos.x) * interpolation,
        y: currentPos.y + (targetPosition.y - currentPos.y) * interpolation
    )
    segmentNode.position = newPos
}
```

### Event-Driven Updates
The Observer pattern keeps UI in sync with game state:
```swift
func onScoreChanged(_ newScore: Int)
func onGameStateChanged(_ newState: GameState)
func onFoodEaten(position: GridPosition, value: Int)
func onPowerUpCollected(_ powerUp: PowerUpType)
```

## Testing

The project includes test targets:
- `TestGameIPITests`: Unit tests
- `TestGameIPIUITests`: UI tests

## Future Enhancements

Potential improvements:
- Multiple difficulty levels
- Different game modes (time trial, infinite, etc.)
- Sound effects and background music
- Customizable themes
- Leaderboard with GameCenter integration
- Achievements system
- Haptic feedback
- Landscape orientation support

## Credits

Created by Jeffrey He

Built with modern iOS development best practices and a focus on clean, maintainable code.

## License

This project is for educational and portfolio purposes.

---

**Enjoy the game and happy coding! 🎮**
