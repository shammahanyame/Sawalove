# Contributing to SawaLove

## Development Workflow
1. **Fork & Clone**
   ```
   git clone https://github.com/YOUR_USERNAME/sawalove.git
   cd sawalove
   flutter pub get
   ```

2. **Branching**
   ```
   git checkout -b feature/discovery-swipe
   # or bugfix/payment-crash
   # or blackboxai/screen-name
   ```

3. **Development Standards**
   - Riverpod for all business logic (no `setState`)
   - GoRouter for navigation
   - `AppLocalizations.of(context)` – no hardcoded strings
   - Match [Design System](../douala_sun/DESIGN.md)
   - `flutter analyze` passes
   - Write widget tests for new components

4. **Commit & PR**
   ```
   git add .
   git commit -m 'feat(discovery): add swipe card stack with animations'
   git push origin feature/discovery-swipe
   ```
   - PR to `main` with screenshots
   - Update [TODO.md](../TODO.md)

## Commands
```
flutter analyze          # Lint
flutter format .         # Format
flutter test             # Tests
flutter pub get          # Deps
dart fix --apply         # Auto-fix lints
```

## Testing
- Unit: Services/Providers (`test/`)
- Widget: Key screens (swipe, chat bubble)
- Manual: Mid-range Android (Tecno/Samsung A-series), textScale 1.5x, dark mode

## Features Priority
See [TODO.md](../TODO.md)

Thanks for contributing! 🇨🇲✨

