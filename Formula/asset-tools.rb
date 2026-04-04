class AssetTools < Formula
  desc "Convert Unreal Engine .uasset to JSON and JSON to .uasset"
  homepage "https://github.com/PedroMartinsMenezes/AssetTools"
  license "MIT"

  head "https://github.com/PedroMartinsMenezes/AssetTools.git", branch: "main"

  livecheck do
    url :head
    strategy :git
  end

  depends_on "dotnet" => :build

  def install
    # Isolate NuGet temp locks from /private/tmp/NuGetScratch (avoids permission errors during brew install).
    mkdir_p buildpath/"tmp"
    ENV["TMPDIR"] = (buildpath/"tmp").to_s
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SKIP_FIRST_TIME_EXPERIENCE"] = "1"
    ENV["MSBUILDDISABLENODEREUSE"] = "1"

    rid = if OS.mac?
      Hardware::CPU.arm? ? "osx-arm64" : "osx-x64"
    else
      Hardware::CPU.arm? ? "linux-arm64" : "linux-x64"
    end

    system "dotnet", "publish", "AssetTool/AssetTool.csproj",
           "-c", "Release",
           "-r", rid,
           "--self-contained", "true",
           "-o", libexec
    rm libexec/"AssetTool.pdb"
    bin.install_symlink libexec/"AssetTool"
  end

  def caveats
    <<~EOS
      If install fails because `dotnet` cannot be symlinked into Homebrew, either remove the
      existing `dotnet` binary under #{HOMEBREW_PREFIX}/bin, or run:
        brew link --overwrite dotnet
    EOS
  end

  test do
    assert_match "Usage: AssetTool", shell_output("#{bin}/AssetTool")
  end
end
