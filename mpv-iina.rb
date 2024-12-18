# Last check with upstream: 03fb1acf8d1c5417b8079eb68b2104a1296bc665
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/mpv.rb

class MpvIina < Formula
desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  head "https://github.com/iina/mpv.git", :branch => "iina-release/1.4.0"

  keg_only <<EOS
it is intended to only be used for building IINA. This formula is not recommended for daily use
EOS

  patch do # sub/sd_lavc: check decoder output type for dvb and arib
    url "https://patch-diff.githubusercontent.com/raw/mpv-player/mpv/pull/13752.patch"
    sha256 "6a62ecccf1862526d0c76abbb53916855eb2915871bff0bcf7d72ad11bda0b80"
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on xcode: :build

  depends_on "bear10591/tap/ffmpeg-iina"
  depends_on "jpeg-turbo"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "libplacebo"
  depends_on "little-cms2"
  depends_on "luajit"
  depends_on "libbluray"
  depends_on "libsamplerate"
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
    ENV["NINJA"] = Formula["ninja"].opt_bin/"ninja"

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
