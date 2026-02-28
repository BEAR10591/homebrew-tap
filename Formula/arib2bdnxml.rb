class Arib2bdnxml < Formula
  desc "Convert ARIB STD-B24 Caption to BDN XML+PNG"
  homepage "https://github.com/BEAR10591/arib2bdnxml"
  url "https://github.com/BEAR10591/arib2bdnxml/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "31fd68686f1d3ba6b0dad19a58d3672abb96b035f73591a97775832c2e30dcb7"
  license "MIT"
  head "https://github.com/BEAR10591/arib2bdnxml.git", branch: "main"

  livecheck do
    url "https://github.com/BEAR10591/arib2bdnxml/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on "rust" => :build
  depends_on "pkg-config" => :build
  depends_on "bear10591/tap/ffmpeg-ursus"

  def install
    ENV["FFMPEG_DIR"] = Formula["ffmpeg-ursus"].opt_prefix
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match(/arib2bdnxml/i, shell_output("#{bin}/arib2bdnxml --version 2>&1"))
  end
end
