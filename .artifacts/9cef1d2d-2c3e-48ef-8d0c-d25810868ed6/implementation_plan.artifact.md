# Implementation Plan - UI/UX and Logic Improvements for Tabs

This plan outlines the steps to upgrade the AI Assistant, Random Dish, User Preferences, and Health Stats features to match the provided designs and improve functionality.

## User Review Required

> [!IMPORTANT]
> The `UserPreferences` model will be significantly expanded. This might require clearing existing local data if there's any persistent storage (though currently it seems in-memory).
> AI Assistant logic will be updated to handle "Structured Responses" (like recipe cards and step-by-step instructions).

## Proposed Changes

### 1. Data Models & ViewModels

#### [MODIFY] [user_preferences.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/models/user_preferences.dart)
- Add fields for:
    - Cooking level (Easy, Medium, Hard, Pro)
    - Kitchen preference (Home-cooked, Eat out, Both)
    - Default eaters count
    - Preferred meal times (List)
    - Allergies (List)
    - Favorite cuisines (List)
    - Spiciness level (None to Very Spicy)
    - Health profile: height, weight, gender, birth year, activity level, calorie goal.

#### [MODIFY] [profile_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/profile_viewmodel.dart)
- Add calculation logic for BMI and TDEE based on health profile.
- Add methods to update individual segments of preferences.

#### [MODIFY] [chatbot_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/chatbot_viewmodel.dart)
- Update `ChatMessage` to support "Content Types": Text, Recipe List, Recipe Detail (Ingredients + Steps).
- Update AI logic to try and prompt for structured data when recipes are found.

---

### 2. AI Assistant (Trợ lý của tôi)

#### [MODIFY] [chatbot_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/chatbot/chatbot_screen.dart)
- Redesign Header: Add message history (clock icon) and new chat (+) buttons.
- Redesign Bubbles: Match the orange gradient for user and white for AI.
- Implement specialized message widgets:
    - `RecipeListMessage`: Horizontal/Vertical cards for multiple recipes.
    - `RecipeStepMessage`: Instruction card with "Next Step" and "View All" buttons.
- Update Input Bar: Add image attachment and voice input icons.

---

### 3. Random Dish (Ăn theo ý trời)

#### [MODIFY] [random_dish_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/random_dish_screen.dart)
- Redesign UI to match the "Modal" look with blurry background.
- Add "AI is ready" state with shake animation.
- Implement confetti effect on success.
- Redesign result card with detailed recipe info and tags.

---

### 4. Settings & Preferences

#### [MODIFY] [preference_settings_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/preference_settings_screen.dart)
- Split into two main sections/screens if necessary: "Cooking Skills" and "Dietary Preferences".
- Use icons for diet types and allergies.
- Add "Budget" and "Meal Times" selectors.

---

### 5. Health Stats (Chỉ số sức khỏe)

#### [MODIFY] [health_stats_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/health_stats_screen.dart)
- Implement empty state UI.
- Create `HealthProfileFormScreen` or modal for data input.
- Show BMI and TDEE result boxes with informational text.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no regression.

### Manual Verification
- Verify AI Assistant can display recipes in cards.
- Test "Random Dish" shake/spin functionality and confetti.
- Verify health calculations (BMI/TDEE) are correct.
- Check that all preferences are saved and reflected in the UI.
