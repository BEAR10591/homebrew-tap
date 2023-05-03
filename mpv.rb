class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.35.1.tar.gz"
  sha256 "41df981b7b84e33a2ef4478aaf81d6f4f5c8b9cd2c0d337ac142fc20b387d1a9"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  stable do
    def patches
      [
        "https://github.com/mpv-player/mpv/commit/0da0acdae8e729eecfb2498ac11cb86a7fe3360d.patch",
        "https://github.com/mpv-player/mpv/pull/11648.patch"
      ]
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => :build
  depends_on xcode: :build
  depends_on "bear10591/tap/ffmpeg"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "vapoursynth"
  depends_on "yt-dlp"

  on_linux do
    depends_on "alsa-lib"
  end

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # force meson find ninja from homebrew
    ENV["NINJA"] = Formula["ninja"].opt_bin/"ninja"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"

    args = %W[
      -Ddvbin=enabled
      -Dhtml-build=enabled
      -Djavascript=enabled
      -Dlibmpv=true
      -Dlua=luajit
      -Dlibarchive=enabled
      -Duchardet=enabled
      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
      --mandir=#{man}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    inreplace "TOOLS/dylib-unhell.py", "libraries(lib, result)", "lib = lib.replace(\"@loader_path\", \"" + "#{HOMEBREW_PREFIX}/lib" + "\"); libraries(lib, result)"
    system "python3.11", "TOOLS/osxbundle.py", "build/mpv"
    bindir = "build/mpv.app/Contents/MacOS/"
    rm   bindir + "mpv-bundle"
    mv   bindir + "mpv",        bindir + "mpv-bundle"
    ln_s bindir + "mpv-bundle", bindir + "mpv"
    system "codesign", "--deep", "-fs", "-", "build/mpv.app"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")
  end
end
