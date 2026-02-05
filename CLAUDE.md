# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PetManager is a native iOS application built with SwiftUI for managing pets. It connects to a backend API running at `http://localhost:8000`.

## Build and Run Commands

```bash
# Open in Xcode
open petmanager.xcodeproj

# Build from command line
xcodebuild -scheme petmanager -configuration Debug

# Run tests
xcodebuild test -scheme petmanager -destination 'platform=iOS Simulator,name=iPhone 17'

# Run specific test class
xcodebuild test -scheme petmanager -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:petmanagerTests/TestClassName

# Run specific test method
xcodebuild test -scheme petmanager -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:petmanagerTests/TestClassName/testMethodName
```

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

```
petmanager/
├── Models/         # Data structures (Pet, Appointment, request models)
├── ViewModels/     # State management (@Published properties, Combine)
├── Services/       # API layer (PetService singleton with Combine publishers)
└── Views/          # SwiftUI views
```

**Data Flow:**
- Views observe ViewModels via `@EnvironmentObject`
- ViewModels call Services and expose `@Published` properties
- Services return Combine `AnyPublisher` types for async operations
- Cancellables stored in ViewModels to manage subscription lifecycle

## Key Patterns

- **Tab Navigation**: MainTabView contains 4 tabs (Home, Pets, Health, Settings)
- **API Mapping**: Pet model maps API field `species` to local `breed`; local-only fields (imageName) use `CodingKeys` to exclude from API encoding
- **Singleton Service**: `PetService.shared` for all API calls

## API Endpoints

The backend provides these endpoints:

**Pets:**
- `GET/POST /pets` - List/create pets
- `GET/PATCH/DELETE /pets/{id}` - Single pet operations
- `GET/POST /users/{userId}/pets` - User-specific pet operations

**Appointments:**
- `GET /pets/{petId}/appointments` - List appointments for a pet
- `POST /pets/{petId}/appointments` - Create appointment for a pet
- `PATCH /appointments/{id}` - Update an appointment
- `DELETE /appointments/{id}` - Delete an appointment

## Date Formats

- **Pet birthday**: `YYYY-MM-DD` format (e.g., `"2023-05-15"`)
- **Appointment datetime**: ISO8601 format (e.g., `"2026-02-10T10:30:00Z"`)
