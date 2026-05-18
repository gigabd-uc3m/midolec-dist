#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_ROOT="$(cd "${RUNTIME_ROOT}/.." && pwd)"
FREELING_ROOT="${RUNTIME_ROOT}/freeling"
FREELING_LIB_DIR="${FREELING_ROOT}/lib"
FREELING_SHARE_DIR="${FREELING_ROOT}/share/freeling"
PYINSTALLER_BINDING_PATH="${APP_ROOT}/_internal/core/vendor/freeling/_pyfreeling.so"
SOURCE_BINDING_PATH="${APP_ROOT}/core/vendor/freeling/_pyfreeling.so"
LEGACY_BINDING_PATH="${APP_ROOT}/core/vendor/_pyfreeling.so"
LIBFREELING_PATH="${FREELING_LIB_DIR}/libfreeling.so"

SYSTEM_PACKAGES_HINT=(
  libboost-regex1.74.0
  libboost-program-options1.74.0
)

CUSTOM_LIBS=(
  libfreeling.so
  libfoma.so
  libtreeler.so
  libdynet.so
  libcrfsuite.so
)

MODEL_DIRS=(
  "${FREELING_SHARE_DIR}/common"
  "${FREELING_SHARE_DIR}/es"
)

CHECK_LIBS=1
CHECK_RESOURCES=1
CHECK_ABI=1

print_usage() {
  cat <<'EOF'
Usage:
  bash v6/runtime/provisioning/check_freeling_runtime.sh [options]

Options:
  --all             Validate libraries, binding dependencies and resources. Default.
  --libs-only       Validate native libraries and the Python binding only.
  --resources-only  Validate FreeLing common/ and es/ resource folders only.
  --skip-abi        Skip the optional symbol-level ABI compatibility check.
  -h, --help        Show this help.

This script only checks the local Midolec V6 FreeLing runtime layout. It does
not download files, does not patch RPATH, and does not install apt packages.
EOF
}

require_linux() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This script only supports Linux/WSL." >&2
    exit 1
  fi
}

resolve_binding_path() {
  if [[ -f "$PYINSTALLER_BINDING_PATH" ]]; then
    printf '%s\n' "$PYINSTALLER_BINDING_PATH"
    return 0
  fi
  if [[ -f "$SOURCE_BINDING_PATH" ]]; then
    printf '%s\n' "$SOURCE_BINDING_PATH"
    return 0
  fi
  if [[ -f "$LEGACY_BINDING_PATH" ]]; then
    printf '%s\n' "$LEGACY_BINDING_PATH"
    return 0
  fi
  return 1
}

check_custom_libs() {
  local missing=0
  local lib

  echo "Checking custom FreeLing shared libraries..."
  for lib in "${CUSTOM_LIBS[@]}"; do
    if [[ -f "${FREELING_LIB_DIR}/${lib}" ]]; then
      echo "OK: ${FREELING_LIB_DIR}/${lib}"
    else
      echo "MISSING: ${FREELING_LIB_DIR}/${lib}"
      missing=1
    fi
  done

  return "$missing"
}

check_model_dirs() {
  local missing=0
  local dir

  echo "Checking FreeLing resource directories..."
  for dir in "${MODEL_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
      echo "OK: $dir"
    else
      echo "MISSING: $dir"
      missing=1
    fi
  done

  return "$missing"
}

check_binding_dependencies() {
  local binding_path
  if ! binding_path="$(resolve_binding_path)"; then
    echo "Binding not found in the expected PyInstaller or source locations." >&2
    return 1
  fi

  if ! command -v ldd >/dev/null 2>&1; then
    echo "ldd is required to inspect _pyfreeling.so dependencies." >&2
    return 1
  fi

  # Run ldd without LD_LIBRARY_PATH so the check validates the same
  # RPATH/RUNPATH-based resolution used by normal Midolec execution.
  echo "Inspecting Python binding dependencies with ldd..."
  env -u LD_LIBRARY_PATH ldd "$binding_path"

  if env -u LD_LIBRARY_PATH ldd "$binding_path" | grep -Fq 'not found'; then
    echo ""
    echo "There are unresolved shared-library dependencies for _pyfreeling.so." >&2
    echo "If runtime/freeling/lib exists, run patch_freeling_rpath.sh and retry." >&2
    return 1
  fi

  return 0
}

check_freeling_abi_match() {
  local binding_path
  local missing=0
  local required_symbols_file
  local exported_symbols_file
  local symbol

  if [[ "$CHECK_ABI" -eq 0 ]]; then
    return 0
  fi

  if ! binding_path="$(resolve_binding_path)"; then
    echo "Binding not found in the expected PyInstaller or source locations." >&2
    return 1
  fi

  if [[ ! -f "$LIBFREELING_PATH" ]]; then
    echo "libfreeling.so not found: $LIBFREELING_PATH" >&2
    return 1
  fi

  if ! command -v nm >/dev/null 2>&1; then
    echo "Skipping ABI check: nm is not installed."
    return 0
  fi

  echo "Checking FreeLing ABI compatibility between _pyfreeling.so and libfreeling.so..."
  required_symbols_file="$(mktemp)"
  exported_symbols_file="$(mktemp)"

  nm -D "$binding_path" 2>/dev/null | awk '$1 == "U" && $2 ~ /^_ZN8freeling/ {print $2}' | sort -u > "$required_symbols_file"
  nm -D "$LIBFREELING_PATH" 2>/dev/null | awk 'NF >= 3 {print $3}' | sort -u > "$exported_symbols_file"

  if [[ ! -s "$required_symbols_file" ]]; then
    echo "No FreeLing C++ symbols were found in the binding dependency table."
    rm -f "$required_symbols_file" "$exported_symbols_file"
    return 0
  fi

  while IFS= read -r symbol; do
    [[ -z "$symbol" ]] && continue
    if ! grep -Fxq "$symbol" "$exported_symbols_file"; then
      echo "ABI MISMATCH: ${LIBFREELING_PATH} does not export required symbol:"
      if command -v c++filt >/dev/null 2>&1; then
        echo "  $(printf '%s\n' "$symbol" | c++filt)"
      else
        echo "  $symbol"
      fi
      missing=1
    fi
  done < "$required_symbols_file"

  rm -f "$required_symbols_file" "$exported_symbols_file"

  if [[ "$missing" -ne 0 ]]; then
    echo ""
    echo "_pyfreeling.so and ${LIBFREELING_PATH} were built from incompatible FreeLing APIs." >&2
    echo "Use the runtime libraries published for this Midolec V6 build." >&2
    return 1
  fi

  echo "OK: FreeLing binding and libfreeling.so expose compatible symbols."
  return 0
}

print_manual_help() {
  cat <<EOF

How to fix missing FreeLing runtime files:

  v6/runtime/provisioning/install_freeling_libs.sh
  v6/runtime/provisioning/install_freeling_resources.sh

If the runtime files are present but Midolec still reports missing
RPATH/RUNPATH resolution, patch the binding and the native libraries with:

  bash v6/runtime/provisioning/patch_freeling_rpath.sh /path/to/midolec-root

If ldd reports missing system libraries, install the required OS packages. The
known Ubuntu/WSL packages used by this runtime are:

  ${SYSTEM_PACKAGES_HINT[*]}
EOF
}

parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --all)
        CHECK_LIBS=1
        CHECK_RESOURCES=1
        CHECK_ABI=1
        shift
        ;;
      --libs-only)
        CHECK_LIBS=1
        CHECK_RESOURCES=0
        shift
        ;;
      --resources-only)
        CHECK_LIBS=0
        CHECK_RESOURCES=1
        CHECK_ABI=0
        shift
        ;;
      --skip-abi)
        CHECK_ABI=0
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
}

main() {
  local libs_ok=0
  local models_ok=0
  local binding_ok=0
  local abi_ok=0

  parse_args "$@"
  require_linux

  if [[ "$CHECK_LIBS" -eq 1 ]]; then
    check_custom_libs || libs_ok=$?
    check_binding_dependencies || binding_ok=$?
    check_freeling_abi_match || abi_ok=$?
  fi

  if [[ "$CHECK_RESOURCES" -eq 1 ]]; then
    check_model_dirs || models_ok=$?
  fi

  if [[ "$libs_ok" -ne 0 || "$models_ok" -ne 0 || "$binding_ok" -ne 0 || "$abi_ok" -ne 0 ]]; then
    print_manual_help
    exit 1
  fi

  echo ""
  echo "FreeLing runtime dependencies look ready for the selected check scope."
}

main "$@"
