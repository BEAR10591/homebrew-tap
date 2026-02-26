class Tsreadex < Formula
  desc "MPEG-TS stream selector and stabilizer"
  homepage "https://github.com/xtne6f/tsreadex"
  url "https://github.com/xtne6f/tsreadex/archive/refs/tags/master-240517.tar.gz"
  sha256 "1ec21917aa9c1f363d50469d54cef2c121c5086f1bb4eb27efa5297fe1139c44"
  license "MIT"
  head "https://github.com/xtne6f/tsreadex.git", branch: "master"

  livecheck do
    url "https://github.com/xtne6f/tsreadex/releases/latest"
    regex(%r{href=.*?/tag/(master-\d{6})["' >]}i)
  end

  def install
    system "make"
    bin.install "tsreadex"
  end

  test do
    # tsreadex returns non-zero when no args given; check it runs
    assert_match(/not enough arguments/, shell_output("#{bin}/tsreadex 2>&1", 1))
  end
end
