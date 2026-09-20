# oorukai_core

Shared Flutter code for Oorukai's games: Squeeze, Vertex, Santa Drop.

Not published to pub.dev. Each game depends on it as a `git:` dependency,
which is what `oorukai-core-starter` generates and what every game ships:

```yaml
dependencies:
  oorukai_core:
    git:
      url: https://github.com/h4554n1n/oorukai-core.git
```

This repo is public, so that resolves with no credentials — including on
CI runners, which only ever hold a token for the game's own repo.

While you are editing `oorukai_core` itself, swap those lines for a sibling
checkout so changes take effect without pushing:

```yaml
dependencies:
  oorukai_core:
    path: ../oorukai-core
```

Swap it back before committing the game.

## What's here

- **Splash screen** (`OorukaiSplashScreen`) — the studio's branded splash
  shown on cold start, plus the underlying `assets/branding/` artwork and
  the `isCoverSafe`/`coverMappedRect`/`containMappedRect` geometry helpers
  used to crop it safely per device aspect ratio.

See `CLAUDE.md` for scope and conventions, including how to migrate a new
piece of shared code in here.
