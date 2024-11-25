class MpvIina < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/refs/tags/v0.39.0.tar.gz"
  sha256 "2ca92437affb62c2b559b4419ea4785c70d023590500e8a52e95ea3ab4554683"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  keg_only <<EOS
it is intended to only be used for building IINA. This formula is not recommended for daily use
EOS

  stable do
    patch do # mp_image: copy params before dovi mapping for mp_image_copy_attributes
      url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/14961.patch"
      # sha256 "8dcd912c70030d46269eda8cab05d594a220183d324ef0c41a22b4864d568a36"
    end
  end

  stable do
    patch do # video/mp_image: fix original param copy implementation
      url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/15210.patch"
      # sha256 "6d4da39a9983fc3ce5d354a8a7645c415c5889def810e4b6fc4a2c30e1db5bd6"
    end
  end

  stable do
    patch do # Use only tag name in mpv version
      url "https://github.com/iina/mpv/commit/0e2b759fcf01eb4b57960a17d7c6d9ff888e47cc.patch"
      # sha256 "ce3d98fd83b742812922777b5c6fed782a8e324d2ab99318cdc684cb9c166bf7"
    end
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on xcode: :build
  depends_on "bear10591/tap/ffmpeg-iina"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libplacebo"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "rubberband"
  depends_on "vulkan-loader"
  depends_on "zimg"
  # depends_on "molten-vk"

  uses_from_macos "zlib"

  depends_on "mujs"
  depends_on "uchardet"
  # depends_on "vapoursynth"
  depends_on "yt-dlp"

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # force meson find ninja from homebrew
    ENV["NINJA"] = which("ninja")

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"

    args = %W[
      -Dhtml-build=disabled
      -Djavascript=enabled
      -Dlibmpv=true
      -Dlua=luajit
      -Dlibarchive=enabled
      -Duchardet=enabled

      -Dlibbluray=enabled
      -Dcplayer=false

      -Dmanpage-build=disabled

      -Dmacos-touchbar=disabled
      -Dmacos-media-player=disabled
      -Dmacos-cocoa-cb=disabled

      --sysconfdir=#{pkgetc}
      --datadir=#{pkgshare}
    ]

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    # `pkg-config --libs mpv` includes libarchive, but that package is
    # keg-only so it needs to look for the pkgconfig file in libarchive's opt
    # path.
    libarchive = Formula["libarchive"].opt_prefix
    inreplace lib/"pkgconfig/mpv.pc" do |s|
     s.gsub!(/^Requires\.private:(.*)\blibarchive\b(.*?)(,.*)?$/,
             "Requires.private:\\1#{libarchive}/lib/pkgconfig/libarchive.pc\\3")
    end

  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
    # Make sure `pkg-config` can parse `mpv.pc` after the `inreplace`.
    system "pkg-config", "mpv"
  end
end
