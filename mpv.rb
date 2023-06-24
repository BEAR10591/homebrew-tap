class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.35.1.tar.gz"
  sha256 "41df981b7b84e33a2ef4478aaf81d6f4f5c8b9cd2c0d337ac142fc20b387d1a9"
  license :cannot_represent
  revision 2
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  stable do
    patch do
      url "https://raw.githubusercontent.com/BEAR10591/homebrew-tap/main/patch/mpv_libaribcaption.patch"
    end

    # Fix ytdl issue. Remove after next mpv release.
    patch do
      url "https://raw.githubusercontent.com/BEAR10591/homebrew-tap/main/patch/mpv_ytdl-hook.patch"
    end
  end

  head do
    patch do
      url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/11648.patch"
    end

    patch do
      url "https://github.com/mpv-player/mpv/compare/master...rcombs:mpv:avfoundation.patch"
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on xcode: :build
  depends_on "bear10591/tap/ffmpeg"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "libplacebo"
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
      -Dhtml-build=enabled
      -Djavascript=enabled
      -Dlibmpv=true
      -Dlua=luajit
      -Dlibarchive=enabled
      -Duchardet=enabled
      -Dvulkan=enabled
      -Dlibplacebo=enabled
      -Dlibplacebo-next=enabled
      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
      --mandir=#{man}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    if OS.mac?
      # `pkg-config --libs mpv` includes libarchive, but that package is
      # keg-only so it needs to look for the pkgconfig file in libarchive's opt
      # path.
      libarchive = Formula["libarchive"].opt_prefix
      inreplace lib/"pkgconfig/mpv.pc" do |s|
        s.gsub!(/^Requires\.private:(.*)\blibarchive\b(.*?)(,.*)?$/,
                "Requires.private:\\1#{libarchive}/lib/pkgconfig/libarchive.pc\\3")
      end
    end

    bash_completion.install "etc/mpv.bash-completion" => "mpv"
    zsh_completion.install "etc/_mpv.zsh" => "_mpv"

    inreplace "TOOLS/dylib-unhell.py", "libraries(lib, result)",
              "lib = lib.replace(\"@loader_path\", \"" + "#{HOMEBREW_PREFIX}/lib" + "\"); libraries(lib, result)"
    inreplace "TOOLS/dylib-unhell.py", "libraries(lib, result)",
              "lib = lib.replace(      \"@rpath\", \"" + "#{HOMEBREW_PREFIX}/lib" + "\"); libraries(lib, result)"
    system "python3.11", "TOOLS/osxbundle.py", "build/mpv"
    bindir = "build/mpv.app/Contents/MacOS/"
    rm   bindir + "mpv-bundle"
    mv   bindir + "mpv", bindir + "mpv-bundle"
    ln_s "mpv-bundle", bindir + "mpv"
    system "codesign", "--deep", "-fs", "-", "build/mpv.app"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")

    # Make sure `pkg-config` can parse `mpv.pc` after the `inreplace`.
    system "pkg-config", "mpv"
  end
end
