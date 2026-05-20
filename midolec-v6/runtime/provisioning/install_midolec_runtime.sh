#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PYTHON_BIN="${MIDOLEC_PYTHON:-python3}"
BACKEND=""
ASSUME_YES=0
COMPLETED_STEPS=()
SKIPPED_STEPS=()
FAILED_STEPS=()

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
  bash runtime/provisioning/install_midolec_runtime.sh [options]

Options:
  --backend NAME   Install one backend: freeling, spacy, or all.
  --yes            Do not ask for confirmation before installing.
  --python PATH    Python executable used by the spaCy installer. Default: python3.
  -h, --help       Show this help.

This is the recommended user-facing installer for Midolec V6.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --backend)
      BACKEND="${2:?Missing value for --backend}"
      shift 2
      ;;
    --yes|-y)
      ASSUME_YES=1
      shift
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
  ""|freeling|spacy|all) ;;
  *)
    echo "Unknown backend: $BACKEND" >&2
    echo "Expected: freeling, spacy, or all." >&2
    exit 2
    ;;
esac

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

select_backend_interactively() {
  local choice

  echo "Select the runtime backend you want to prepare:"
  echo "  1) FreeLing (Spanish backend)"
  echo "  2) spaCy (English backend)"
  echo "  3) Both FreeLing and spaCy"
  echo
  printf "Enter a number [1-3]: "
  read -r choice

  case "$choice" in
    1) BACKEND="freeling" ;;
    2) BACKEND="spacy" ;;
    3) BACKEND="all" ;;
    *)
      echo "Invalid selection: $choice" >&2
      exit 2
      ;;
  esac
}

packages_for_backend() {
  case "$BACKEND" in
    freeling)
      printf '%s\n' "${FREELING_APT_PACKAGES[@]}"
      ;;
    spacy)
      printf '%s\n' "${SPACY_APT_PACKAGES[@]}"
      ;;
    all)
      printf '%s\n' "${FREELING_APT_PACKAGES[@]}" "${SPACY_APT_PACKAGES[@]}" | sort -u
      ;;
  esac
}

missing_apt_packages() {
  local package_name

  while IFS= read -r package_name; do
    [[ -z "$package_name" ]] && continue
    if ! apt_package_installed "$package_name"; then
      printf '%s\n' "$package_name"
    fi
  done < <(packages_for_backend)
}

confirm_installation() {
  local answer

  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi

  echo
  echo "To make Midolec work correctly, the installer may run these actions:"
  if [[ "${#MISSING_PACKAGES[@]}" -gt 0 ]]; then
    echo "  - sudo apt update"
    echo "  - sudo apt install -y ${MISSING_PACKAGES[*]}"
  else
    echo "  - No missing Ubuntu/WSL system packages were detected."
  fi

  case "$BACKEND" in
    freeling)
      echo "  - Install/configure FreeLing runtime assets"
      ;;
    spacy)
      echo "  - Install/configure spaCy English runtime"
      ;;
    all)
      echo "  - Install/configure FreeLing runtime assets"
      echo "  - Install/configure spaCy English runtime"
      ;;
  esac

  echo
  printf "Do you agree? Type yes to continue: "
  read -r answer

  if [[ "$answer" != "yes" ]]; then
    SKIPPED_STEPS+=("User cancelled before installation.")
    return 1
  fi
}

record_failure_hint() {
  local step_name="$1"

  echo
  echo "The step failed: $step_name"
  echo "Common causes:"
  echo "  - No internet connection or GitHub/PyPI is unreachable."
  echo "  - Missing sudo permissions."
  echo "  - Unsupported environment. Use Ubuntu, WSL Ubuntu, or SSH into Linux."
  echo "  - Not enough disk space."
  echo
  echo "If this does not match your case, copy the full terminal output and send it"
  echo "to gigabd@uc3m.es with subject: [midolec-dist] [install]"
}

run_step() {
  local step_name="$1"
  shift

  echo
  echo "==> $step_name"
  if "$@"; then
    COMPLETED_STEPS+=("$step_name")
    return 0
  fi

  FAILED_STEPS+=("$step_name")
  record_failure_hint "$step_name"
  return 1
}

install_missing_apt_packages() {
  if [[ "${#MISSING_PACKAGES[@]}" -eq 0 ]]; then
    SKIPPED_STEPS+=("Ubuntu/WSL system packages already installed.")
    return 0
  fi

  if ! command_exists apt-get; then
    echo "apt-get was not found. Automatic OS package installation is not available." >&2
    return 1
  fi

  if ! command_exists sudo; then
    echo "sudo was not found. Ask an administrator to install: ${MISSING_PACKAGES[*]}" >&2
    return 1
  fi

  run_step "Install missing Ubuntu/WSL packages" sudo apt-get update || return 1
  run_step "Install packages: ${MISSING_PACKAGES[*]}" sudo apt-get install -y "${MISSING_PACKAGES[@]}"
}

install_freeling() {
  run_step "Install and configure FreeLing" bash "${SCRIPT_DIR}/install_configure_freeling.sh" --root "$APP_ROOT"
}

install_spacy() {
  run_step "Install and configure spaCy" bash "${SCRIPT_DIR}/install_spacy_en.sh" --python "$PYTHON_BIN"
}

run_doctor() {
  echo
  echo "Running final doctor check..."
  if bash "${SCRIPT_DIR}/doctor.sh" --backend "$BACKEND" --python "$PYTHON_BIN"; then
    COMPLETED_STEPS+=("Final doctor check passed.")
    return 0
  fi

  FAILED_STEPS+=("Final doctor check reported missing items.")
  return 1
}

print_summary() {
  echo
  echo "Installation summary"

  if [[ "${#COMPLETED_STEPS[@]}" -gt 0 ]]; then
    echo "Completed:"
    printf '  - %s\n' "${COMPLETED_STEPS[@]}"
  fi

  if [[ "${#SKIPPED_STEPS[@]}" -gt 0 ]]; then
    echo "Skipped:"
    printf '  - %s\n' "${SKIPPED_STEPS[@]}"
  fi

  if [[ "${#FAILED_STEPS[@]}" -gt 0 ]]; then
    echo "Failed:"
    printf '  - %s\n' "${FAILED_STEPS[@]}"
    echo
    echo "The installation did not finish cleanly. Please review the error above."
    echo "If the cause is not clear, send the full terminal output to gigabd@uc3m.es"
    echo "with subject: [midolec-dist] [install]"
    return 1
  fi

  echo
  echo "Midolec runtime setup finished successfully."
  echo "You can now run one of the example commands from the README."
  return 0
}

echo "Midolec V6 guided runtime installer"
echo "Application root: $APP_ROOT"

if [[ "$(uname -s 2>/dev/null || true)" != "Linux" ]]; then
  echo "ERROR: this installer must run in Ubuntu, WSL Ubuntu, or a Linux server." >&2
  echo "MobaXterm/Cygwin/MSYS/Git Bash local shells are not supported." >&2
  exit 1
fi

if [[ -z "$BACKEND" ]]; then
  select_backend_interactively
fi

echo "Selected backend: $BACKEND"

echo
echo "Initial environment checklist"
bash "${SCRIPT_DIR}/doctor.sh" --backend "$BACKEND" --python "$PYTHON_BIN" || true

mapfile -t MISSING_PACKAGES < <(missing_apt_packages)

if ! confirm_installation; then
  print_summary
  exit 1
fi

install_missing_apt_packages || {
  print_summary
  exit 1
}

case "$BACKEND" in
  freeling)
    install_freeling || {
      print_summary
      exit 1
    }
    ;;
  spacy)
    install_spacy || {
      print_summary
      exit 1
    }
    ;;
  all)
    install_freeling || {
      print_summary
      exit 1
    }
    install_spacy || {
      print_summary
      exit 1
    }
    ;;
esac

run_doctor || {
  print_summary
  exit 1
}

print_summary
