#!/usr/bin/env bash
set -e
TARGET_BIN="$HOME/.local/bin/wallpaper"
DESKTOP_ENTRY="$HOME/.config/autostart/wallhaven-daemon.desktop"
CONFIG_DIR="$HOME/.config/wallhaven"
echo "🧹 Starting uninstallation of Wallhaven Wallpaper tool..."
# 1. Stop any running daemon instance
if pgrep -f "wallpaper (-D|--daemon)" > /dev/null || [ -f "$CONFIG_DIR/wallpaper.pid" ]; then
    echo "🛑 Stopping running wallpaper daemon..."
    if command -v wallpaper &> /dev/null; then
        wallpaper --stop 2>/dev/null || true
    fi
    # Fallback kill if process still lingers
    if [ -f "$CONFIG_DIR/wallpaper.pid" ]; then
        PID=$(cat "$CONFIG_DIR/wallpaper.pid" 2>/dev/null || true)
        if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            kill "$PID" 2>/dev/null || true
        fi
    fi
fi
# 2. Remove binary executable
if [ -f "$TARGET_BIN" ]; then
    rm -f "$TARGET_BIN"
    echo "🗑️ Removed executable: $TARGET_BIN"
else
    echo "ℹ️ Binary not found at $TARGET_BIN (skipping)."
fi
# 3. Remove autostart entry
if [ -f "$DESKTOP_ENTRY" ]; then
    rm -f "$DESKTOP_ENTRY"
    echo "🗑️ Removed autostart entry: $DESKTOP_ENTRY"
else
    echo "ℹ️ Autostart entry not found (skipping)."
fi
# 4. Prompt for configuration & cache cleanup
if [ -d "$CONFIG_DIR" ]; then
    read -p "Do you also want to delete your settings and logs ($CONFIG_DIR)? (y/N): " rm_config
    case "$rm_config" in
        [yY][eE][sS]|[yY])
            rm -rf "$CONFIG_DIR"
            echo "🗑️ Removed configuration and log directory: $CONFIG_DIR"
            ;;
        *)
            echo "📁 Kept configuration directory at $CONFIG_DIR"
            ;;
    esac
else
    echo "ℹ️ Configuration directory not found (skipping)."
fi
echo ""
echo "✨ Uninstallation complete!"
