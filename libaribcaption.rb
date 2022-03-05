class Libaribcaption < Formula
    desc "Portable ARIB STD-B24 Caption Decoder/Renderer"
    homepage "https://github.com/xqq/libaribcaption"
    head "https://github.com/xqq/libaribcaption.git", branch: "master"

    depends_on "cmake" => :build

    def install
        system "cmake", "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_INSTALL_PREFIX=#{prefix}"
        system "cmake", "--build", "-j8"
        system "cmake", "--install"
    end
  end
