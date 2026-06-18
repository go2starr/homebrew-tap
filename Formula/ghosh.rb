class Ghosh < Formula
  desc "Mosh-style remote shell over QUIC"
  homepage "https://github.com/go2starr/dream/tree/codex/quic-broker-jsonrpc/projects/ghosh"
  url "https://raw.githubusercontent.com/go2starr/homebrew-tap/main/resources/ghosh-0.1.0-d6b65b8.tar.gz"
  sha256 "932e50ce37b73d57ae20e090811e518626679ebd8b277faa1cd7c8aef2102730"
  version "0.1.0"

  depends_on "llvm" => :build
  depends_on "rust" => :build

  resource "ghostty-vt" do
    url "https://raw.githubusercontent.com/go2starr/homebrew-tap/main/resources/ghostty-vt-macos-arm64-f9c52d0cd.tar.gz"
    sha256 "98c03bb2894e87220edbad0fc293cdd51447c2c28bd9687a835e959043e9d5e1"
  end

  def install
    odie "this prebuilt libghostty-vt package is currently macOS arm64 only" unless OS.mac? && Hardware::CPU.arm?

    resource("ghostty-vt").stage buildpath

    ENV["GHOSTTY_VT_DIR"] = buildpath/"ghostty-vt"
    ENV["LIBCLANG_PATH"] = Formula["llvm"].opt_lib/shared_library("libclang")
    ENV.prepend_path "PATH", Formula["llvm"].opt_bin

    system "cargo", "install", *std_cargo_args(path: "ghosh")
  end

  test do
    assert_predicate bin/"ghosh", :exist?
    assert_predicate bin/"ghosh-server", :exist?
  end
end
