class Mkvtoolnix < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://mkvtoolnix.download/"
 url "https://mkvtoolnix.download/sources/mkvtoolnix-67.0.0.tar.xz"
  mirror "https://fossies.org/linux/misc/mkvtoolnix-67.0.0.tar.xz"
  sha256 "db68be91ee8a0b688d924cc00d3bac9349306d54c29ce44a555728c1abb7d3ec"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://mkvtoolnix.download/sources/"
    regex(/href=.*?mkvtoolnix[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "docbook-xsl" => :build
  depends_on "pkg-config" => :build
  depends_on "cmark"
  depends_on "boost"
  depends_on "flac"
  depends_on "fmt"
  depends_on "gettext"
  depends_on "gmp"
  depends_on "libebml"
  depends_on "libmatroska"
  depends_on "libogg"
  depends_on "libvorbis"
  # https://mkvtoolnix.download/downloads.html#macosx
  depends_on macos: :catalina # C++17
  depends_on "nlohmann-json"
  depends_on "pugixml"
  depends_on "qt"
  depends_on "utf8cpp"

  uses_from_macos "libxslt" => :build
  uses_from_macos "ruby" => :build

  on_linux do
    depends_on "gcc" => :build
  end

  fails_with gcc: "5"

  def install
    ENV.cxx11

    features = %w[flac gmp libebml libmatroska libogg libvorbis]
    extra_includes = ""
    extra_libs = ""
    features.each do |feature|
      extra_includes << "#{Formula[feature].opt_include};"
      extra_libs << "#{Formula[feature].opt_lib};"
    end
    extra_includes << "#{Formula["utf8cpp"].opt_include}/utf8cpp;"
    extra_includes.chop!
    extra_libs.chop!

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-boost=#{Formula["boost"].opt_prefix}",
                          "--with-docbook-xsl-root=#{Formula["docbook-xsl"].opt_prefix}/docbook-xsl",
                          "--with-extra-includes=#{extra_includes}",
                          "--with-extra-libs=#{extra_libs}",
                          "--enable-gui"
    system "rake", "-j#{ENV.make_jobs}"
    system "rake", "install"
  end
end
