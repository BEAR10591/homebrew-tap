class MpvIina < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.34.1.tar.gz"
  sha256 "32ded8c13b6398310fa27767378193dc1db6d78b006b70dbcbd3123a1445e746"
  head "https://github.com/mpv-player/mpv.git"

  patch :DATA

  keg_only "it is intended to only be used for building IINA. This formula is not recommended for daily use"

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on xcode: :build

  depends_on "ffmpeg"
  depends_on "jpeg"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "little-cms2"
  depends_on "luajit-openresty"
  depends_on "libbluray"
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "yt-dlp"
  uses_from_macos "libiconv"
  uses_from_macos "zlib"

  def install
    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "C"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"
    # luajit-openresty is key-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["luajit-openresty"].opt_lib/"pkgconfig"

    ENV["CFLAGS"] = "-O3 -flto"
    ENV["LDFLAGS"] = "-flto"

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

    system Formula["python@3.9"].opt_bin/"python3", "bootstrap.py"
    system Formula["python@3.9"].opt_bin/"python3", "waf", "configure", *args
    system Formula["python@3.9"].opt_bin/"python3", "waf", "install"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
  end
end
__END__
diff --git a/version.sh b/version.sh
index a8023ac..88bf078 100755
--- a/version.sh
+++ b/version.sh
@@ -34,7 +34,7 @@ fi
 # or from "git describe" output
 git_revision=$(cat snapshot_version 2> /dev/null)
 test "$git_revision" || test ! -e .git || git_revision="$(git describe \
-    --match "v[0-9]*" --always --tags --dirty | sed 's/^v//')"
+    --match "v[0-9]*" --always --tags | sed 's/^v//')"
 version="$git_revision"

 # other tarballs extract the version number from the VERSION file
diff --git a/waftools/detections/compiler_swift.py b/waftools/detections/compiler_swift.py
index be66df0..a0a15f6 100644
--- a/waftools/detections/compiler_swift.py
+++ b/waftools/detections/compiler_swift.py
@@ -36,7 +36,7 @@ def __add_swift_flags(ctx):
 def __add_static_swift_library_linking_flags(ctx, swift_library):
     ctx.env.append_value('LINKFLAGS', [
         '-L%s' % swift_library,
-        '-Xlinker', '-force_load_swift_libs', '-lc++',
+        '-lc++',
     ])


@@ -83,8 +83,8 @@ def __find_swift_library(ctx):
             'usr/lib/swift/macosx'
         ],
         'SWIFT_LIB_STATIC': [
-            'Toolchains/XcodeDefault.xctoolchain/usr/lib/swift_static/macosx',
-            'usr/lib/swift_static/macosx'
+            'Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx',
+            'usr/lib/swift/macosx'
         ]
     }
     dev_path = __run(['xcode-select', '-p'])[1:]
