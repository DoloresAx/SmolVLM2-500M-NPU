#!/usr/bin/env bash
# ==============================================================================
# Script to download SmolVLM2-500M models for RK3588 NPU
# Models downloaded:
#   1. smolvlm2_500m_vision_fp16_rk3588.rknn (~206 MB)
#   2. smolvlm2_500m_llm_w8a8_rk3588.rkllm   (~484 MB)
# Source: Hugging Face (Qengineering/smolvlm2-500m-rk3588)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/models"
HF_BASE_URL="https://huggingface.co/Qengineering/smolvlm2-500m-rk3588/resolve/main"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

FORCE_DOWNLOAD=false
for arg in "$@"; do
    case "$arg" in
        -f|--force)
            FORCE_DOWNLOAD=true
            ;;
        -h|--help)
            echo "Usage: $0 [-f|--force]"
            echo "  -f, --force    Re-download files even if they already exist"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown argument: $arg${NC}"
            echo "Usage: $0 [-f|--force]"
            exit 1
            ;;
    esac
done

# Ensure models directory exists
mkdir -p "${TARGET_DIR}"

# Check for download tool
DOWNLOAD_CMD=""
if command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget"
elif command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl"
else
    echo -e "${RED}Error: Neither 'wget' nor 'curl' found. Please install one of them.${NC}"
    exit 1
fi

MODELS=(
    "smolvlm2_500m_vision_fp16_rk3588.rknn"
    "smolvlm2_500m_llm_w8a8_rk3588.rkllm"
)

download_file() {
    local filename="$1"
    local url="${HF_BASE_URL}/${filename}"
    local filepath="${TARGET_DIR}/${filename}"

    echo -e "${BLUE}==>${NC} Checking ${YELLOW}${filename}${NC}..."

    if [ -f "${filepath}" ] && [ "${FORCE_DOWNLOAD}" = false ]; then
        local filesize
        filesize=$(stat -c%s "${filepath}" 2>/dev/null || stat -f%z "${filepath}" 2>/dev/null || echo 0)
        if [ "$filesize" -gt 1048576 ]; then # larger than 1MB
            echo -e "   ${GREEN}[OK]${NC} Already downloaded (${filesize} bytes). Skipping."
            echo -e "   Use ${YELLOW}--force${NC} to re-download if needed."
            return 0
        else
            echo -e "   ${YELLOW}[!]${NC} Existing file seems incomplete (${filesize} bytes). Re-downloading..."
        fi
    fi

    echo -e "   Downloading from: ${url}"
    if [ "${DOWNLOAD_CMD}" = "wget" ]; then
        wget -c --show-progress -q -O "${filepath}" "${url}" || {
            echo -e "${RED}Failed to download ${filename} with wget${NC}"
            return 1
        }
    elif [ "${DOWNLOAD_CMD}" = "curl" ]; then
        curl -L --progress-bar -C - -o "${filepath}" "${url}" || {
            echo -e "${RED}Failed to download ${filename} with curl${NC}"
            return 1
        }
    fi

    echo -e "   ${GREEN}[SUCCESS]${NC} Saved to ${filepath}"
}

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}   SmolVLM2-500M Model Downloader for RK3588 NPU     ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo "Target directory: ${TARGET_DIR}"
echo ""

for model in "${MODELS[@]}"; do
    download_file "${model}"
    echo ""
done

echo -e "${GREEN}All models are ready!${NC}"
echo "Models location:"
ls -lh "${TARGET_DIR}"/*.{rknn,rkllm} 2>/dev/null || true
echo ""
echo "Example run command:"
echo "  ./build/VLM_NPU ./Moon.jpg ./models/smolvlm2_500m_vision_fp16_rk3588.rknn ./models/smolvlm2_500m_llm_w8a8_rk3588.rkllm"
