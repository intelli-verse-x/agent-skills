---
name: ivx-qv-scriptable-objects
description: Create and manage ScriptableObject configs, data assets, and data-driven design patterns in QuizVerse.
version: "1.0"
---

## When to Use
"ScriptableObject", "config", "data asset", "SO", "configuration", "settings asset"

## Existing ScriptableObjects in QuizVerse
| Config | Script | Purpose |
|--------|--------|---------|
| Score config | `UnifiedScoreConfig` | Scoring rules per mode |
| Rhythm score | `RhythmScoreConfig` | Rhythm quiz scoring |
| ASMR config | `ASMRConfig` | ASMR mode settings |
| Game themes | `LearningGameTheme` | Arcade game visuals |
| Topics DB | `VisualModeTopicsDatabase` | Visual mode topic data |
| IAP catalog | `IAPRewardCatalogSO` | Purchase reward definitions |
| Compatibility | `CompatibilityQuizConfig` | Compatibility quiz settings |
| AI Voice | `AIVoiceConfig` | AI host voice settings |
| Async challenge | `AsyncChallengeConfig` | Async mode settings |
| Link&Play test | `LinkAndPlayTestConfig` | Test configurations |
| Beat Mastery | `BeatMasteryS3Config` | Beat game S3 paths |

## Creation Pattern
```csharp
[CreateAssetMenu(fileName = "NewConfig", menuName = "QuizVerse/ConfigName")]
public class MyConfig : ScriptableObject
{
    [Header("Settings")]
    [SerializeField] private int _maxRetries = 3;
    [SerializeField] private float _timeout = 10f;
    
    // Public read-only properties
    public int MaxRetries => _maxRetries;
    public float Timeout => _timeout;
}
```

## Best Practices
- `[CreateAssetMenu]` for easy asset creation
- `[SerializeField] private` + public readonly property
- Store in `Assets/_QuizVerse/Data/` or `Assets/_QuizVerse/Configs/`
- Reference via `[SerializeField]` on MonoBehaviours (not `Resources.Load`)
- Use for: tuning values, reward tables, theme definitions, feature flags

## MCP Creation
```
manage_scriptable_object(action="create", type_name="MyConfig", 
    folder_path="Assets/_QuizVerse/Configs", asset_name="DefaultConfig")
manage_scriptable_object(action="modify", target={"path": "Assets/..."}, 
    patches=[{"path": "property", "value": 42}])
```

## Anti-Patterns
- ❌ Don't put game logic in SOs — data only
- ❌ Don't use `Resources.Load<SO>()` — use serialized refs
- ❌ Don't mutate SO fields at runtime (they persist in editor!)
