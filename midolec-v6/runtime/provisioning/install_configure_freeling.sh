#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SKIP_LIBS=0
SKIP_RESOURCES=0
SKIP_PATCH=0
SKIP_CHECK=0
COMMON_INSTALL_ARGS=()

print_usage() {
  cat <<'EOF'
Usage:
  bash runtime/provisioning/install_configure_freeling.sh [options]

Options:
  --root PATH           Midolec root folder to patch/check. Defaults to the
                        application root that contains runtime/provisioning/.
  --release-url URL     GitHub Release URL used by both FreeLing installers.
  --github-repo REPO    GitHub Release repository used by both installers.
  --release-tag TAG     GitHub Release tag used by both installers.
  --skip-libs           Do not install FreeLing native libraries.
  --skip-resources      Do not install FreeLing common/ and es/ resources.
  --skip-patch          Do not patch RPATH/RUNPATH.
  --skip-check          Do not run the final FreeLing runtime check.
  -h, --help            Show this help.

Recommended first-time setup for public release assets:
  sudo apt update
  sudo apt install -y curl patchelf libboost-regex1.74.0 libboost-program-options1.74.0
  bash runtime/provisioning/install_configure_freeling.sh

This script runs the full FreeLing setup sequence:
  1) freeling/install_libs.sh
  2) freeling/install_resources.sh
  3) freeling/patch_freeling_rpath.sh
  4) freeling/check_runtime.sh

Supported environments:
  Ubuntu native, Linux servers, or WSL Ubuntu. MobaXterm/Cygwin/MSYS/Git Bash
  local terminals are not supported for this Linux runtime package.
EOF
}

require_supported_linux_runtime() {
  local kernel_name
  kernel_name="$(uname -s 2>/dev/null || true)"

  if [[ "$kernel_name" != "Linux" ]]; then
    cat >&2 <<EOF
ERROR: Midolec V6 FreeLing provisioning must run in a Linux runtime.

Supported environments:
  - Ubuntu or another compatible Linux distribution
  - WSL Ubuntu on Windows
  - SSH session connected to a Linux server

Unsupported local terminals for this package:
  - MobaXterm local shell
  - Cygwin/MSYS/Git Bash
  - Windows PowerShell or CMD without WSL

If you are on Windows, install/open WSL Ubuntu and run this script there.
GitHub CLI is only needed if the release assets are private or direct public
download is unavailable.
EOF
    exit 1
  fi
}

require_supported_linux_runtime

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --root)
      APP_ROOT="${2:?Missing value for --root}"
      shift 2
      ;;
    --release-url|--github-repo|--release-tag)
      COMMON_INSTALL_ARGS+=("$1" "${2:?Missing value for $1}")
      shift 2
      ;;
    --skip-libs)
      SKIP_LIBS=1
      shift
      ;;
    --skip-resources)
      SKIP_RESOURCES=1
      shift
      ;;
    --skip-patch)
      SKIP_PATCH=1
      shift
      ;;
    --skip-check)
      SKIP_CHECK=1
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

APP_ROOT="$(cd "$APP_ROOT" && pwd)"
TARGET_PROVISIONING_DIR="${APP_ROOT}/runtime/provisioning"
FREELING_SCRIPT_DIR="${TARGET_PROVISIONING_DIR}/freeling"

if [[ ! -d "$FREELING_SCRIPT_DIR" ]]; then
  echo "ERROR: FreeLing provisioning directory not found: $FREELING_SCRIPT_DIR" >&2
  exit 1
fi

echo "Midolec V6 FreeLing setup"
echo "Application root: $APP_ROOT"
echo "Provisioning dir: $TARGET_PROVISIONING_DIR"
echo

if [[ "$SKIP_LIBS" -eq 0 ]]; then
  echo "=== Installing FreeLing native libraries ==="
  bash "${FREELING_SCRIPT_DIR}/install_libs.sh" "${COMMON_INSTALL_ARGS[@]}" --skip-check
fi

if [[ "$SKIP_RESOURCES" -eq 0 ]]; then
  echo
  echo "=== Installing FreeLing linguistic resources ==="
  bash "${FREELING_SCRIPT_DIR}/install_resources.sh" "${COMMON_INSTALL_ARGS[@]}" --skip-check
fi

if [[ "$SKIP_PATCH" -eq 0 ]]; then
  echo
  echo "=== Configuring FreeLing RPATH/RUNPATH ==="
  bash "${FREELING_SCRIPT_DIR}/patch_freeling_rpath.sh" "$APP_ROOT"
fi

if [[ "$SKIP_CHECK" -eq 0 ]]; then
  echo
  echo "=== Checking FreeLing runtime ==="
  bash "${FREELING_SCRIPT_DIR}/check_runtime.sh"
fi

echo
echo "FreeLing runtime setup finished."
