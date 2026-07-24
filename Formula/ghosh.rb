require "download_strategy"

# Downloads release assets from the PRIVATE go2starr/dream-rs repo. Requires
# HOMEBREW_GITHUB_API_TOKEN with read (Contents) access to the repo. It resolves
# the asset id through the GitHub API (authenticated), then fetches the asset
# blob. Modern curl drops the Authorization header on GitHub's cross-host
# redirect to the signed CDN URL, so the token never leaks past api.github.com.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  require "utils/github"

  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
  end

  def parse_url_pattern
    url_pattern = %r{https://github.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    raise CurlDownloadStrategyError, "Invalid GitHub Release URL: #{@url}" unless @url =~ url_pattern

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    "https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    if github_token.to_s.empty?
      raise CurlDownloadStrategyError,
            "HOMEBREW_GITHUB_API_TOKEN is required to install ghosh from the private repo."
    end

    curl_download download_url,
                  "--header", "Accept: application/octet-stream",
                  "--header", "Authorization: token #{github_token}",
                  to: temporary_path, timeout: timeout
  end

  def github_token
    ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
  end

  def asset_id
    @asset_id ||= begin
      release = GitHub::API.open_rest(
        "https://api.github.com/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}",
      )
      asset = release["assets"].find { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Asset #{@filename} not found in release #{@tag}." if asset.nil?

      asset["id"]
    end
  end
end

class Ghosh < Formula
  desc "Mosh-style remote shell over QUIC (ghostty + mosh)"
  homepage "https://github.com/go2starr/dream-rs"
  version "0.1.0"
  license any_of: ["MIT", "Apache-2.0"]

  # Prebuilt binaries from the private `ghosh-v<version>` GitHub Release on
  # go2starr/dream-rs. The three platforms match the release matrix in
  # .github/workflows/ghosh-release.yml and the vendored libghostty-vt bundles.
  # Run `homebrew/update-formula.sh ghosh-v<version>` to refresh version + sha256.
  # Only aarch64 macOS is shipped today (both target machines are Apple
  # Silicon). To add Linux, re-enable the matrix rows in ghosh-release.yml, then
  # add on_linux `on_intel`/`on_arm` url+sha256 blocks here and re-run
  # update-formula.sh — it fills whatever platform blocks exist.
  on_macos do
    on_arm do
      url "https://github.com/go2starr/dream-rs/releases/download/ghosh-v0.1.0/ghosh-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "3ef399be9ea32fde3a5cb707327177f849f31d0a82d4c759cb3d79d6d55cf0c0"
    end
  end

  def install
    bin.install "ghosh", "ghosh-server"
  end

  test do
    # ghosh has no --help/--version; a bad flag is the deterministic offline
    # path (prints usage, exits 2). ghosh-server's modes all block or do real
    # work, so just assert it installed as a runnable binary.
    assert_match "usage: ghosh", shell_output("#{bin}/ghosh --nope 2>&1", 2)
    assert_predicate bin/"ghosh-server", :executable?
  end
end
