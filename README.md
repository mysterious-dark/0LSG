# Game Overview
A mobile game developed in Godot Engine, designed for one-handed play focusing on simple interactions through buttons and area controls.

## Core Game Phases

### 1. Main GUI (Hub Phase)
- Primary interface where players spend most of their time
- Should be easily navigable with one hand
- Requirements:
  - Clear, easily tappable buttons
  - Intuitive layout for one-handed operation
  - Quick access to all other game phases
  - Status/progress indicators

### 2. Visual Story Phase
- Story-driven content with animations
- Requirements:
  - Simple tap/swipe controls for story progression
  - Character/scene animations
  - Text display system
  - Possible choices/branching system
  - Skip/fast-forward functionality

### 3. Customization/Planning Phase ("My Room")
Features:
- Character/room customization
- Upgrade/enhancement systems
- Planning mechanics
Requirements:
- Drag-and-drop or simple tap interface
- Clear preview of changes
- Easy-to-navigate inventory/options
- Save/load functionality

### 4. Combat Phase
Requirements:
- Simple, one-handed combat controls
- Clear action buttons
- Accessible ability activation
- Visual feedback for actions
- Health/status indicators

## Technical Requirements
- Platform: Mobile (Android/iOS)
- Engine: Godot
- Input: Touch-based, one-handed operation
- Screen Orientation: TBD (Recommend portrait for one-handed play)

## Development Priorities
1. Set up basic navigation between all four phases
2. Implement core UI framework
3. Develop basic systems for each phase
4. Add content and polish

## Next Steps
- [ ] Create initial project structure in Godot
- [ ] Design UI mockups for each phase
- [ ] Implement basic scene transitions
- [ ] Create prototype of each phase
- [ ] Test one-handed usability

## Notes
- All UI elements should be positioned for comfortable one-handed operation
- Consider thumb reachability zones for button placement
- Implement a save system for progress retention
- Ensure all interactive elements are large enough for mobile touch input

# Easiest Components to Implement First

The Main GUI (Hub Phase) is the most straightforward component to implement first for several reasons:
1. Simple UI-based functionality with minimal complex logic
2. Primarily uses built-in Godot UI nodes (Control, Button, Label)
3. Serves as a foundation for navigating to other phases
4. No complex game mechanics or state management required initially

## Recommended Implementation Order (Easiest to Most Complex):
1. Main GUI (Hub) - Navigation and basic UI
2. Visual Story Phase - Text and simple animations
3. Customization/Room Phase - Static customization options
4. Combat Phase - Complex game mechanics and state management

# Modular Structure for GitHub Updates

## Core Components (Rarely Updated)
Place these in a `core/` directory:
```
core/
├── engine/
│   ├── save_system.gd
│   ├── update_manager.gd
│   └── config_manager.gd
├── ui/
│   ├── base_menu.tscn
│   └── common_elements.tscn
└── autoload/
    └── global.gd
```

## Updatable Components
Place these in separate directories that can be easily updated:

```
content/
├── stories/
│   ├── chapter_1/
│   ├── chapter_2/
│   └── story_data.json
├── items/
│   ├── weapons/
│   ├── cosmetics/
│   └── items_data.json
└── combat/
    ├── moves/
    ├── enemies/
    └── combat_data.json
```

## Update System Implementation

### 1. Version Control File
Create a `version.json` in the root:
```json
{
  "core_version": "1.0.0",
  "content_version": "1.0.0",
  "required_core": "1.0.0",
  "update_url": "https://api.github.com/repos/mysterious-dark/LSG/releases/latest"
}
```

### 2. Update Manager Script
```gdscript
extends Node

const VERSION_FILE = "res://version.json"
const CONTENT_PATH = "res://content/"

func check_for_updates():
    # Connect to GitHub API
    # Compare versions
    # Download new content if available
    pass

func update_content():
    # Download new content files
    # Update version.json
    # Reload content
    pass
```

## Implementation Steps

1. Core Setup:
- [ ] Create basic folder structure
- [ ] Implement version control system
- [ ] Set up update manager

2. Main GUI (First Component):
- [ ] Create basic navigation buttons
- [ ] Implement scene transitions
- [ ] Add update check button

3. Content Structure:
- [ ] Set up content folders
- [ ] Create initial story data
- [ ] Implement basic item system

## Notes
- Keep core game logic separate from content
- Use JSON or similar format for easily updatable data
- Implement version checking on startup
- Add manual update button in settings
- Consider implementing delta updates for bandwidth efficiency
