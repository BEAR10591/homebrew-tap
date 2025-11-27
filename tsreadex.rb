class Tsreadex < Formula
  desc "MPEG-TS stream selector and stabilizer"
  homepage "https://github.com/xtne6f/tsreadex"
  license "MIT"

  head "https://github.com/xtne6f/tsreadex.git", branch: "master"

  stable do
    url "https://github.com/xtne6f/tsreadex/archive/refs/tags/master-240517.tar.gz"
    sha256 "1ec21917aa9c1f363d50469d54cef2c121c5086f1bb4eb27efa5297fe1139c44"
  end

  def install
    system "make"
    bin.install "tsreadex"
  end

  test do
    # 引数なしで実行すると usage が出るはずなので、
    # 出力に "tsreadex" が含まれているかだけ軽く確認
    assert_match "tsreadex", shell_output("#{bin}/tsreadex 2>&1", 1)
  end
end
