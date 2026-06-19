class Ghosh < Formula
  desc "Mosh-style remote shell over QUIC"
  homepage "https://github.com/go2starr/dream/tree/codex/quic-broker-jsonrpc/projects/ghosh"
  url "https://raw.githubusercontent.com/go2starr/homebrew-tap/main/resources/ghosh-0.1.0-macos-arm64.tar.gz"
  sha256 "2f29180f899e3604d2f7256286a6bf94ae8e10f0231f0fd1c75a4efc87ffaa92"
  version "0.1.0"

  def install
    odie "this prebuilt ghosh package is currently macOS arm64 only" unless OS.mac? && Hardware::CPU.arm?

    bin.install "bin/ghosh"
    bin.install "bin/ghosh-server"
    doc.install Dir["share/doc/ghosh/*"]
  end

  test do
    assert_predicate bin/"ghosh", :exist?
    assert_predicate bin/"ghosh-server", :exist?
  end
end
