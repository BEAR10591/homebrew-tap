class FfmpegUrsus < Formula
  desc "FFmpeg with full codec set (gyan.dev full equivalent) and FDK-AAC"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-8.0.1.tar.xz"
  sha256 "05ee0b03119b45c0bdb4df654b96802e909e0a752f72e4fe3794f487229e5a41"
  # GPL-2.0-or-later; use of fdk-aac adds non-free code (see caveats)
  license "GPL-2.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  livecheck do
    formula "ffmpeg"
  end

  keg_only :versioned_formula

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on "aribb24"
  depends_on "dav1d"
  depends_on "fdk-aac"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "gnutls"
  depends_on "harfbuzz"
  depends_on "jpeg-xl"
  depends_on "lame"
  depends_on "libaribcaption"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libbs2b"
  depends_on "libcaca"
  depends_on "libdvdnav"
  depends_on "libdvdread"
  depends_on "libplacebo"
  depends_on "librist"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvidstab"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "llama.cpp"
  depends_on "libgsm"
  depends_on "librsvg"
  depends_on "libmodplug"
  depends_on "libopenmpt"
  depends_on "opencore-amr"
  depends_on "openjpeg"
  depends_on "opus"
  depends_on "rav1e"
  depends_on "rubberband"
  depends_on "sdl2"
  depends_on "snappy"
  depends_on "speex"
  depends_on "srt"
  depends_on "svt-av1"
  depends_on "tesseract"
  depends_on "theora"
  depends_on "two-lame"
  depends_on "webp"
  depends_on "whisper-cpp"
  depends_on "x264"
  depends_on "x265"
  depends_on "xvid"
  depends_on "xz"
  depends_on "zeromq"
  depends_on "zimg"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_macos do
    depends_on "libarchive"
    depends_on "libogg"
    depends_on "libsamplerate"
    depends_on "openal-soft"
  end

  on_linux do
    depends_on "alsa-lib"
    depends_on "libdrm"
    depends_on "libxext"
    depends_on "libxv"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  fails_with :gcc, "5"

  # Fix for QtWebEngine, do not remove
  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=270209
  patch do
    url "https://gitlab.archlinux.org/archlinux/packaging/packages/ffmpeg/-/raw/5670ccd86d3b816f49ebc18cab878125eca2f81f/add-av_stream_get_first_dts-for-chromium.patch"
    sha256 "57e26caced5a1382cb639235f9555fc50e45e7bf8333f7c9ae3d49b3241d3f77"
  end

  # Add svt-av1 4.x support
  patch do
    url "https://git.ffmpeg.org/gitweb/ffmpeg.git/patch/a5d4c398b411a00ac09d8fe3b66117222323844c"
    sha256 "1dbbc1a4cf9834b3902236abc27fefe982da03a14bcaa89fb90c7c8bd10a1664"
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.ld64_version.between?("1015.7", "1022.1")

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-gpl
      --enable-nonfree
      --enable-ffplay
      --enable-gnutls
      --enable-libaom
      --enable-libaribb24
      --enable-libaribcaption
      --enable-libass
      --enable-libbluray
      --enable-libbs2b
      --enable-libcaca
      --enable-libdav1d
      --enable-libdvdnav
      --enable-libdvdread
      --enable-libfdk-aac
      --enable-libfontconfig
      --enable-libfreetype
      --enable-frei0r
      --enable-libgsm
      --enable-libharfbuzz
      --enable-libjxl
      --enable-libmp3lame
      --enable-libmodplug
      --enable-libopenmpt
      --enable-libopus
      --enable-libplacebo
      --enable-librav1e
      --enable-librist
      --enable-librubberband
      --enable-librsvg
      --enable-libsnappy
      --enable-libsrt
      --enable-libssh
      --enable-libsvtav1
      --enable-libtesseract
      --enable-libtheora
      --enable-libtwolame
      --enable-libvidstab
      --enable-libvmaf
      --enable-libvorbis
      --enable-libvpx
      --enable-libwebp
      --enable-libx264
      --enable-libx265
      --enable-libxml2
      --enable-libxvid
      --enable-lzma
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-libopenjpeg
      --enable-libspeex
      --enable-libsoxr
      --enable-libzmq
      --enable-libzimg
      --enable-whisper
      --enable-demuxer=dash
      --disable-htmlpages
      --disable-libjack
      --disable-indev=jack
    ]

    args << "--enable-neon" if Hardware::CPU.arm?
    if OS.mac?
      args += %w[
        --enable-videotoolbox
        --enable-audiotoolbox
        --enable-opencl
        --enable-openal
      ]
    end

    ENV.prepend_path "PKG_CONFIG_PATH", Formula["whisper-cpp"].opt_lib/"pkgconfig"

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  def caveats
    <<~EOS
      ffmpeg-ursus is based on Homebrew's ffmpeg-full with gyan.dev full-style
      libraries and FDK-AAC. See https://www.gyan.dev/ffmpeg/builds/

      It is keg_only (versioned formula), so it does not override system/core ffmpeg.
      Use: brew link ffmpeg-ursus  (or add #{opt_bin} to PATH) to use these binaries.

      This build includes the non-free FDK-AAC encoder (--enable-nonfree).
      FDK-AAC is non-free; take care when redistributing the built binary.
      #{tesseract_caveats}
    EOS
  end

  def tesseract_caveats
    <<~EOS

      The default `tesseract` dependency includes limited language support.
      To add all supported languages, install the `tesseract-lang` formula.
    EOS
  end

  test do
    # Create a 5 second test MP4
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=5", mp4out
    assert_match(/Duration: 00:00:05\.00,.*Video: h264/m, shell_output("#{bin}/ffprobe -hide_banner #{mp4out} 2>&1"))

    # Re-encode it in HEVC/Matroska
    mkvout = testpath/"video.mkv"
    system bin/"ffmpeg", "-i", mp4out, "-c:v", "hevc", mkvout
    assert_match(/Duration: 00:00:05\.00,.*Video: hevc/m, shell_output("#{bin}/ffprobe -hide_banner #{mkvout} 2>&1"))
  end
end
