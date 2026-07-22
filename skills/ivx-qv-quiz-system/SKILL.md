---
name: ivx-qv-quiz-system
description: Work with quiz modes, question fetching, scoring, timers, and the unified question panel in QuizVerse.
version: "1.0"
---

## When to Use
"quiz", "question", "answer", "timer", "score", "quiz mode", "daily quiz", "weekly quiz"

## Data Pipeline
```
QuizQuestionService → Nakama RPCs / S3 CSV
    → QuestionRepository (cache)
    → QuizMode controller (19 modes)
    → UnifiedQuizQuestionPanel (display)
    → ScoreManager → GameSessionManager (lifecycle)
```

## 19 Quiz Modes (under Screen_Canvas/Quizzes/)
| Mode | Controller | Special |
|------|-----------|---------|
| MultipleChoice | `MultipleChoiceMode` | Classic 4-option |
| TrueFalse | `TrueFalseMode` | Binary choice |
| SpeedQuiz | `SpeedQuizMode` | Timed rapid-fire |
| ImageGuess | `ImageGuessQuizMode` | Visual recognition |
| MediaQuiz | `MediaQuizMode` | Audio/Video + AudioSource/VideoPlayer |
| GeoExplore | `GeoExploreMode` | Map-based |
| BrainSprint | `BrainSprintMode` | Rapid difficulty ramp |
| WhosThat | `WhosThatMode` | Silhouette reveal |
| Connection | `ConnectionMode` | Link concepts |
| ViralIQ | `ViralIQMode` | Trending topics |
| CustomTopic | `CustomTopicMode` | AI-generated |
| PickATopic | `PickATopicQuizMode` | Category select |
| DailyQuiz | `DailyQuizUnifiedMode` | Daily reset (DailyQuizManager) |
| WeeklyQuiz | `WeeklyQuizMode` | Weekly reset (WeeklyQuizzesManager) |
| Compatibility | `CompatibilityQuizUIController` | Two-player personality |
| Subjective | `SubjectiveQuizScreen` | Essay/open-ended |
| Link&Play | `LinkAndPlayScreen` | Shared link multiplayer |
| AIHost | `AIHostSceneSetup` | Voice-driven AI host |
| AIFortuneTeller | `AIFortuneTellerSceneSetup` | AI fortune reading |

## Key GameObjects
- `Manager` GO → `QuestionRepository`, `DailyQuizManager`, `DailyPremiumQuizManager`, `QuizMediaService`
- `Screen_Canvas/UnifiedQuestionPanel` → `UnifiedQuizQuestionPanel` + AudioSource + VideoPlayer
- `WeeklyQuizManger` GO → `WeeklyQuizzesManager`

## Context Files (load only if needed)
- Quiz Manager API: `docs/context/micro/QUIZ_MANAGER_INTERFACE.md` (3.3 KB)
- Daily Quiz API: `docs/context/micro/DAILY_QUIZ_INTERFACE.md` (3.1 KB)
- Economy: `docs/context/micro/ECONOMY_INTERFACE.md` (1.5 KB)
- State ownership: `docs/context/micro/STATE_OWNERSHIP.md` (6.5 KB)
