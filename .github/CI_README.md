# GitHub CI Setup for Speech Note (dsnote)

This directory contains GitHub Actions workflows for building Speech Note packages.

## Workflows

### 1. CI Build (`ci.yml`)
- Builds packages for both x86_64 and aarch64 architectures
- Runs on push to main/master branches
- Creates releases automatically on main branch commits

**Triggers:**
- Push to `main` or `master` branches
- Pull requests

**Outputs:**
- Arch Linux packages (`.pkg.tar.zst`) for x86_64 and aarch64
- Automatic GitHub releases with checksums

### 2. Build Container (`build-container.yml`)
- Builds and publishes the aarch64 build container to GitHub Container Registry
- Runs weekly or on demand

**Triggers:**
- Changes to `docker/Dockerfile.aarch64`
- Manual trigger via workflow_dispatch
- Weekly scheduled build (Sunday midnight)

**Outputs:**
- Container image: `ghcr.io/<owner>/dsnote-aarch64-builder:latest`

## Building Locally

### Build aarch64 Container

```bash
cd docker
docker build --platform linux/arm64 -t dsnote-aarch64-builder -f Dockerfile.aarch64 .
```

### Build Package in Container

```bash
# Run the container
docker run --rm -it -v $(pwd):/workspace dsnote-aarch64-builder

# Inside container
cd /workspace
cp arch/git/* .
sudo -u builduser makepkg --syncdeps --noconfirm
```

## Architecture Support

### x86_64
- Full feature support including CUDA (optional)
- Vulkan support (Intel, AMD, NVIDIA)
- Built using standard Arch Linux container

### aarch64
- Vulkan support for Mali and other ARM GPUs
- Optimized for ARM64 architecture
- Built using custom aarch64 container with cross-compilation support

## Release Process

CI automatically creates a release on every push to the `main` branch:

1. Push commits to main: `git push origin main`
2. GitHub Actions will automatically:
   - Build packages for both architectures
   - Create a GitHub release with commit SHA as tag
   - Upload packages as release assets
   - Generate SHA256 checksums

## Configuration Options

The build uses the following CMake options:
- `WITH_DESKTOP=ON` - Enable desktop UI
- `WITH_PY=ON` - Enable Python libraries
- `BUILD_WHISPERCPP_VULKAN=ON` - Enable Vulkan support
- `DOWNLOAD_VOSK=ON` - Download Vosk models

For aarch64, CUDA support is automatically disabled as it's not available on ARM.

## Artifacts

Build artifacts are retained for 7 days and include:
- `dsnote-git-*.pkg.tar.zst` (x86_64)
- `dsnote-git-*.pkg.tar.zst` (aarch64)

## Requirements

### For aarch64 builds on GitHub Actions
- Runner with ARM64 support or QEMU emulation
- GitHub Container Registry access for container images

### For local builds
- Docker with multi-architecture support
- QEMU for cross-platform builds (if building aarch64 on x86_64)

## Troubleshooting

### aarch64 build fails
- Ensure QEMU is properly configured if running on x86_64
- Check that the container image is built for arm64 platform
- Verify all ARM-specific dependencies are installed

### CUDA support on x86_64
- Install CUDA toolkit before building
- Set `FULL_BUILD=true` in PKGBUILD
- Ensure compatible NVIDIA drivers are installed
