#!/bin/bash
# Build script for aarch64 container image
# Usage: ./build-aarch64-container.sh [OPTIONS]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER_NAME="dsnote-aarch64-builder"
DOCKERFILE="${SCRIPT_DIR}/Dockerfile.aarch64"
PUSH=false
TAG="latest"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Build aarch64 container image for Speech Note"
            echo ""
            echo "Options:"
            echo "  --push          Push to GitHub Container Registry"
            echo "  --tag TAG       Tag for the image (default: latest)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

cd "$PROJECT_DIR"

echo "Building aarch64 container image..."
echo "Project directory: $PROJECT_DIR"
echo "Dockerfile: $DOCKERFILE"
echo "Image name: $CONTAINER_NAME"
echo "Tag: $TAG"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if buildx is available
if ! docker buildx version &> /dev/null; then
    echo "Error: Docker buildx is not available"
    exit 1
fi

# Create/build builder instance
echo "Setting up Docker buildx..."
docker buildx create --name dsnote-builder --use --bootstrap 2>/dev/null || docker buildx use dsnote-builder

# Build the image
if [ "$PUSH" = true ]; then
    echo "Building and pushing to GitHub Container Registry..."
    echo "Note: You need to be logged in to ghcr.io. Run: docker login ghcr.io"
    
    GITHUB_USER="${GITHUB_USER:-$(gh auth user 2>/dev/null || echo "unknown")}"
    IMAGE_NAME="ghcr.io/${GITHUB_USER}/${CONTAINER_NAME}:${TAG}"
    
    docker buildx build \
        --platform linux/arm64 \
        --push \
        -t "$IMAGE_NAME" \
        -f "$DOCKERFILE" \
        "$PROJECT_DIR"
    
    echo "Image pushed: $IMAGE_NAME"
else
    echo "Building local image..."
    
    docker buildx build \
        --platform linux/arm64 \
        --load \
        -t "${CONTAINER_NAME}:${TAG}" \
        -f "$DOCKERFILE" \
        "$PROJECT_DIR"
    
    echo "Image built successfully: ${CONTAINER_NAME}:${TAG}"
fi

echo ""
echo "To use the container:"
echo "  docker run --rm -it -v $(pwd):/workspace ${CONTAINER_NAME}:${TAG}"
echo ""
echo "To build a package inside the container:"
echo "  cp arch/git/* ."
echo "  sudo -u builduser makepkg --syncdeps --noconfirm"
