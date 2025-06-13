# Habbitio iOS

A modern habit tracking iOS application built with SwiftUI that helps users build and maintain healthy habits through daily tracking, analytics, and smart notifications.

## Overview

Habbitio is a comprehensive habit tracker designed to help users establish and maintain positive daily routines. The app provides an intuitive interface for creating habits, tracking daily progress, analyzing patterns, and staying motivated through visual statistics and smart reminders.

## Features

### Core Functionality
- **Habit Management**: Create, edit, and organize habits with custom categories
- **Daily Tracking**: Simple one-tap interface to mark habits as completed
- **Weekly Scheduling**: Configure which days of the week each habit should be active
- **Smart Notifications**: Set custom reminders with personalized messages
- **Habit Archiving**: Archive completed or discontinued habits without losing data

### Analytics & Insights
- **Progress Visualization**: Interactive charts showing completion rates over time
- **Weekly Patterns**: Analyze performance by day of the week
- **Individual Habit Statistics**: Track success rates for specific habits
- **Multiple Time Periods**: View statistics for week, month, year, or all-time
- **Completion Rate Tracking**: Monitor overall habit consistency

### User Experience
- **Native iOS Design**: Built with SwiftUI following Apple's design guidelines
- **Widget Support**: Home screen widgets for quick habit tracking
- **Category Organization**: Group habits by custom categories for better organization
- **Dark/Light Mode**: Adaptive interface that respects system preferences
- **Accessibility**: Full support for iOS accessibility features

## Technical Architecture

### Architecture Pattern
The application follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────┐
│   Presentation  │  SwiftUI Views + Routes
│     Layer       │
├─────────────────┤
│   Business      │  Use Cases + Domain Logic
│     Logic       │
├─────────────────┤
│   Data Layer    │  Store + Contracts
└─────────────────┘
```

### Key Components

#### Presentation Layer
- **Routes**: Screen-level SwiftUI views (`HabitListRoute`, `HabitEditRoute`, `StatsRoute`, `ArchiveRoute`)
- **Views**: Reusable UI components (`NavigationBar`, `PrimaryButton`, `InputTextView`, etc.)
- **Dependency Injection**: Environment-based DI system for clean testability

#### Business Logic
- **Use Cases**: Encapsulated business operations for each route
- **Domain Models**: Pure Swift structs representing business entities
- **Context**: Centralized dependency container managing use case instances

#### Data Layer
- **SwiftData Integration**: Modern persistence framework for iOS 17+
- **Repository Pattern**: `Store` class implementing `IStore` protocol
- **Data Models**: SwiftData models with automatic relationship management

### Technology Stack

#### Core Technologies
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's modern data persistence framework
- **Swift Charts**: Native charting framework for analytics
- **WidgetKit**: Home screen widget support
- **UserNotifications**: Local notification scheduling

#### Development Tools
- **Swift Package Manager**: Modular architecture with local packages
- **Xcode 15+**: Native iOS development environment
- **iOS 17+**: Minimum deployment target

#### Architecture Patterns
- **MVVM-C**: Model-View-ViewModel with Coordinator pattern
- **Dependency Injection**: Environment-based DI for loose coupling
- **Repository Pattern**: Abstracted data access layer
- **Use Case Pattern**: Business logic encapsulation

## Project Structure

```
Habbitio/
├── App/                    # Application entry point
│   ├── App.swift          # Main app struct
│   └── Context.swift      # DI container
├── Routes/                # Screen-level views
│   ├── HabitListRoute.swift
│   ├── HabitEditRoute.swift
│   ├── StatsRoute.swift
│   └── ArchiveRoute.swift
├── Views/                 # Reusable UI components
│   ├── NavigationBar.swift
│   ├── PrimaryButton.swift
│   ├── InputTextView.swift
│   └── ...
├── Extensions/            # Swift extensions
└── Resources/             # Assets and fonts

Storage/                   # Data layer package
├── Contracts/             # Domain models & protocols
│   ├── Habit.swift
│   ├── Record.swift
│   ├── Report.swift
│   └── IStore.swift
└── Store/                 # SwiftData implementation
    ├── Store.swift
    └── [SwiftData Models]

HabbitioWidget/            # iOS widget extension
└── Assets.xcassets/
```

## Data Models

### Core Entities

#### Habit
```swift
struct Habit {
    var title: String           # Habit name
    var category: String?       # Optional category
    var days: [String]         # Active weekdays
    var isArchived: Bool       # Archive status
    var isRemainderOn: Bool    # Notification enabled
    var reminderDate: Date?    # Notification time
    var reminderText: String?  # Custom reminder message
}
```

#### Record
```swift
struct Record {
    var date: Date    # Tracking date
    var habit: Habit  # Associated habit
    var done: Bool    # Completion status
    var isEnabled: Bool # Active on this day
}
```

#### Report
```swift
struct Report {
    var date: Date           # Report date
    var records: [Record]    # Daily records
    var rate: Double         # Completion percentage
}
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later (for development)

### Installation
1. Clone the repository
2. Open `Habbitio.xcodeproj` in Xcode
3. Build and run the project

### Development Setup
The project uses Swift Package Manager for modular architecture. The `Storage` package contains the data layer and can be developed independently.

## App Store Information

**Category**: Productivity / Health & Fitness
**Platform**: iOS 17.0+
**Languages**: English with localization support
**Widget Support**: Yes
**iCloud Sync**: Not implemented (local storage only)

## Contributing

This appears to be a personal project. For contributions, please follow standard iOS development practices and maintain the existing architectural patterns.

## License

Please refer to the project's license file for usage terms and conditions.