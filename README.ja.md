# Homebrew Tap

[English](README.md)

この tap は、フルコーデックセット（gyan.dev full 相当）と FDK-AAC を有効にした FFmpeg フォーミュラを提供します。

## インストール

この tap を追加します：

```bash
brew tap bear10591/homebrew-tap
```

## 利用可能なフォーミュラ

| フォーミュラ   | 説明 |
|----------------|------|
| `ffmpeg`       | フルビルドの FFmpeg。リンク時に Homebrew の公式 `ffmpeg` を置き換えます |
| `ffmpeg-ursus` | 同じフルビルドを keg-only（バージョン付き）でインストール。公式 `ffmpeg` は置き換えません |
| `arib2bdnxml`  | ARIB キャプションを BDN XML に変換するツール |

---

## `ffmpeg` と `ffmpeg-ursus` の違い

どちらのフォーミュラも**同じ FFmpeg** をビルドします（フルコーデックセット + FDK-AAC）。違うのは**インストールとリンクのされ方**だけです。

| 項目 | ffmpeg | ffmpeg-ursus |
|------|--------|--------------|
| **リンク** | プレフィックスにリンクされ、Homebrew の公式 `ffmpeg` を**上書き**する | **Keg-only**（バージョン付き）。公式 `ffmpeg` は**上書きしない** |
| **デフォルトのコマンド** | インストール後、`ffmpeg` はこのビルドを指す | リンクや PATH を変えない限り、`ffmpeg` は公式/システムの FFmpeg のまま |
| **想定用途** | このフルビルドをメインの `ffmpeg` にしたい場合 | 公式 `ffmpeg` はそのままにして、必要な時だけこのビルドを使いたい場合 |

### `ffmpeg` を使う場合

- このフルビルド（FDK-AAC・フルコーデック）をデフォルトの `ffmpeg` にしたい。
- Homebrew の公式 `ffmpeg` を置き換えてよい。

```bash
brew install bear10591/homebrew-tap/ffmpeg
# ffmpeg, ffprobe などはこのビルドを指します
```

### `ffmpeg-ursus` を使う場合

- 公式の `ffmpeg` をデフォルトのままにしたい。
- このフルビルドは別としてインストールし、必要な時だけ使いたい。

```bash
brew install bear10591/homebrew-tap/ffmpeg-ursus
# このビルドを使うには：
brew link ffmpeg-ursus
# または $(brew --prefix ffmpeg-ursus)/bin を PATH に追加
```

### まとめ

- **ビルド内容は同じ**：コーデック・オプション・FDK-AAC も同一。
- **ffmpeg**：「デフォルトの ffmpeg をこのビルドに差し替える。」
- **ffmpeg-ursus**：「このビルドは別インストール。デフォルトの ffmpeg は触らない。」

---

## 注意事項

- 両方の FFmpeg フォーミュラには**非フリーの FDK-AAC** エンコーダが含まれます。バイナリの再配布時はライセンスに注意してください。
- ビルドの参考: [gyan.dev FFmpeg builds](https://www.gyan.dev/ffmpeg/builds/)。
