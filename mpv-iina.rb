class MpvIina < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.35.0.tar.gz"
  sha256 "dc411c899a64548250c142bf1fa1aa7528f1b4398a24c86b816093999049ec00"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  keg_only "it is intended to only be used for building IINA. This formula is not recommended for daily use"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.11" => :build
  depends_on xcode: :build
  depends_on "bear10591/tap/ffmpeg-iina"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "libbluray"
  depends_on "mujs"
  depends_on "uchardet"
  # depends_on "vapoursynth"
  depends_on "yt-dlp/taps/yt-dlp"

  fails_with gcc: "5" # ffmpeg is compiled with GCC

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"

    args = %W[
      --prefix=#{prefix}
      --enable-javascript
      --enable-libmpv-shared
      --enable-lua
      --enable-libarchive
      --enable-uchardet
      --enable-libbluray
      --disable-swift
      --disable-debug-build
      --disable-macos-media-player
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --mandir=#{man}
      --docdir=#{doc}
      --lua=luajit
    ]

    python3 = "python3.11"
    system python3, "bootstrap.py"
    system python3, "waf", "configure", *args
    system python3, "waf", "install"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
  end
end
