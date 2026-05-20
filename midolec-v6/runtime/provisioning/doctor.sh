#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
RUNTIME_ROOT="${APP_ROOT}/runtime"
FREELING_SCRIPT_DIR="${SCRIPT_DIR}/freeling"
FREELING_LIB_DIR="${RUNTIME_ROOT}/freeling/lib"
FREELING_SHARE_DIR="${RUNTIME_ROOT}/freeling/share/freeling"
SPACY_MODEL_DIR="${RUNTIME_ROOT}/spacy/models/en_core_web_sm"
PYTHON_BIN="${MIDOLEC_PYTHON:-python3}"
BACKEND="all"
MISSING_COUNT=0
WARNING_COUNT=0

FREELING_APT_PACKAGES=(
  curl
  patchelf
  libboost-regex1.74.0
  libboost-program-options1.74.0
)

SPACY_APT_PACKAGES=(
  python3
  python3-pip
)

print_usage() {
  cat <<'EOF'
Usage:
  bash runtime/provisioning/doctor.sh [options]

Options:
  --backend NAME   Check one backend: freeling, spacy, or all. Default: all.
  --python PATH    Python executable used for spaCy checks. Default: python3.
  -h, --help       Show this help.

This script prints a user-friendly checklist. It does not install or modify
anything.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --backend)
      BACKEND="${2:?Missing value for --backend}"
      shift 2
      ;;
    --python)
      PYTHON_BIN="${2:?Missing value for --python}"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage >&2
      exit 2
      ;;
  esac
done

case "$BACKEND" in
  freeling|spacy|all) ;;
  *)
    echo "Unknown backend: $BACKEND" >&2
    echo "Expected: freeling, spacy, or all." >&2
    exit 2
    ;;
esac

mark_ok() {
  printf '  [OK]      %s\n' "$1"
}

mark_missing() {
  printf '  [MISSING] %s\n' "$1"
  MISSING_COUNT=$((MISSING_COUNT + 1))
}

mark_warn() {
  printf '  [WARN]    %s\n' "$1"
  WARNING_COUNT=$((WARNING_COUNT + 1))
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

apt_package_installed() {
  local package_name="$1"

  if command_exists dpkg-query; then
    dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -Fq "install ok installed"
    return $?
  fi

  case "$package_name" in
    curl|python3)
      command_exists "$package_name"
      ;;
    patchelf)
      command_exists patchelf
      ;;
    python3-pip)
      command_exists "$PYTHON_BIN" && "$PYTHON_BIN" -m pip --version >/dev/null 2>&1
      ;;
    libboost-regex1.74.0)
      ldconfig -p 2>/dev/null | grep -Fq "libboost_regex.so.1.74.0"
      ;;
    libboost-program-options1.74.0)
      ldconfig -p 2>/dev/null | grep -Fq "libboost_program_options.so.1.74.0"
      ;;
    *)
      return 1
      ;;
  esac
}

python_module_available() {
  local module_name="$1"

  command_exists "$PYTHON_BIN" &&
    "$PYTHON_BIN" -c "import ${module_name}" >/dev/null 2>&1
}

check_linux_environment() {
  echo "Environment"

  if [[ "$(uname -s 2>/dev/null || true)" == "Linux" ]]; then
    mark_ok "Linux runtime detected."
  else
    mark_missing "This package must run in Ubuntu, WSL Ubuntu, or a Linux server."
  fi

  if command_exists apt-get; then
    mark_ok "apt package manager is available."
  else
    mark_warn "apt-get was not found. Automatic OS package installation may not be available."
  fi

  if command_exists sudo; then
    mark_ok "sudo is available for installing missing OS packages."
  else
    mark_warn "sudo was not found. You may need an administrator to install OS packages."
  fi
}

check_freeling() {
  local lib
  local package_name

  echo
  echo "FreeLing backend checklist"

  for package_name in "${FREELING_APT_PACKAGES[@]}"; do
    if apt_package_installed "$package_name"; then
      mark_ok "System package available: $package_name"
    else
      mark_missing "System package missing: $package_name"
    fi
  done

  for lib in libfreeling.so libfoma.so libtreeler.so libdynet.so libcrfsuite.so; do
    if [[ -f "${FREELING_LIB_DIR}/${lib}" ]]; then
      mark_ok "FreeLing library found: runtime/freeling/lib/${lib}"
    else
      mark_missing "FreeLing library missing: runtime/freeling/lib/${lib}"
    fi
  done

  if [[ -d "${FREELING_SHARE_DIR}/common" ]]; then
    mark_ok "FreeLing common resources found."
  else
    mark_missing "FreeLing common resources missing."
  fi

  if [[ -d "${FREELING_SHARE_DIR}/es" ]]; then
    mark_ok "FreeLing Spanish resources found."
  else
    mark_missing "FreeLing Spanish resources missing."
  fi

  if [[ -x "${FREELING_SCRIPT_DIR}/check_runtime.sh" || -f "${FREELING_SCRIPT_DIR}/check_runtime.sh" ]]; then
    if bash "${FREELING_SCRIPT_DIR}/check_runtime.sh" >/tmp/midolec-freeling-doctor-check.log 2>&1; then
      mark_ok "FreeLing runtime check passes."
    else
      mark_missing "FreeLing runtime check does not pass yet."
      echo "           Details:"
      sed 's/^/           /' /tmp/midolec-freeling-doctor-check.log | tail -n 20
    fi
    rm -f /tmp/midolec-freeling-doctor-check.log
  else
    mark_missing "FreeLing runtime checker script is missing."
  fi
}

check_spacy() {
  local package_name

  echo
  echo "spaCy backend checklist"

  for package_name in "${SPACY_APT_PACKAGES[@]}"; do
    if apt_package_installed "$package_name"; then
      mark_ok "System package available: $package_name"
    else
      mark_missing "System package missing: $package_name"
    fi
  done

  if python_module_available spacy; then
    mark_ok "Python module available: spacy"
  else
    mark_missing "Python module missing: spacy"
  fi

  if python_module_available pyphen; then
    mark_ok "Python module available: pyphen"
  else
    mark_missing "Python module missing: pyphen"
  fi

  if python_module_available en_core_web_sm; then
    mark_ok "spaCy model package available: en_core_web_sm"
  else
    mark_missing "spaCy model package missing: en_core_web_sm"
  fi

  if [[ -f "${SPACY_MODEL_DIR}/config.cfg" ]]; then
    mark_ok "Runtime spaCy model copy found: runtime/spacy/models/en_core_web_sm"
  else
    mark_missing "Runtime spaCy model copy missing: runtime/spacy/models/en_core_web_sm"
  fi
}

print_summary() {
  echo
  echo "Doctor summary"
  if [[ "$MISSING_COUNT" -eq 0 ]]; then
    echo "  All required checks passed for backend: $BACKEND"
  else
    echo "  Missing items: $MISSING_COUNT"
  fi

  if [[ "$WARNING_COUNT" -gt 0 ]]; then
    echo "  Warnings: $WARNING_COUNT"
  fi

  if [[ "$MISSING_COUNT" -gt 0 ]]; then
    echo
    echo "Next step:"
    echo "  Run: bash runtime/provisioning/install_midolec_runtime.sh"
    echo
    echo "If the installer cannot solve the issue, copy the full terminal output and"
    echo "send it to gigabd@uc3m.es with subject: [midolec-dist] [install]"
  fi
}

echo "Midolec runtime doctor"
echo "Application root: $APP_ROOT"
echo "Selected backend: $BACKEND"
echo

check_linux_environment

case "$BACKEND" in
  freeling)
    check_freeling
    ;;
  spacy)
    check_spacy
    ;;
  all)
    check_freeling
    check_spacy
    ;;
esac

print_summary

if [[ "$MISSING_COUNT" -gt 0 ]]; then
  exit 1
fi

exit 0
