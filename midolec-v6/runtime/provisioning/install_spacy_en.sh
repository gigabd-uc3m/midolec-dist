#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SPACY_MODEL_TARGET="${RUNTIME_ROOT}/spacy/models/en_core_web_sm"
PYTHON_BIN="${MIDOLEC_PYTHON:-python3}"
COPY_MODEL_TO_RUNTIME=1
UPGRADE_PACKAGES=0

print_usage() {
  cat <<'EOF'
Usage:
  runtime/provisioning/install_spacy_en.sh [options]

Options:
  --python PATH              Python executable to use. Defaults to MIDOLEC_PYTHON or python3.
  --upgrade                  Upgrade spacy and pyphen even if already installed.
  --no-runtime-copy          Do not copy the downloaded model into runtime/spacy/models/.
  -h, --help                 Show this help.

Installs the English backend dependencies currently used by Midolec:
  - spacy
  - pyphen
  - en_core_web_sm
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --python)
      PYTHON_BIN="${2:?Missing value for --python}"
      shift 2
      ;;
    --upgrade)
      UPGRADE_PACKAGES=1
      shift
      ;;
    --no-runtime-copy)
      COPY_MODEL_TO_RUNTIME=0
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

run_python() {
  "$PYTHON_BIN" "$@"
}

module_available() {
  local module_name="$1"
  run_python -c "import ${module_name}" >/dev/null 2>&1
}

install_package() {
  local package_name="$1"
  if [[ "$UPGRADE_PACKAGES" -eq 1 ]]; then
    run_python -m pip install --upgrade "$package_name"
  elif module_available "$package_name"; then
    echo "OK: Python module '${package_name}' is already installed."
  else
    run_python -m pip install "$package_name"
  fi
}

ensure_spacy_model() {
  if run_python - <<'PY' >/dev/null 2>&1
import spacy
spacy.load("en_core_web_sm")
PY
  then
    echo "OK: spaCy model 'en_core_web_sm' is already available."
  else
    run_python -m spacy download en_core_web_sm
  fi
}

copy_model_to_runtime() {
  if [[ "$COPY_MODEL_TO_RUNTIME" -eq 0 ]]; then
    return 0
  fi

  local model_path
  model_path="$(
    run_python - <<'PY'
from pathlib import Path
import en_core_web_sm
package_path = Path(en_core_web_sm.__file__).resolve().parent
candidate_paths = [package_path] + sorted(path for path in package_path.iterdir() if path.is_dir())
for candidate_path in candidate_paths:
    if (candidate_path / "config.cfg").is_file():
        print(candidate_path)
        break
else:
    raise SystemExit(f"Could not find loadable spaCy model folder under {package_path}")
PY
  )"

  mkdir -p "$(dirname "$SPACY_MODEL_TARGET")"
  rm -rf "$SPACY_MODEL_TARGET"
  cp -a "$model_path" "$SPACY_MODEL_TARGET"
  echo "Copied spaCy model package to: $SPACY_MODEL_TARGET"
  echo "The English loader can now prefer the bundled runtime model when it exists."
}

main() {
  if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    echo "Python executable not found: $PYTHON_BIN" >&2
    exit 1
  fi

  run_python -m pip --version >/dev/null
  install_package spacy
  install_package pyphen
  ensure_spacy_model
  copy_model_to_runtime

  echo "English spaCy dependencies are ready."
}

main "$@"
