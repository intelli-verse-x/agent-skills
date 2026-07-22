---
name: ivx-qv-localization
description: Manage multi-language support, RTL text, CSV translation, and localization in QuizVerse.
version: "1.0"
---

## When to Use
"localize", "translate", "language", "RTL", "i18n", "localization", "multi-language"

## Architecture
```
SceneLocalizationManager (root GO) → runtime locale switching
IVXLocalizationManagerAdapter → SDK bridge
QuizVerseLanguageManager → language code mappings
CSV files on S3/CDN → translation data per language
```

## Language Code Mapping
> ⚠️ **Common bug source**: API uses `en`, CSV uses `English`. Always verify code matches.

## Patterns
```csharp
// Get localized string
string text = LocalizationManager.Instance.GetText("key_name");

// Set language
LocalizationManager.Instance.SetLanguage("en");

// RTL check
bool isRTL = LocalizationManager.Instance.IsRTL;
```

## RTL Handling
- Reverse layout direction for Arabic, Hebrew, Urdu
- TMP supports RTL natively (`isRightToLeftText = true`)
- Mirror horizontal padding/margins
- Flip navigation arrows

## CSV Format
```
key,en,ar,hi,es,fr
welcome_title,Welcome!,!مرحبا,स्वागत है!,¡Bienvenido!,Bienvenue!
```

## Rules
- All user-facing strings MUST use localization keys
- Never hardcode display text in C#
- Test with longest language (German) for overflow
- Test RTL with Arabic for layout mirroring
