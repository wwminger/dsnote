# Dockerfile for build environment for Speech Note (dsnote)
# Supports: linux/amd64, linux/arm64
# Build: docker buildx build --platform linux/amd64,linux/arm64 -t dsnote-builder .
FROM ogarcia/archlinux:devel

LABEL maintainer="Michal Kosciesza <michal@mkiol.net>"
LABEL description="Build environment for Speech Note"
LABEL org.opencontainers.image.source="https://github.com/mkiol/dsnote"

# Set platform for multi-arch builds
ARG TARGETPLATFORM=linux/amd64

# Update system
RUN pacman -Syu --noconfirm && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Install runtime dependencies (from PKGBUILD depends)
RUN pacman -S --noconfirm --needed \
    boost-libs \
    fmt \
    glslang \
    gst-plugins-good \
    hicolor-icon-theme \
    kconfigwidgets5 \
    kdbusaddons5 \
    kiconthemes5 \
    kirigami2 \
    libarchive \
    libpulse \
    libxinerama \
    libxtst \
    ocl-icd \
    openblas \
    python \
    python-accelerate \
    python-pip \
    python-torchaudio \
    python-transformers \
    qt5-base \
    qt5-declarative \
    qt5-multimedia \
    qt5-quickcontrols2 \
    qt5-x11extras \
    rubberband \
    taglib \
    vulkan-icd-loader \
    wayland \
    xz && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Install build dependencies (from PKGBUILD makedepends)
RUN pacman -S --noconfirm --needed \
    boost \
    cmake \
    extra-cmake-modules \
    git \
    meson \
    patchelf \
    pybind11 \
    qt5-tools \
    vulkan-headers \
    sudo && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*


# Install optional dependencies (from PKGBUILD optdepends)
# ydotool: Support for inserting text into active window in Wayland
RUN pacman -S --noconfirm --needed \
    ydotool || true && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Create build user
RUN useradd -m builduser && \
    echo "builduser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builduser && \
    chmod 0440 /etc/sudoers.d/builduser

# Configure git for builduser
RUN su - builduser -c "git config --global --add safe.directory /workspace"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
