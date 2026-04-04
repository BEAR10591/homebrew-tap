class Assettool < Formula
  desc "Convert Unreal Engine .uasset to JSON and JSON to .uasset"
  homepage "https://github.com/PedroMartinsMenezes/AssetTools"
  license "MIT"

  head "https://github.com/PedroMartinsMenezes/AssetTools.git", branch: "main"

  livecheck do
    url :head
    strategy :git
  end

  depends_on "dotnet"

  def install
    mkdir_p buildpath/"tmp"
    ENV["TMPDIR"] = (buildpath/"tmp").to_s

    system "dotnet", "publish", "AssetTool/AssetTool.csproj",
           "-c", "Release",
           "--no-self-contained",
           "-o", libexec
    rm libexec/"AssetTool.pdb"
    bin.install_symlink libexec/"AssetTool"
  end

  test do
    assert_match "Usage: AssetTool", shell_output("#{bin}/AssetTool")
  end
end
