#!/usr/bin/env bash

# Shared helpers for downloading Midolec runtime assets from private GitHub Releases.
# This file is sourced by the provisioning scripts and is not meant to be executed directly.

require_github_cli() {
  if ! command -v gh >/dev/null 2>&1; then
    cat >&2 <<'EOF'
GitHub CLI (gh) is required to download runtime assets from a private GitHub Release.
Install it and authenticate before running this script:

  gh auth login

Alternatively, pass --url, --archive or --from-dir to avoid GitHub Release download.
EOF
    exit 1
  fi
}

require_github_auth() {
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    cat >&2 <<'EOF'
GitHub CLI is installed, but it is not authenticated for github.com.
Run:

  gh auth login

The authenticated account must have access to the private Midolec repository.
EOF
    exit 1
  fi
}

download_release_asset() {
  local repo="$1"
  local release_tag="$2"
  local asset_name="$3"
  local out_dir="$4"

  require_github_cli
  require_github_auth

  mkdir -p "$out_dir"
  echo "Downloading GitHub Release asset:"
  echo "  repo:    $repo"
  echo "  tag:     $release_tag"
  echo "  asset:   $asset_name"
  gh release download "$release_tag" \
    --repo "$repo" \
    --pattern "$asset_name" \
    --dir "$out_dir"

  if [[ ! -f "${out_dir}/${asset_name}" ]]; then
    echo "Downloaded asset not found: ${out_dir}/${asset_name}" >&2
    exit 1
  fi
}

download_release_checksums() {
  local repo="$1"
  local release_tag="$2"
  local out_dir="$3"

  require_github_cli
  require_github_auth

  gh release download "$release_tag" \
    --repo "$repo" \
    --pattern "SHA256SUMS" \
    --dir "$out_dir"
}

verify_release_asset_checksum() {
  local out_dir="$1"
  local asset_name="$2"

  if [[ ! -f "${out_dir}/SHA256SUMS" ]]; then
    echo "SHA256SUMS not found; cannot verify ${asset_name}." >&2
    exit 1
  fi
  if ! command -v sha256sum >/dev/null 2>&1; then
    echo "sha256sum is required to verify downloaded runtime assets." >&2
    exit 1
  fi
  if ! grep -Fq "  ${asset_name}" "${out_dir}/SHA256SUMS"; then
    echo "SHA256SUMS does not contain an entry for ${asset_name}." >&2
    exit 1
  fi

  echo "Verifying checksum for ${asset_name}..."
  (cd "$out_dir" && sha256sum --ignore-missing -c SHA256SUMS)
}

archive_name_from_url() {
  local url="$1"
  local fallback="$2"
  local clean_url
  local name

  # Strip common query parameters before extracting the basename.
  clean_url="${url%%\?*}"
  name="$(basename "$clean_url")"

  if [[ -z "$name" || "$name" == "." || "$name" == "/" ]]; then
    name="$fallback"
  fi

  printf '%s\n' "$name"
}

apply_release_url() {
  local url="$1"
  local clean_url
  local path
  local repo_path
  local tag

  if [[ -z "$url" ]]; then
    return 0
  fi

  clean_url="${url%%\?*}"
  clean_url="${clean_url#https://github.com/}"
  clean_url="${clean_url#http://github.com/}"
  path="${clean_url%/}"

  if [[ "$path" != */releases/tag/* ]]; then
    echo "Invalid GitHub Release URL: $url" >&2
    echo "Expected format: https://github.com/OWNER/REPO/releases/tag/TAG" >&2
    exit 1
  fi

  repo_path="${path%%/releases/tag/*}"
  tag="${path##*/releases/tag/}"

  if [[ "$repo_path" != */* || -z "$tag" ]]; then
    echo "Could not parse GitHub Release URL: $url" >&2
    exit 1
  fi

  GITHUB_REPO="$repo_path"
  RELEASE_TAG="$tag"
}
