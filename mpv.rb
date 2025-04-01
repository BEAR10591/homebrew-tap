class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.40.0.tar.gz"
  sha256 "10a0f4654f62140a6dd4d380dcf0bbdbdcf6e697556863dc499c296182f081a3"
  license :cannot_represent
  revision 1
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  patch do # Info.plist: change "LSApplicationCategoryType"
    url "https://raw.githubusercontent.com/BEAR10591/homebrew-tap/refs/heads/main/patch/mpv-app-category.patch"
    sha256 "5b8907575b0f377ef5e621530bc27f56b70e1ba8460f800dc22e349acc788605"
  end

  stable do
    patch do # console.lua: use double quotes #16106
      url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/16106.patch"
      sha256 "f1b6d032a2cbe40dc2b49f844cf58294d7b010c5f0c53ca3c68aa04b2f84dd66"
    end

    patch do # console.lua: replace font script-opt with monospace_font #16150
      url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/16150.patch"
      sha256 "c04941496f8aa4a8db418d4482c7437e8d38cb519804b24ea99457d3454db945"
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on xcode: :build
  depends_on "bear10591/tap/ffmpeg"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libdvdnav"
  depends_on "libplacebo"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "mujs"
  depends_on "rubberband"
  depends_on "uchardet"
  depends_on "vapoursynth"
  depends_on "vulkan-loader"
  depends_on "yt-dlp"
  depends_on "zimg"

  uses_from_macos "zlib"

  on_macos do
    depends_on "molten-vk"
  end

  on_ventura :or_older do
    depends_on "lld" => :build
  end

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # force meson find ninja from homebrew
    ENV["NINJA"] = which("ninja")

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig" if OS.mac?

    # Work around https://github.com/mpv-player/mpv/issues/15591
    # This bug happens running classic ld, which is the default
    # prior to Xcode 15 and we enable it in the superenv prior to
    # Xcode 15.3 when using -dead_strip_dylibs (default for meson).
    if OS.mac? && MacOS.version <= :ventura
      ENV.append "LDFLAGS", "-fuse-ld=lld"
      ENV.O1 # -Os is not supported for lld and we don't have ENV.O2
    end

    args = %W[
      -Dbuild-date=false
      -Dhtml-build=enabled
      -Djavascript=enabled
      -Dlibmpv=true
      -Dlua=luajit
      -Ddvdnav=enabled
      -Dlibarchive=enabled
      -Duchardet=enabled
      -Dvulkan=enabled
      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
      --mandir=#{man}
    ]
    if OS.linux?
      args += %w[
        -Degl=enabled
        -Dwayland=enabled
        -Dx11=enabled
      ]
    end

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

    # Build App Bundle
    system "meson", "compile", "-C", "build", "macos-bundle"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", "--vo=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")

    # Make sure `pkgconf` can parse `mpv.pc` after the `inreplace`.
    system "pkgconf", "--print-errors", "mpv"
  end
end
