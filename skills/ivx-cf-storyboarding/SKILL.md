---
name: ivx-cf-storyboarding
description: Create visual storyboards and scene plans for AI-generated content. Use when planning creative campaigns, designing narrative flow, or structuring video content.
---
# Storyboarding Skill

## Purpose

Plan visual content through structured storyboards before generation.

## Storyboard Elements

| Element | Description |
|---------|-------------|
| Scene # | Sequential identifier |
| Shot Type | Wide, medium, close-up, POV |
| Duration | Seconds |
| Description | Action, motion, composition |
| Visual Ref | Reference image or sketch |
| Audio | Dialogue, music, SFX cues |
| Transitions | Cut, fade, dissolve |

## Template

```markdown
## Storyboard: [Project]

### Scene 1: [Name]
- **Shot**: Wide establishing shot
- **Duration**: 5s
- **Description**: [Camera movement, subject action, environment]
- **Visual Ref**: [Link or description]
- **Audio**: [Music mood, ambient sound]
- **Transition**: Cut to Scene 2

### Scene 2: [Name]
- **Shot**: Medium shot
- **Duration**: 3s
- **Description**: [...]
```

## Best Practices

- Plan 2-6 second clips per shot
- Vary shot types for visual interest
- Match audio to visual pacing
- Include transition timing
- Reference specific visual styles

## CF Integration

- Storyboard feeds into pipeline parameters
- Each scene generates one or more pipeline tasks
- Visual refs used for style consistency
- Audio cues passed to voice/music generators
