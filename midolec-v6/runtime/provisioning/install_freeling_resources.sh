#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_ROOT="${RUNTIME_ROOT}/freeling/share/freeling"
SOURCE_URL="${MIDOLEC_FREELING_RESOURCES_URL:-}"
GITHUB_REPO="${MIDOLEC_RUNTIME_GITHUB_REPO:-gigabd-uc3m/midolec-dist}"
RELEASE_TAG="${MIDOLEC_RUNTIME_RELEASE_TAG:-v6-runtime-2026-05-07}"
RELEASE_URL="${MIDOLEC_RUNTIME_RELEASE_URL:-}"
RELEASE_ASSET="${MIDOLEC_FREELING_RESOURCES_ASSET:-midolec-v6-freeling-resources-es-2026-05-07.tar.gz}"
LOCAL_ARCHIVE=""
LOCAL_DIR=""
KEEP_TMP=0
VERIFY_CHECKSUM=1
RUN_CHECK=1

# shellcheck source=_github_release.sh
source "${SCRIPT_DIR}/_github_release.sh"

print_usage() {
  cat <<'EOF'
Usage:
  runtime/provisioning/install_freeling_resources.sh [options]

Options:
  --url URL             Download a FreeLing resources archive from URL.
  --release-url URL     Parse repo and tag from a GitHub Release URL.
  --github-repo REPO    Download from a private GitHub Release repo (owner/name).
  --release-tag TAG     GitHub Release tag to download from.
  --asset NAME          GitHub Release asset name for the resources archive.
  --archive PATH        Use a local archive instead of downloading.
  --from-dir PATH       Copy resources from a local directory.
  --skip-checksum       Do not verify SHA256SUMS when using GitHub Release download.
  --skip-check          Do not run check_freeling_runtime.sh --resources-only.
  --keep-tmp            Keep the temporary extraction directory for debugging.
  -h, --help            Show this help.

Environment:
  MIDOLEC_FREELING_RESOURCES_URL
  MIDOLEC_RUNTIME_RELEASE_URL
  MIDOLEC_RUNTIME_GITHUB_REPO
  MIDOLEC_RUNTIME_RELEASE_TAG
  MIDOLEC_FREELING_RESOURCES_ASSET

The source must provide the FreeLing common/ and es/ folders. Supported archive
formats: .tar, .tar.gz, .tgz, .tar.xz, .zip. For private repos this script uses
GitHub CLI, so run "gh auth login" first.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --url)
      SOURCE_URL="${2:?Missing value for --url}"
      shift 2
      ;;
    --release-url)
      RELEASE_URL="${2:?Missing value for --release-url}"
      shift 2
      ;;
    --github-repo)
      GITHUB_REPO="${2:?Missing value for --github-repo}"
      shift 2
      ;;
    --release-tag)
      RELEASE_TAG="${2:?Missing value for --release-tag}"
      shift 2
      ;;
    --asset)
      RELEASE_ASSET="${2:?Missing value for --asset}"
      shift 2
      ;;
    --archive)
      LOCAL_ARCHIVE="${2:?Missing value for --archive}"
      shift 2
      ;;
    --from-dir)
      LOCAL_DIR="${2:?Missing value for --from-dir}"
      shift 2
      ;;
    --keep-tmp)
      KEEP_TMP=1
      shift
      ;;
    --skip-check)
      RUN_CHECK=0
      shift
      ;;
    --skip-checksum)
      VERIFY_CHECKSUM=0
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage >&2
      exit 1
      ;;
  esac
done

apply_release_url "$RELEASE_URL"

run_runtime_check() {
  if [[ "$RUN_CHECK" -eq 0 ]]; then
    return 0
  fi

  if [[ -f "${SCRIPT_DIR}/check_freeling_runtime.sh" ]]; then
    bash "${SCRIPT_DIR}/check_freeling_runtime.sh" --resources-only
  else
    echo "Runtime check script not found; skipping."
  fi
}

download_file() {
  local url="$1"
  local out="$2"
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to download resources." >&2
    exit 1
  fi
  curl -L --fail --show-error --output "$out" "$url"
}

extract_archive() {
  local archive="$1"
  local out_dir="$2"
  case "$archive" in
    *.tar.gz|*.tgz)
      tar -xzf "$archive" -C "$out_dir"
      ;;
    *.tar.xz)
      tar -xJf "$archive" -C "$out_dir"
      ;;
    *.tar)
      tar -xf "$archive" -C "$out_dir"
      ;;
    *.zip)
      if ! command -v unzip >/dev/null 2>&1; then
        echo "unzip is required to extract .zip archives." >&2
        exit 1
      fi
      unzip -q "$archive" -d "$out_dir"
      ;;
    *)
      echo "Unsupported archive format: $archive" >&2
      exit 1
      ;;
  esac
}

find_resource_dir() {
  local root="$1"
  local name="$2"
  local candidate

  for candidate in \
    "$root/$name" \
    "$root/freeling/$name" \
    "$root/share/freeling/$name"; do
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  find "$root" -type d -path "*/${name}" | head -n 1
}

install_from_dir() {
  local source_dir="$1"
  local common_dir
  local es_dir

  common_dir="$(find_resource_dir "$source_dir" common)"
  es_dir="$(find_resource_dir "$source_dir" es)"

  if [[ -z "$common_dir" || -z "$es_dir" ]]; then
    echo "Could not find both common/ and es/ resource folders under: $source_dir" >&2
    exit 1
  fi

  mkdir -p "$TARGET_ROOT"
  rm -rf "${TARGET_ROOT}/common" "${TARGET_ROOT}/es"
  cp -a "$common_dir" "${TARGET_ROOT}/common"
  cp -a "$es_dir" "${TARGET_ROOT}/es"

  echo "Installed FreeLing resources:"
  echo "  ${TARGET_ROOT}/common"
  echo "  ${TARGET_ROOT}/es"
}

main() {
  local tmp_dir=""
  local archive_path="$LOCAL_ARCHIVE"
  local archive_name

  if [[ -n "$LOCAL_DIR" ]]; then
    install_from_dir "$LOCAL_DIR"
    run_runtime_check
    exit 0
  fi

  if [[ -z "$archive_path" ]]; then
    tmp_dir="$(mktemp -d)"
    if [[ -n "$SOURCE_URL" ]]; then
      archive_name="$(archive_name_from_url "$SOURCE_URL" "freeling_resources.tar.gz")"
      archive_path="${tmp_dir}/${archive_name}"
      download_file "$SOURCE_URL" "$archive_path"
    else
      download_release_asset "$GITHUB_REPO" "$RELEASE_TAG" "$RELEASE_ASSET" "$tmp_dir"
      archive_path="${tmp_dir}/${RELEASE_ASSET}"
      if [[ "$VERIFY_CHECKSUM" -eq 1 ]]; then
        download_release_checksums "$GITHUB_REPO" "$RELEASE_TAG" "$tmp_dir"
        verify_release_asset_checksum "$tmp_dir" "$RELEASE_ASSET"
      fi
    fi
  else
    tmp_dir="$(mktemp -d)"
  fi

  extract_archive "$archive_path" "$tmp_dir"
  install_from_dir "$tmp_dir"

  if [[ "$KEEP_TMP" -eq 1 ]]; then
    echo "Temporary extraction directory kept at: $tmp_dir"
  else
    rm -rf "$tmp_dir"
  fi

  run_runtime_check
}

main "$@"
