---
name: ivx-qv-editor-tools
description: Create custom Unity Editor inspectors, windows, and build tools for QuizVerse development.
version: "1.0"
---

## When to Use
"editor tool", "custom inspector", "editor window", "MenuItem", "build tool", "editor script"

## Existing Editor Scripts
- `Tools/Editor/URPSetupUtility.cs` — Pipeline setup
- `Editor/AppodealPhotonConflictFix.cs` — Dependency conflict resolver

## Custom Inspector Pattern
```csharp
#if UNITY_EDITOR
using UnityEditor;

[CustomEditor(typeof(MyComponent))]
public class MyComponentEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        
        var comp = (MyComponent)target;
        
        if (GUILayout.Button("Test Action"))
            comp.DoSomething();
    }
}
#endif
```

## Editor Window Pattern
```csharp
#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

public class MyToolWindow : EditorWindow
{
    [MenuItem("QuizVerse/My Tool")]
    public static void ShowWindow()
        => GetWindow<MyToolWindow>("My Tool");

    private void OnGUI()
    {
        GUILayout.Label("Tool Settings", EditorStyles.boldLabel);
        if (GUILayout.Button("Execute"))
            Execute();
    }
}
#endif
```

## Rules
- Always wrap in `#if UNITY_EDITOR` / `#endif`
- Place in `Assets/_QuizVerse/Scripts/Editor/` folder
- Use `[MenuItem("QuizVerse/...")]` for menu items
- Never reference Editor APIs from runtime scripts
- Template available: `.cursor/examples/EDITOR_TOOL_TEMPLATE.cs` (14 KB)
