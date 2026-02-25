class Arib2bdnxml < Formula
  desc "Convert ARIB STD-B24 Caption to BDN XML+PNG"
  homepage "https://github.com/BEAR10591/arib2bdnxml"
  url "https://github.com/BEAR10591/arib2bdnxml/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "2f6d334289b66d7a8fe114f971b4eb7b23d643926bc1225892ad41bed59e2b49"
  license "MIT"
  head "https://github.com/BEAR10591/arib2bdnxml.git", branch: "main"

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
