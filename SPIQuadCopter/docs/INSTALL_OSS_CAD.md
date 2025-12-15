OSS-CAD-SUITE (manual install)
=================================

This file shows a minimal, repeatable way to download a prebuilt OSS-CAD-SUITE release and install it locally for use with this project's Makefile.

We recommend installing into `~/.tools/oss-cad-suite` with the revision number in the path (e.g., `~/.tools/oss-cad-suite-rev123`). Adjust the paths below if you want to install elsewhere.

1) Pick the release asset

Open the releases page and choose the correct Linux x86_64 tarball:

  https://github.com/YosysHQ/oss-cad-suite-build/releases

You can also fetch the latest matching asset URL from the command line.

2) Quick one-liner (recommended)

This downloads the latest Linux x86_64 tarball, extracts it to `~/.tools/oss-cad-suite` with the revision number, and creates a symlink.

```bash
mkdir -p ~/.tools

# Find the latest asset URL and extract revision/build number from JSON
RELEASE_DATA=$(curl -s https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest)
REV=$(echo "$RELEASE_DATA" | grep -Po '"tag_name":\s*"\K[^"]+' | head -n1)
URL=$(echo "$RELEASE_DATA" | grep -Po '"browser_download_url":\s*"\K[^"]+' \
  | grep -iE 'linux.*(x86_64|amd64).*tar.xz' | head -n1)

if [ -z "$REV" ] || [ -z "$URL" ]; then
  echo "Failed to fetch release info. Check your internet connection or visit:"
  echo "https://github.com/YosysHQ/oss-cad-suite-build/releases"
  exit 1
fi

INSTALL_DIR="$HOME/.tools/oss-cad-suite-$REV"
echo "Revision: $REV"
echo "Downloading: $URL"
echo "Installing to: $INSTALL_DIR"

curl -L -o /tmp/oss-cad.tar.xz "$URL"
tar -xJf /tmp/oss-cad.tar.xz -C ~/.tools
mv ~/.tools/oss-cad-suite "$INSTALL_DIR"
ln -sfn "$INSTALL_DIR" ~/.tools/oss-cad-suite
rm /tmp/oss-cad.tar.xz

echo "Installation complete at: $INSTALL_DIR"
echo "Symlink: ~/.tools/oss-cad-suite -> $INSTALL_DIR"
```

If the Makefile installation fails or you want a specific version, you can also browse the releases page manually and download the correct tarball:
  
  https://github.com/YosysHQ/oss-cad-suite-build/releases

Then extract into `~/.tools` and create a symlink as needed.

3) Add the toolchain to your PATH

Add the following to your shell profile (`~/.bashrc`, `~/.profile`, or `~/.zshrc`):

```bash
export PATH="$HOME/.tools/oss-cad-suite/bin:$PATH"
```

Then reload the shell:

```bash
source ~/.bashrc   # or restart your shell
```

4) Verify installs

```bash
yosys --version
nextpnr-himbaechel --version
openFPGALoader --help   # optional; may be a separate package
```

5) openFPGALoader

The OSS-CAD-Suite releases include `openFPGALoader` by default. If for some reason it's not present in your installation, you can install it separately:

- From distro packages (Debian/Ubuntu):

  sudo apt-get install openfpgaloader

- Or build & install locally (scripts in this project include a helper: `scripts/install_local_tools.sh`).

6) Notes and troubleshooting

- Releases are large (hundreds of MB → 1GB); ensure sufficient disk space and a stable connection.
- The installation script creates a versioned directory (e.g., `~/.tools/oss-cad-suite-20250101`) and maintains a symlink at `~/.tools/oss-cad-suite` for easy PATH management. You can keep multiple versions and switch by updating the symlink.
- If the automatic URL lookup doesn't find a suitable asset, open the releases page in a browser and download the correct tarball manually, then extract into `~/.tools` and rename/symlink as needed.
- If you need additional runtime libraries (e.g., for building openFPGALoader), install these on Debian/Ubuntu before building: `build-essential cmake pkg-config libusb-1.0-0-dev libftdi1-dev`.
