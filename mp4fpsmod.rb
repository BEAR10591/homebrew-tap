class Mp4fpsmod < Formula
  desc "mp4 time code editor"
  homepage "https://sites.google.com/site/qaacpage/"
  license "public_domain"

  head "https://github.com/nu774/mp4fpsmod.git", branch: "master"

  stable do
    url "https://github.com/nu774/mp4fpsmod/archive/refs/tags/v0.28.tar.gz"
    sha256 "334fbaa523a7ca16311d7edb25b244b016ec4af6cf438860b687feadaa23b2f8"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool"  => :build

  def install
    system "./bootstrap.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "strip", "mp4fpsmod"
    system "make", "install"
  end

  test do
    # ヘルプが出るか確認（戻り値は 1 でもよいので 2>&1 で吸う）
    assert_match "mp4 time code editor",
                 shell_output("#{bin}/mp4fpsmod 2>&1", 1)
  end
end
