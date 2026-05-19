#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Patch FreeLing RPATH/RUNPATH for Midolec V6
# ------------------------------------------------------------
# Usage:
#   bash runtime/provisioning/freeling/patch_freeling_rpath.sh
#   bash runtime/provisioning/freeling/patch_freeling_rpath.sh /path/to/midolec-root
#
# It supports both:
#   1) Source tree:
#      core/vendor/freeling/_pyfreeling.so
#      runtime/freeling/lib/
#
#   2) PyInstaller onedir distribution:
#      _internal/core/vendor/freeling/_pyfreeling.so
#      runtime/freeling/lib/
#
# The script makes _pyfreeling.so resolve FreeLing native libraries
# from runtime/freeling/lib without requiring LD_LIBRARY_PATH.

ROOT_DIR="${1:-$(pwd)}"
ROOT_DIR="$(cd "$ROOT_DIR" && pwd)"

if ! command -v patchelf >/dev/null 2>&1; then
  echo "ERROR: patchelf is not installed."
  echo "Install it with:"
  echo "  sudo apt update && sudo apt install -y patchelf"
  exit 1
fi

# Detect execution layout.
if [[ -f "$ROOT_DIR/_internal/core/vendor/freeling/_pyfreeling.so" ]]; then
  MODE="pyinstaller"
  PYFREELING_SO="$ROOT_DIR/_internal/core/vendor/freeling/_pyfreeling.so"
  PYFREELING_RPATH='$ORIGIN/../../../../runtime/freeling/lib'
elif [[ -f "$ROOT_DIR/core/vendor/freeling/_pyfreeling.so" ]]; then
  MODE="source"
  PYFREELING_SO="$ROOT_DIR/core/vendor/freeling/_pyfreeling.so"
  PYFREELING_RPATH='$ORIGIN/../../../runtime/freeling/lib'
else
  echo "ERROR: _pyfreeling.so not found."
  echo "Expected one of:"
  echo "  $ROOT_DIR/_internal/core/vendor/freeling/_pyfreeling.so"
  echo "  $ROOT_DIR/core/vendor/freeling/_pyfreeling.so"
  exit 1
fi

FREELING_LIB_DIR="$ROOT_DIR/runtime/freeling/lib"

echo "Detected mode: $MODE"
echo "Root directory: $ROOT_DIR"
echo "FreeLing binding: $PYFREELING_SO"
echo "FreeLing runtime lib dir: $FREELING_LIB_DIR"

# If this is a PyInstaller build, fail if native FreeLing libraries
# were accidentally bundled inside _internal. They should come from runtime/.
if [[ "$MODE" == "pyinstaller" ]]; then
  BAD_INTERNAL_LIBS="$(find "$ROOT_DIR/_internal" \
    \( -name "libfreeling.so*" \
       -o -name "libfoma.so*" \
       -o -name "libtreeler.so*" \
       -o -name "libdynet.so*" \
       -o -name "libcrfsuite.so*" \) \
    -print || true)"

  if [[ -n "$BAD_INTERNAL_LIBS" ]]; then
    echo "ERROR: FreeLing native libraries were found inside _internal:"
    echo "$BAD_INTERNAL_LIBS"
    echo
    echo "These libraries must not be bundled by PyInstaller if runtime/freeling/lib is used."
    echo "Fix the .spec file and rebuild."
    exit 1
  fi
fi

# Patch _pyfreeling.so so it can find runtime/freeling/lib relatively.
echo
echo "Patching _pyfreeling.so RPATH/RUNPATH..."
patchelf --set-rpath "$PYFREELING_RPATH" "$PYFREELING_SO"

echo "Current _pyfreeling.so RPATH/RUNPATH:"
patchelf --print-rpath "$PYFREELING_SO"

# Patch each native FreeLing library so transitive dependencies in the same
# directory can also be resolved without LD_LIBRARY_PATH.
#
# This matters because libfreeling.so may depend on libfoma.so, libtreeler.so,
# libdynet.so, libcrfsuite.so, etc. Setting $ORIGIN on each runtime library
# makes each library search its own directory for sibling dependencies.
if [[ -d "$FREELING_LIB_DIR" ]]; then
  echo
  echo "Patching native FreeLing libraries with RPATH/RUNPATH=\$ORIGIN..."

  find "$FREELING_LIB_DIR" -maxdepth 1 -type f -name "*.so*" | while read -r lib; do
    echo "  patching: $lib"
    patchelf --set-rpath '$ORIGIN' "$lib" || {
      echo "  warning: could not patch $lib"
    }
  done

  echo
  echo "Checking _pyfreeling.so dependencies without LD_LIBRARY_PATH..."
  env -u LD_LIBRARY_PATH ldd "$PYFREELING_SO" | grep -E "freeling|foma|treeler|dynet|crfsuite|boost|not found" || true
else
  echo
  echo "WARNING: $FREELING_LIB_DIR does not exist yet."
  echo "RPATH was patched in _pyfreeling.so, but runtime libraries cannot be checked."
fi

echo
echo "Done."
