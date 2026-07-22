---
name: ivx-cf-visual-evaluation
description: Evaluate AI-generated visual content for quality, consistency, and adherence to requirements. Use when reviewing generated images or videos.
---
# Visual Evaluation Skill

## Purpose

Systematically evaluate generated visual content quality.

## Dimensions

| Dimension | Criteria | Score |
|-----------|----------|-------|
| Prompt Adherence | Subject matches prompt | 1-5 |
| Quality | Sharpness, detail, no artifacts | 1-5 |
| Style | Matches reference/style guide | 1-5 |
| Composition | Framing, balance, interest | 1-5 |
| Consistency | Matches previous scenes | 1-5 |
| Technical | Resolution, aspect ratio, format | Pass/Fail |

## Automated Metrics

- FID (Frechet Inception Distance)
- CLIP score (text-image similarity)
- LPIPS (perceptual similarity)
- Aesthetic score (predictor)

## Manual Review

- Side-by-side with reference
- Checklist per dimension
- Multiple reviewers for calibration
- Document outliers and failure modes

## CF-Specific

- Compare to brand style guide
- Verify character identity consistency
- Check no unwanted text/watermarks
- Audio sync for video
- Frame-level consistency (video)

## Report Template

```markdown
## Visual Evaluation: [Asset]

### Scores
| Dimension | Score | Notes |
|-----------|-------|-------|
| Prompt Adherence | X/5 | [...] |
| Quality | X/5 | [...] |
| Style | X/5 | [...] |

### Issues
- [ ] Issue 1
- [ ] Issue 2

### Recommendation
[Approve / Regenerate / Modify]
```
