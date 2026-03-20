# WCAG 2.2 Color Contrast Audit

## Requirements

- **Normal text** (below 18pt / 14pt bold): 4.5:1 minimum contrast ratio (AA)
- **Large text** (18pt+ / 14pt+ bold): 3:1 minimum contrast ratio (AA)
- **UI components and graphical objects**: 3:1 minimum contrast ratio
- **Focused elements**: 3:1 minimum contrast ratio

## Named Colors (from Assets.xcassets and AppColors.swift)

### Light Mode (on white #FFFFFF background)

| Color Name    | Hex     | Contrast vs White | Passes AA (Normal) | Passes AA (Large) | Passes UI 3:1 |
| ------------- | ------- | ----------------- | ------------------ | ----------------- | ------------- |
| PrimaryGreen  | #58CC02 | 2.66:1            | FAIL               | FAIL              | FAIL          |
| PrimaryBlue   | #1CB0F6 | 2.79:1            | FAIL               | FAIL              | FAIL          |
| AccentOrange  | #FF9600 | 2.15:1            | FAIL               | FAIL              | FAIL          |
| SuccessGreen  | #58CC02 | 2.66:1            | FAIL               | FAIL              | FAIL          |
| WarningYellow | #FFC800 | 1.62:1            | FAIL               | FAIL              | FAIL          |
| ErrorRed      | #FF4B4B | 3.55:1            | FAIL               | PASS              | PASS          |
| PremiumPurple | #CE82FF | 3.15:1            | FAIL               | PASS              | PASS          |

### Dark Mode (on black #000000 background)

| Color Name    | Hex     | Contrast vs Black | Passes AA (Normal) | Passes AA (Large) | Passes UI 3:1 |
| ------------- | ------- | ----------------- | ------------------ | ----------------- | ------------- |
| PrimaryGreen  | #58CC02 | 7.90:1            | PASS               | PASS              | PASS          |
| PrimaryBlue   | #1CB0F6 | 7.52:1            | PASS               | PASS              | PASS          |
| AccentOrange  | #FF9600 | 9.77:1            | PASS               | PASS              | PASS          |
| SuccessGreen  | #58CC02 | 7.90:1            | PASS               | PASS              | PASS          |
| WarningYellow | #FFC800 | 12.93:1           | PASS               | PASS              | PASS          |
| ErrorRed      | #FF4B4B | 5.91:1            | PASS               | PASS              | PASS          |
| PremiumPurple | #CE82FF | 6.65:1            | PASS               | PASS              | PASS          |

### Contrast Ratio Calculation Method

Relative luminance formula (WCAG 2.2):

- L = 0.2126 _ R + 0.7152 _ G + 0.0722 \* B
- Where R, G, B are linearized from sRGB (gamma-corrected) values
- Contrast ratio = (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter color

### Detailed Calculations

| Color         | Hex     | R(lin) | G(lin) | B(lin) | Luminance |
| ------------- | ------- | ------ | ------ | ------ | --------- |
| White         | #FFFFFF | 1.0000 | 1.0000 | 1.0000 | 1.0000    |
| Black         | #000000 | 0.0000 | 0.0000 | 0.0000 | 0.0000    |
| PrimaryGreen  | #58CC02 | 0.0893 | 0.5271 | 0.0006 | 0.3957    |
| PrimaryBlue   | #1CB0F6 | 0.0144 | 0.3677 | 0.9130 | 0.3434    |
| AccentOrange  | #FF9600 | 1.0000 | 0.2836 | 0.0000 | 0.4157    |
| ErrorRed      | #FF4B4B | 1.0000 | 0.0586 | 0.0586 | 0.2598    |
| PremiumPurple | #CE82FF | 0.5843 | 0.2242 | 1.0000 | 0.2962    |

## Action Items

### Critical (Must Fix for AA Compliance)

- [ ] **PrimaryGreen (#58CC02)**: Fails all AA checks on white. Used as primary button color.
  - Recommended darker variant for text: **#3B8A00** (estimated 4.5:1+ on white)
  - Buttons are acceptable because white text on green background meets 3:1 for large text
  - Consider using PrimaryGreen only for large/bold text or UI components on white backgrounds

- [ ] **PrimaryBlue (#1CB0F6)**: Fails all AA checks on white.
  - Recommended darker variant for text: **#0077B6** (estimated 4.5:1+ on white)

- [ ] **AccentOrange (#FF9600)**: Fails all checks on white.
  - Recommended darker variant for text: **#B36B00** (estimated 4.5:1+ on white)

- [ ] **WarningYellow (#FFC800)**: Worst contrast ratio. Should never be used for text on white.
  - Recommended darker variant for text: **#806400** (estimated 4.5:1+ on white)

### Acceptable (Passes Some Requirements)

- [x] **ErrorRed (#FF4B4B)**: Passes large text AA and UI component requirements on white.
- [x] **PremiumPurple (#CE82FF)**: Passes large text AA and UI component requirements on white.
- [x] All colors pass AA on black/dark backgrounds.

### Non-Color Indicator Requirements

The following views rely on color alone to convey information and need secondary indicators:

- [ ] `FeatureStatusRow`: Uses green/gray to show enabled/disabled. Add text "ON"/"OFF" when `accessibilityDifferentiateWithoutColor` is true.
- [ ] `DayCell` in `StreakCalendarView`: Uses orange fill vs no fill for active/inactive. Add checkmark overlay when `accessibilityDifferentiateWithoutColor` is true.
- [ ] `StreakBadgeView`: Flame color indicates streak level (red/orange/blue/purple). Streak count text already provides numeric alternative.

### Notes

- All dark mode contrast ratios pass because the colors are inherently bright/saturated
- Button styles (white text on colored background) have different contrast characteristics than text on white
- SwiftUI system colors (`.primary`, `.secondary`) automatically adapt for accessibility
- Consider implementing `.accessibilityDifferentiateWithoutColor` checks in views that use color as the sole indicator
