class Repak < Formula
  desc "Utility for building/extracting/inspecting Unreal Engine .pak files"
  homepage "https://github.com/trumank/repak"
  license any_of: ["Apache-2.0", "MIT"]

  head "https://github.com/trumank/repak.git", branch: "master"

  stable do
    url "https://github.com/trumank/repak/archive/refs/tags/v0.2.3.tar.gz"
    sha256 "78d2aa522c323dc7b1a06ddde9172e8f30730144e5637f5bce9e07b3f8bb93fe"
  end

  livecheck do
    url "https://github.com/trumank/repak/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "repak_cli")
  end

  test do
    assert_match "Usage: repak", shell_output("#{bin}/repak --help")
  end
end

