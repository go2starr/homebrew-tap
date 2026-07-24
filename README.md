# homebrew-tap

Personal Homebrew tap for tools built from the (private) `go2starr/dream-rs`
repo.

## ghosh — mosh-style remote shell over QUIC

```sh
export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)   # read access to go2starr/dream-rs
brew tap go2starr/tap
brew install ghosh
```

The formula installs **prebuilt** `ghosh` + `ghosh-server` binaries (macOS
arm64) from private `dream-rs` GitHub Releases. The binaries are private, so a
`HOMEBREW_GITHUB_API_TOKEN` with read access is required; the token is used only
against `api.github.com` and is dropped on GitHub's redirect to the CDN.

Publishing is driven from `dream-rs` (`homebrew/` + `.github/workflows/ghosh-release.yml`).
