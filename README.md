# Island Epoch

A strategic island management simulation game built with SwiftUI for iOS. Manage multiple islands, build structures, assign workers, research technologies, and progress through different epochs.

## Project Overview

Island Epoch is a resource management and city-building game where players:
- Manage multiple islands with limited building slots
- Construct and operate various production buildings (farms, mines, foresters, etc.)
- Balance resource production and consumption
- Assign workers to buildings to maximize productivity
- Research technologies to improve efficiency
- Progress through 10 different epochs, unlocking new content

The game features a tick-based simulation system that runs every second, processing production, consumption, and passive income.

## Current Status

The game is in active development with the following features implemented:

### Completed Features
- Core game loop with auto-save functionality
- Multi-island support with building slot system
- Building construction and demolition system
- Worker assignment and productivity calculations
- Resource production and consumption chains
- Research system with resource costs
- Island map visualization with interactive building slots
- Persistent save/load system
- Debug tools for testing and development

### Current Islands
- **Main Isle**: 6 building slots, starter island
- **Ironcliff**: 4 building slots, secondary island

## Architecture

The project follows a clean MVVM (Model-View-ViewModel) architecture with clear separation of concerns:

```
IslandEpoch/
├── Models/              # Pure data structures
├── ViewModels/          # Business logic and state management
├── Views/               # SwiftUI user interface
├── Managers/            # Specialized business logic
└── Utilities/           # Helper functions and logging
```

### Architecture Pattern

**Single Source of Truth**: `GameState` contains all game data and is the single source of truth passed through the application.

**Dependency Flow**:
```
Views → GameViewModel → Managers → GameState (mutated)
                    ↓
                 Models
```

## Modular Code Blocks

### Models (Data Layer)

Pure data structures with no business logic, all conforming to `Codable` for persistence:

- **GameState.swift**: The root data model containing all game state
  - Time tracking (tick counter, game time)
  - Economy (gold)
  - Territory (islands array)
  - Progression (epochs, research)

- **Island.swift**: Individual island data
  - Building slots (fixed-size array)
  - Resource inventory
  - Worker availability calculations

- **Building.swift**: Building instance data
  - Type reference
  - Assigned workers
  - Unique identifier

- **BuildingType.swift**: Building blueprints (static catalog)
  - Production/consumption rates
  - Worker requirements
  - Costs and unlocks
  - Available buildings: Tent, Farm, Forester, Mine, Bakery, Forager

- **Resource.swift**: Resource system
  - Resource types (wheat, wood, iron ore, bread, berries)
  - Resource categories (food, material, ore)
  - Inventory type alias and helper methods

- **Research.swift**: Technology research system
  - Research blueprints with costs and effects
  - Completed research tracking
  - Current research: Metal Hatchets (+15% wood production)

- **EpochTracker.swift**: Era progression system
  - Current epoch (1-10)
  - Building availability by epoch
  - Epoch advancement logic

### ViewModels (Business Logic Layer)

- **GameViewModel.swift**: Main view model (MainActor)
  - Owns `GameState` as `@Published` property
  - Coordinates all managers
  - Manages game loop timer (1-second ticks)
  - Provides convenience accessors for views
  - Handles user actions: building, demolishing, research, worker assignment
  - Auto-save every 10 ticks

### Managers (Specialized Logic Layer)

Each manager handles a specific domain and operates on `GameState`:

- **BuildingManager.swift**: Building lifecycle
  - Construction validation (gold, slots, epoch)
  - Slot assignment (specific or auto-find empty)
  - Demolition with refunds (50% gold back)
  - Special rules (can't demolish last tent)

- **ProductionManager.swift**: Resource production
  - Per-tick resource processing for all islands
  - Consumption before production
  - Production/consumption calculations
  - Productivity-based output (worker-dependent)
  - Resource availability checks

- **ProductivityCalculator.swift**: Worker efficiency
  - Calculates productivity percentage (0-100%)
  - Based on assigned workers vs required workers
  - Research bonus application
  - Used by production calculations

- **SaveManager.swift**: Persistence
  - JSON-based save/load system
  - File management in documents directory
  - Error handling with Result types

### Views (UI Layer)

SwiftUI views organized by feature:

- **ContentView.swift**: Main app container
  - Tab bar navigation (Island, Buildings, Research, Debug)
  - GameViewModel lifecycle management
  - Environment object injection

- **IslandMapView.swift**: Visual island representation
  - Grid-based building slot display
  - Resource and worker counts
  - Interactive slot tapping

- **BuildMenuView.swift**: Building construction UI
  - Available building catalog
  - Cost display and affordability checks
  - Construction confirmation

- **BuildingDetailView.swift**: Individual building management
  - Worker assignment controls
  - Production/consumption display
  - Productivity percentage
  - Demolition option

- **BuildingListView.swift**: All buildings overview
  - Per-island building lists
  - Quick access to all structures

- **ResearchView.swift**: Technology tree
  - Available research display
  - Cost requirements
  - Completion tracking

- **DebugView.swift**: Development tools
  - Save/load/delete controls
  - New game initialization
  - State inspection

### Utilities

- **Logger.swift**: Centralized logging
  - OSLog-based logging system
  - Multiple log categories (general, building, gameLoop)
  - Structured logging for debugging

## Game Mechanics

### Resource System

Resources flow through production chains:
- **Raw materials**: Wheat (Farm), Wood (Forester), Iron Ore (Mine), Berries (Forager)
- **Processed goods**: Bread (Bakery: consumes Wheat)

Resources are stored per-island in inventories and cannot currently be transferred between islands.

### Worker System

Workers are the key to productivity:
1. **Housing buildings** (Tents) provide workers (5 per tent)
2. **Unassigned workers** can be assigned to production buildings
3. **Productivity** is calculated as: `(assigned workers / required workers) * 100%`
4. **Production output** scales with productivity percentage

Example: A Farm needs 2 workers and produces 2 wheat/tick. With 1 worker assigned (50% productivity), it produces 1 wheat/tick.

### Building System

- Fixed number of **building slots per island** (cannot expand currently)
- Buildings cost **gold** and can be demolished for 50% refund
- Building **types** determine workers needed, production, and costs
- Buildings are **unlocked by epoch** (currently all are Epoch 1)
- Special rule: **Cannot demolish last tent** (must keep housing)

### Time System

- Game runs on a **1-second tick** cycle
- Each tick:
  1. Increments tick counter
  2. Adds passive gold income
  3. Processes production (all islands)
  4. Auto-saves every 10 ticks
  5. Updates UI

### Save System

- Automatic saves every 10 seconds (ticks)
- JSON-based serialization
- Saved to iOS documents directory
- Loads automatically on app launch

## Technology Stack

- **Language**: Swift 5
- **Framework**: SwiftUI
- **Platform**: iOS
- **Architecture**: MVVM
- **Persistence**: Codable + FileManager
- **Logging**: OSLog
- **Concurrency**: MainActor (UI-safe)
- **State Management**: Combine (@Published, ObservableObject)

## Recent Changes

Recent pull requests have focused on:
1. **Building Construction UX**: Consolidated building menu to shared `BuildMenuView`
2. **Island Map Integration**: Linked map spots to actual building slots with tap interactions
3. **Island Tab**: Added dedicated island view with building slot visualization

## Development Notes

### Code Style
- Extensive use of `Result` types for error handling
- Clear error enums with `LocalizedError` conformance
- Computed properties for derived state
- MARK comments for code organization
- Comprehensive logging throughout

### Future Expansion Points
- Epoch system ready for expansion (currently only Epoch 1 content)
- Research system extensible (currently 1 research)
- Inter-island trade system prepared but not implemented
- Additional building types can be added to catalog
- Resource categories support future UI grouping

### Key Design Decisions
1. **Fixed-size building arrays** with optionals rather than dynamic arrays
2. **Tick-based simulation** rather than real-time differential
3. **Per-island inventories** rather than global resources
4. **Worker assignment** is manual rather than automatic
5. **Productivity scaling** allows partial operation of buildings

## Getting Started

### Requirements
- Xcode 14+
- iOS 16+
- Swift 5.7+

### Building and Running
1. Open `IslandEpoch.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (Cmd+R)

### Development Workflow
1. Make changes to relevant modular components
2. Test in simulator or use Debug tab in-game
3. Check logs for debugging information
4. Save file persists between app launches

## License

Copyright 2025 Casper Stienstra
