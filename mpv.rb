class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.36.0.tar.gz"
  sha256 "29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  # sd_lavc: support rendering bitmap subtitles with libaribcaption
  patch do
    url "https://raw.githubusercontent.com/BEAR10591/homebrew-tap/main/patch/mpv_libaribcaption_PR11648.patch"
    sha256 "f903867b3342abab28ceb11bd447aefd42ef3cefd1f6f0cd03c0f177436e854f"
  end

  # ao: add a new ao "avfoundation" to support spatial audio in macOS
  patch do
    url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/11955.patch"
    sha256 "bb3a4a5cd6e6803e856b6dd513f10f68ae18fdf427bc60ff62c1236e9b81adec"
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
  depends_on "molten-vk"
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
      -Dlibmpv=false
      -Dlua=luajit
      -Dlibarchive=enabled
      -Dlibplacebo=enabled
      -Duchardet=enabled
      -Davfoundation=enabled
      -Dvulkan=enabled
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

    if MacOS.version >= :big_sur
      bash_completion.install "etc/mpv.bash-completion" => "mpv"
      zsh_completion.install "etc/_mpv.zsh" => "_mpv"
    end

    # Build, Fix, and Codesign App Bundle
    system "python3.12", "TOOLS/osxbundle.py", "build/mpv", "--skip-deps"
    if MacOS.version < :mojave || !build.head?
      bindir = "build/mpv.app/Contents/MacOS/"
      rm_f bindir + "mpv-bundle"
      cp   bindir + "mpv", bindir + "mpv-bundle"
      system "codesign", "--deep", "-fs", "-", "build/mpv.app"
    end
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")

    # Make sure `pkg-config` can parse `mpv.pc` after the `inreplace`.
    system "pkg-config", "mpv"
  end
end
