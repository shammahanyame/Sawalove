# Design System Specification: Premium African Modern

## 1. Overview & Creative North Star
**The Creative North Star: "The Radiant Soul"**
This design system moves away from the clinical, "tech-first" aesthetic of Western dating apps to embrace a "Premium African Modern" philosophy. It is designed to feel as vibrant as a Douala sunset and as sophisticated as high-end contemporary African editorial. 

The experience is defined by **Radiant Depth**. We reject the flat, grid-locked "template" look in favor of intentional asymmetry, overlapping photo elements, and a "stacked paper" depth model. This system prioritizes trust through exquisite typography and high-contrast tonal layering, ensuring the user feels they are in a curated, premium space rather than a generic digital marketplace.

---

## 2. Colors: Vibrancy Through Tonal Logic
Our palette is anchored in energetic magentas and deep berry tones, balanced by a sophisticated "warm-white" foundation.

### Core Palette (Material Convention)
*   **Primary:** `#b30065` (Vibrant Magenta) - Use for critical brand moments and high-intent actions.
*   **Primary Container:** `#ff6ea9` - Use for large surface areas or "soft" primary backgrounds.
*   **Secondary:** `#8329c8` (Royal Purple) - Used for premium features or "Verified" status accents.
*   **Tertiary:** `#00647c` (Deep Teal) - Provides a calming, trustworthy contrast to the energetic pinks.
*   **Surface:** `#fff4f6` (Warm Blush White) - The foundation for all screens.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined solely through:
1.  **Background Color Shifts:** Placing a `surface-container-low` card against a `surface` background.
2.  **Vertical Space:** Utilizing the spacing scale to allow the eye to perceive boundaries.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Each inner container should shift one tier in the surface stack:
*   **Base Layer:** `surface` (`#fff4f6`)
*   **In-Page Sections:** `surface-container-low` (`#ffecf1`)
*   **Elevated Cards:** `surface-container-lowest` (`#ffffff`) for maximum "pop" and cleanliness.

### Signature Textures
Avoid flat backgrounds on Hero sections. Use a subtle linear gradient transitioning from `primary` (`#b30065`) to `primary-container` (`#ff6ea9`) at a 135° angle to add "soul" and dimension.

---

## 3. Typography: Editorial Authority
The type system uses a dual-font approach to balance personality with extreme readability for bilingual (English/French) contexts.

| Level | Font Family | Size | Intent |
| :--- | :--- | :--- | :--- |
| **Display-LG** | Plus Jakarta Sans | 3.5rem | High-impact marketing/onboarding. |
| **Headline-MD** | Plus Jakarta Sans | 1.75rem | Profile names and major section headers. |
| **Title-LG** | Be Vietnam Pro | 1.375rem | Modal headers and card titles. |
| **Body-LG** | Be Vietnam Pro | 1rem | User bios and chat messages. |
| **Label-MD** | Be Vietnam Pro | 0.75rem | Small metadata (Location, Age, Status). |

**Editorial Note:** Use tight letter-spacing (-0.02em) for Display styles to create a "custom-fitted" look. For Body text in French, ensure line-height is set to 1.5 to accommodate the increased character count and accents.

---

## 4. Elevation & Depth: Tonal Layering
We achieve hierarchy through "soft physics" rather than artificial shadows.

*   **The Layering Principle:** Depth is achieved by "stacking." Place a white card (`surface-container-lowest`) on a blush background (`surface-container-low`) to create a natural lift.
*   **Ambient Shadows:** If a floating element (like a FAB) is required, use an extra-diffused shadow: `box-shadow: 0 12px 32px rgba(74, 33, 52, 0.08);`. Note the shadow color uses a tint of `on-surface` (`#4a2134`)—**never pure black.**
*   **Glassmorphism:** For the navigation bar and top app bars, use a backdrop-blur effect: `background: rgba(255, 244, 246, 0.8); backdrop-filter: blur(12px);`. This makes the layout feel integrated and premium.
*   **Ghost Borders:** If a border is required for a secondary button or input, use `outline-variant` (`#d89cb4`) at **20% opacity**.

---

## 5. Components

### Buttons
*   **Primary:** `primary` background with `on-primary` text. Roundedness: `full`.
*   **Secondary:** `primary-container` background with `on-primary-container` text.
*   **Tertiary:** No background. Bold `primary` text. Use for "Skip" or secondary navigation.

### Cards (Profile/Discovery)
*   **Constraint:** No borders or heavy shadows.
*   **Styling:** Use `rounded-lg` (2rem). Content (name/age) should overlap the bottom of the image using a semi-transparent glass container (`surface-variant` at 80% opacity with blur).

### Input Fields
*   **Background:** `surface-container-highest`.
*   **Corners:** `md` (1.5rem) to maintain a "friendly" feel.
*   **State:** On focus, the ghost border becomes 100% opaque `primary`.

### Navigation (The "Sawa" Bar)
*   Instead of a flat bar, use a floating bottom bar with `xl` (3rem) rounding. Use the Glassmorphism rule to let user profile photos peek through as they scroll.

### Bilingual Considerations
*   **Auto-Layout:** Use flexible Figma/Code containers. French strings are often 20-30% longer than English. Never use fixed-width buttons.

---

## 6. Do's and Don'ts

### Do
*   **DO** use asymmetric layouts for profile galleries (e.g., one large image followed by two small stacked images).
*   **DO** use "Primary" for high-emotion actions like "Like" or "Match."
*   **DO** use `surface-bright` for the cleanest possible background on high-density chat screens.

### Don't
*   **DON'T** use black (`#000000`) for text. Use `on-surface` (`#4a2134`) for a softer, premium feel.
*   **DON'T** use the `none` or `sm` roundedness tokens for UI containers; this system is "Soft Modern," and sharp corners break the brand trust.
*   **DON'T** use divider lines. If content needs separation, use an 8px or 16px gap of empty space.