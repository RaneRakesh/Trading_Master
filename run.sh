#!/usr/bin/env bash
# ==============================================================================
# Trading Master — Unified Execution Script (Mobile & Web)
# ==============================================================================
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# Default configuration
TARGET_MODE="auto"
TARGET_DEVICE=""
STARTED_BACKEND=false
BACKEND_PID=""

# Color helpers
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}==========================================================${NC}"
    echo -e "${BLUE}   🚀 Starting Trading Master AI Decision Support System  ${NC}"
    echo -e "${BLUE}==========================================================${NC}"
}

print_help() {
    echo "Usage: ./run.sh [MODE] [OPTIONS]"
    echo ""
    echo "Modes:"
    echo "  mobile              Run on connected mobile device (default if device attached)"
    echo "  web                 Run as Web server on http://0.0.0.0:3000"
    echo "  chrome              Run inside Google Chrome desktop browser"
    echo "  auto                Auto-detect: Use mobile if connected, else web (default)"
    echo ""
    echo "Options:"
    echo "  -d, --device <ID>   Specify target mobile device ID (e.g. R9ZR30HWSBN)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./run.sh                  # Smart auto-detect"
    echo "  ./run.sh mobile           # Explicitly launch on mobile device"
    echo "  ./run.sh web              # Launch web server"
    echo "  ./run.sh chrome           # Launch in Chrome browser"
    echo "  ./run.sh -d R9ZR30HWSBN   # Target specific device ID"
}

# Parse Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        mobile|--mobile|-m)
            TARGET_MODE="mobile"
            shift
            ;;
        web|--web|-w)
            TARGET_MODE="web"
            shift
            ;;
        chrome|--chrome|-c)
            TARGET_MODE="chrome"
            shift
            ;;
        auto)
            TARGET_MODE="auto"
            shift
            ;;
        -d|--device)
            TARGET_DEVICE="$2"
            TARGET_MODE="mobile"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1. Defaulting to auto-detection.${NC}"
            shift
            ;;
    esac
done

cleanup() {
    if [ "$STARTED_BACKEND" = true ] && [ -n "$BACKEND_PID" ]; then
        echo -e "\n${YELLOW}Stopping FastAPI backend (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT INT TERM

print_banner

# ------------------------------------------------------------------------------
# 1. Environment & SDK Discovery
# ------------------------------------------------------------------------------
echo -e "${BLUE}[1/5] Checking Toolchains & Environment...${NC}"

# Find Flutter
if ! command -v flutter &>/dev/null; then
    for candidate in "$HOME/develop/flutter/bin/flutter" "$HOME/flutter/bin/flutter" "/opt/flutter/bin/flutter"; do
        if [ -x "$candidate" ]; then
            export PATH="$(dirname "$candidate"):$PATH"
            break
        fi
    done
fi

if ! command -v flutter &>/dev/null; then
    echo -e "${RED}Error: Flutter SDK not found in PATH or standard directories.${NC}"
    echo "Please ensure Flutter is installed and added to PATH."
    exit 1
fi
echo -e "  ${GREEN}✓${NC} Flutter: $(flutter --version | head -n 1)"

# Android SDK & Tools
if [ -z "$ANDROID_HOME" ]; then
    if [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
    fi
fi

if [ -n "$ANDROID_HOME" ]; then
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        export PATH="$ANDROID_HOME/platform-tools:$PATH"
    fi
    if [ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]; then
        export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    fi
    echo -e "  ${GREEN}✓${NC} Android SDK: $ANDROID_HOME"
fi

# Locate Modern JDK (JDK 17+) for Gradle 8/9 builds
CURRENT_JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ "$CURRENT_JAVA_VER" = "1" ] || [ -z "$JAVA_HOME" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
    # Look for Android Studio JBR or system JDK 17+
    for jbr_candidate in \
        "/snap/android-studio/current/jbr" \
        "/snap/android-studio/242/jbr" \
        "/snap/android-studio/241/jbr" \
        "/usr/lib/jvm/java-17-openjdk-amd64" \
        "/usr/lib/jvm/java-21-openjdk-amd64"; do
        if [ -d "$jbr_candidate" ] && [ -x "$jbr_candidate/bin/java" ]; then
            export JAVA_HOME="$jbr_candidate"
            export PATH="$JAVA_HOME/bin:$PATH"
            break
        fi
    done
fi

if [ -n "$JAVA_HOME" ]; then
    echo -e "  ${GREEN}✓${NC} Java Home (JDK 17+ compatible): $JAVA_HOME"
fi

# ------------------------------------------------------------------------------
# 2. Python Backend Dependencies
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[2/5] Checking Python Backend Dependencies...${NC}"
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Error: python3 is not installed.${NC}"
    exit 1
fi

MISSING_PY_DEPS=false
python3 -c "import fastapi, uvicorn, yfinance, pandas, numpy, sklearn" 2>/dev/null || MISSING_PY_DEPS=true

if [ "$MISSING_PY_DEPS" = true ]; then
    echo -e "  ${YELLOW}Installing missing backend dependencies from requirements.txt...${NC}"
    python3 -m pip install -r "$BACKEND_DIR/requirements.txt"
else
    echo -e "  ${GREEN}✓${NC} Backend Python packages are satisfied."
fi

# ------------------------------------------------------------------------------
# 3. Flutter Dependencies & Platform Files
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[3/5] Verifying Flutter Packages & Setup...${NC}"
cd "$FRONTEND_DIR"

if [ ! -d ".dart_tool" ]; then
    echo "  Running 'flutter pub get'..."
    flutter pub get
else
    echo -e "  ${GREEN}✓${NC} Frontend dependencies resolved."
fi

# Ensure Android platform is generated if needed
if [ ! -d "android" ]; then
    echo "  Creating Android platform scaffolding..."
    flutter create . --platforms=android
fi

# ------------------------------------------------------------------------------
# 4. Start Backend Server (Port 8000)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[4/5] Launching FastAPI Backend Server...${NC}"

# Check if backend is already running
if curl -s -m 2 http://127.0.0.1:8000/health | grep -q "healthy"; then
    echo -e "  ${GREEN}✓${NC} FastAPI backend is already running on http://127.0.0.1:8000"
else
    cd "$BACKEND_DIR"
    python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload &
    BACKEND_PID=$!
    STARTED_BACKEND=true
    cd "$PROJECT_ROOT"

    # Wait for backend health
    echo -n "  Waiting for backend to be ready"
    READY=false
    for _ in {1..15}; do
        if curl -s -m 1 http://127.0.0.1:8000/health | grep -q "healthy"; then
            READY=true
            break
        fi
        echo -n "."
        sleep 1
    done
    echo ""

    if [ "$READY" = true ]; then
        echo -e "  ${GREEN}✓${NC} Backend running (PID: $BACKEND_PID)"
    else
        echo -e "  ${YELLOW}Warning: Backend health check took longer than expected. Continuing...${NC}"
    fi
fi
echo -e "  API Documentation: ${GREEN}http://localhost:8000/docs${NC}"

# ------------------------------------------------------------------------------
# 5. Device Target Selection & Launch
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}[5/5] Preparing Target Device & Launching Application...${NC}"

# Resolve target mode if "auto"
if [ "$TARGET_MODE" = "auto" ]; then
    if command -v adb &>/dev/null; then
        ATTACHED_DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | awk '{print $1}')
        if [ -n "$ATTACHED_DEVICES" ]; then
            TARGET_MODE="mobile"
            echo -e "  ${GREEN}✓ Connected mobile device detected. Launching in Mobile mode.${NC}"
        else
            TARGET_MODE="web"
            echo -e "  ${YELLOW}No mobile device detected. Defaulting to Web mode.${NC}"
        fi
    else
        TARGET_MODE="web"
    fi
fi

cd "$FRONTEND_DIR"

if [ "$TARGET_MODE" = "mobile" ]; then
    # Ensure adb is present
    if ! command -v adb &>/dev/null; then
        echo -e "${RED}Error: 'adb' tool not found. Please connect your Android device or specify 'web' mode.${NC}"
        exit 1
    fi

    # Find connected device if not explicitly specified
    if [ -z "$TARGET_DEVICE" ]; then
        TARGET_DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | head -n 1 | awk '{print $1}')
    fi

    if [ -z "$TARGET_DEVICE" ]; then
        echo -e "${RED}Error: No authorized Android mobile device or emulator found.${NC}"
        echo "Check your USB cable, verify USB Debugging is ON, and run 'adb devices'."
        exit 1
    fi

    DEVICE_MODEL=$(adb -s "$TARGET_DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r' || echo "$TARGET_DEVICE")
    echo -e "  Target Device: ${GREEN}$DEVICE_MODEL${NC} (ID: $TARGET_DEVICE)"

    # Set up reverse port forwarding so phone reaches host's FastAPI backend
    echo "  Configuring ADB reverse port forwarding (device:8000 -> host:8000)..."
    adb -s "$TARGET_DEVICE" reverse tcp:8000 tcp:8000
    echo -e "  ${GREEN}✓${NC} ADB reverse tunnel active."

    echo -e "\n${GREEN}🚀 Launching Trading Master on $DEVICE_MODEL...${NC}\n"
    flutter run -d "$TARGET_DEVICE"

elif [ "$TARGET_MODE" = "chrome" ]; then
    echo -e "\n${GREEN}🚀 Launching Trading Master in Google Chrome...${NC}\n"
    flutter run -d chrome

elif [ "$TARGET_MODE" = "web" ]; then
    echo -e "\n${GREEN}🚀 Starting Trading Master Web Application...${NC}"
    echo -e "  Web Application URL: ${GREEN}http://localhost:3000${NC}\n"
    flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
fi
