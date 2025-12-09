#!/usr/bin/env bash
set -euo pipefail

# Installer: download prebuilt OSS-CAD-SUITE and openFPGALoader to ~/.tools
# Usage: ./scripts/install_local_tools.sh [--prefix /path/to/install]

PREFIX="${HOME}/.tools"
if [ "${1:-}" = "--prefix" ]; then
  PREFIX="$2"
fi

mkdir -p "$PREFIX/bin" "$PREFIX/src" "$PREFIX/tmp"
echo "Installing tools to: $PREFIX"

CURL=${CURL:-curl}
TAR=${TAR:-tar}
GIT=${GIT:-git}

# Helper to find and download a release asset from GitHub
# args: repo e.g. YosysHQ/oss-cad-suite-build pattern
download_github_asset() {
  repo="$1"
  pattern="$2"
  outdir="$3"

  echo "Querying GitHub releases for $repo (asset pattern: $pattern)"
  api_url="https://api.github.com/repos/${repo}/releases/latest"
  json="$($CURL -s "$api_url")"
  asset_url=$(printf "%s" "$json" | grep -Po '"browser_download_url":\s*"\K[^"]+' | grep -i -E "$pattern" || true)

  if [ -z "$asset_url" ]; then
    echo "No matching release asset found for ${repo} with pattern ${pattern}"
    return 1
  fi

  file="${outdir}/$(basename "$asset_url")"
  echo "Downloading: $asset_url -> $file"
  $CURL -L -o "$file" "$asset_url"
  echo "$file"
}

# 1) OSS-CAD-SUITE (prebuilt)
OSS_DEST="$PREFIX/oss-cad-suite"
if [ -x "$OSS_DEST/bin/yosys" ]; then
  echo "oss-cad-suite already installed in $OSS_DEST"
else
  mkdir -p "$PREFIX/tmp"
  echo "Attempting to download prebuilt OSS CAD Suite..."
  asset=$(download_github_asset "YosysHQ/oss-cad-suite-build" "linux.*(x86_64|amd64).*tar.xz|oss-cad-suite.*linux.*tar" "$PREFIX/tmp" || true)
  if [ -n "$asset" ] && [ -f "$asset" ]; then
    echo "Extracting $asset to $OSS_DEST"
    mkdir -p "$OSS_DEST"
    $TAR -xJf "$asset" -C "$OSS_DEST" --strip-components=1
    echo "Symlinking binaries into $PREFIX/bin"
    for b in "$OSS_DEST"/bin/*; do
      [ -f "$b" ] || continue
      ln -sf "$b" "$PREFIX/bin/$(basename "$b")"
    done
  else
    echo "Prebuilt OSS CAD Suite not found. Please install system packages or build manually." >&2
  fi
fi

# 2) openFPGALoader
OFL_DEST="$PREFIX/openFPGALoader"
if command -v openFPGALoader >/dev/null 2>&1; then
  echo "openFPGALoader already available in PATH"
else
  echo "Trying to download openFPGALoader release binaries..."
  asset=$(download_github_asset "trabucayre/openFPGALoader" "linux.*(x86_64|amd64).*tar.xz|openFPGALoader.*linux.*tar" "$PREFIX/tmp" || true)
  if [ -n "$asset" ] && [ -f "$asset" ]; then
    mkdir -p "$OFL_DEST"
    echo "Extracting $asset to $OFL_DEST"
    $TAR -xJf "$asset" -C "$OFL_DEST" --strip-components=1
    echo "Symlinking openFPGALoader into $PREFIX/bin"
    if [ -f "$OFL_DEST/bin/openFPGALoader" ]; then
      ln -sf "$OFL_DEST/bin/openFPGALoader" "$PREFIX/bin/openFPGALoader"
    elif [ -f "$OFL_DEST/openFPGALoader" ]; then
      ln -sf "$OFL_DEST/openFPGALoader" "$PREFIX/bin/openFPGALoader"
    fi
  else
    echo "No prebuilt openFPGALoader found; attempting to build from source (requires cmake, pkg-config, libusb-1.0-dev, libftdi1-dev)."
    # If on Debian/Ubuntu, try to install required build deps automatically.
    if command -v apt-get >/dev/null 2>&1; then
      echo "Detected apt; installing build dependencies via sudo apt-get..."
      sudo apt-get update
      sudo apt-get install -y build-essential cmake pkg-config libusb-1.0-0-dev libftdi1-dev git curl tar || echo "apt-get install failed; please install dependencies manually"
    fi

    mkdir -p "$PREFIX/src"
    cd "$PREFIX/src"
    if [ ! -d "openFPGALoader" ]; then
      $GIT clone --depth 1 https://github.com/trabucayre/openFPGALoader.git
    fi
    cd openFPGALoader
    mkdir -p build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$OFL_DEST"
    make -j$(nproc)
    make install
    if [ -f "$OFL_DEST/bin/openFPGALoader" ]; then
      ln -sf "$OFL_DEST/bin/openFPGALoader" "$PREFIX/bin/openFPGALoader"
    fi
  fi
fi

# 3) Ensure ~/.tools/bin is on PATH (print instructions; do not modify shell files automatically)
cat <<'EOF'

Installation attempt finished.
If the following directory is not in your PATH, add it to your shell profile:

  export PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"

Add it to ~/.bashrc or ~/.profile, for example:

  echo 'export PATH="$PREFIX/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc

Then verify tools:
  yosys --version
  nextpnr-himbaechel --version
  openFPGALoader --help

EOF

# Cleanup tmp
rm -rf "$PREFIX/tmp"

echo "Done."
