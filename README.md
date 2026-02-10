# Homebrew Tap

[日本語](README.ja.md)

This tap provides FFmpeg formulae with a full codec set (gyan.dev full equivalent) and FDK-AAC support.

## Installation

Add this tap:

```bash
brew tap bear10591/homebrew-tap
```

## Available Formulae

| Formula        | Description |
|----------------|-------------|
| `ffmpeg`       | Full FFmpeg build; replaces Homebrew's core `ffmpeg` when linked |
| `ffmpeg-ursus` | Same full build as keg-only (versioned); does not override core `ffmpeg` |
| `arib2bdnxml`  | ARIB caption to BDN XML converter |

---

## Difference between `ffmpeg` and `ffmpeg-ursus`

Both formulae build **the same FFmpeg**: full codec set (gyan.dev full equivalent) and FDK-AAC. The only difference is **how they are installed and linked**.

| Aspect | ffmpeg | ffmpeg-ursus |
|--------|--------|--------------|
| **Linking** | Linked into your prefix; overrides Homebrew core `ffmpeg` | **Keg-only** (versioned); does **not** override core `ffmpeg` |
| **Default command** | `ffmpeg` runs this build after install | `ffmpeg` still runs core/system FFmpeg unless you link or adjust PATH |
| **Use case** | Use this full build as your main `ffmpeg` | Keep core `ffmpeg` and use this build only when needed |

### When to use `ffmpeg`

- You want this full build (FDK-AAC, full codecs) to be your default `ffmpeg`.
- You are okay with replacing Homebrew's core `ffmpeg`.

```bash
brew install bear10591/homebrew-tap/ffmpeg
# ffmpeg, ffprobe, etc. will point to this build
```

### When to use `ffmpeg-ursus`

- You want to keep Homebrew's core `ffmpeg` as default.
- You want this full build installed side-by-side and use it only when needed.

```bash
brew install bear10591/homebrew-tap/ffmpeg-ursus
# To use these binaries:
brew link ffmpeg-ursus
# or add $(brew --prefix ffmpeg-ursus)/bin to your PATH
```

### Summary

- **Same build**: same codecs, same options, same FDK-AAC.
- **ffmpeg**: "replace default ffmpeg with this build."
- **ffmpeg-ursus**: "install this build separately; don't touch default ffmpeg."

---

## Notes

- Both FFmpeg formulae include the **non-free FDK-AAC** encoder. Be aware of licensing when redistributing binaries.
- Build reference: [gyan.dev FFmpeg builds](https://www.gyan.dev/ffmpeg/builds/).
