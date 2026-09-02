# oorukai_core

Shared Flutter code for Oorukai's games: Squeeze, Vertex, Santa Drop.

Not published to pub.dev — each game depends on it via a local `path:`
dependency:

```yaml
dependencies:
  oorukai_core:
    path: ../oorukai-core
```

## What's here

- **Splash screen** (`OorukaiSplashScreen`) — the studio's branded splash
  shown on cold start, plus the underlying `assets/branding/` artwork and
  the `isCoverSafe`/`coverMappedRect`/`containMappedRect` geometry helpers
  used to crop it safely per device aspect ratio.

See `CLAUDE.md` for scope and conventions, including how to migrate a new
piece of shared code in here.
