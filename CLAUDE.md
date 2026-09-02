# CLAUDE.md

## What this is
Shared Flutter code for Oorukai's games — Squeeze, Vertex, Santa Drop.
Consumed as a `path:` dependency (see `pubspec.yaml` in each game), not
published to pub.dev.

## Project commands
- Test: `flutter test`
- Lint: `flutter analyze`

## Scope
Only code identical or near-identical across at least two games belongs
here: studio-branding UI (e.g. the splash screen) and the vendor-wrapper
services (crash reporting, analytics, ads, purchases, haptics,
leaderboards). Game logic — rendering, physics, scoring, game state — stays
in each game's own repo. When in doubt, leave it in the game repo until a
second game needs the same thing.

## Conventions
- Every vendor-wrapper service is `abstract class`/`abstract interface
  class` plus a `Noop*` default and a real SDK-backed implementation, with
  every SDK call an injectable constructor parameter — no
  `flutter_test`-compatible fake exists for most of these SDKs, so tests
  exercise the wrapper's own logic via injected fakes, never a real
  platform channel. A real implementation never throws back into
  game/screen code: swallow and no-op instead.
- No feature is migrated here speculatively. It moves once a second
  consumer needs it, adapting call sites in each game as part of that move.
- Bundled assets (e.g. `assets/branding/`) are loaded by consumers via
  `Image.asset(path, package: 'oorukai_core')` — see
  `OorukaiSplashArt.assetPackage`.

## Migrating a service from a game repo
1. Copy the interface + implementations here, generalising only what
   actually differs between the games (constructor params, not new
   abstractions).
2. Add tests here covering the wrapper's own logic (init guarding,
   no-op-until-ready, error swallowing) — not the vendor SDK itself.
3. Update each consuming game to depend on the shared type and delete its
   local copy in the same change.
