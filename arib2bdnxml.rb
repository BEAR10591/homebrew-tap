class Arib2bdnxml < Formula
  desc "Convert ARIB STD-B24 Caption to BDN XML+PNG"
  homepage "https://github.com/BEAR10591/arib2bdnxml"
  url "https://github.com/BEAR10591/arib2bdnxml/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0ee1edf874484ad2a644c62e273af1e9ceec105973134ae39d459e9164589607"
  license "MIT"
  head "https://github.com/BEAR10591/arib2bdnxml.git", branch: "main"

  depends_on "meson" => :build
  depends_on "pkgconf" => :build
  depends_on "bear10591/tap/ffmpeg"
  depends_on "libpng"

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    assert_match(/arib2bdnxml/i, shell_output("#{bin}/arib2bdnxml --version 2>&1"))
  end
end

