#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"
TARGET_BIN="$TARGET_DIR/wallpaper"
WALLPAPER_SRC="$SCRIPT_DIR/wallpaper"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_ENTRY="$AUTOSTART_DIR/wallhaven-daemon.desktop"

echo "🔍 Checking desktop environment..."

# 1. Check for KDE Plasma
DESKTOP_ENV="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
DESKTOP_ENV_LOWER="$(echo "$DESKTOP_ENV" | tr '[:upper:]' '[:lower:]')"

if [[ "$DESKTOP_ENV_LOWER" != *"kde"* ]]; then
    echo "⚠️ Warning: Desktop environment is '$DESKTOP_ENV', not KDE."
    echo "   Automatic wallpaper setting might not work out-of-the-box."
    read -p "Do you wish to continue anyway? (y/N): " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            echo "Proceeding with setup..."
            ;;
        *)
            echo "❌ Setup cancelled by user."
            exit 0
            ;;
    esac
else
    echo "✅ KDE Plasma detected!"
fi

# 2. Check source file existence
if [ ! -f "$WALLPAPER_SRC" ]; then
    echo "❌ Error: Could not find 'wallpaper' source file in $SCRIPT_DIR"
    exit 1
fi

# 3. Create ~/.local/bin if missing
if [ ! -d "$TARGET_DIR" ]; then
    echo "📁 Creating directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 4. Hash verification for existing installation
if [ -f "$TARGET_BIN" ]; then
    SRC_HASH=$(sha256sum "$WALLPAPER_SRC" | awk '{print $1}')
    TARGET_HASH=$(sha256sum "$TARGET_BIN" | awk '{print $1}')

    if [ "$SRC_HASH" = "$TARGET_HASH" ]; then
        echo "ℹ️ You already have this exact version installed."
        read -p "Do you want to reinstall/overwrite it anyway? (y/N): " reinstall
        case "$reinstall" in
            [yY][eE][sS]|[yY])
                echo "Reinstalling..."
                ;;
            *)
                echo "Skipped file replacement."
                ;;
        esac
    else
        echo "🔄 An older or different version of 'wallpaper' was found."
        read -p "Do you want to replace it with the new version? (Y/n): " replace
        case "$replace" in
            [nN][oO]|[nN])
                echo "Replacement cancelled by user."
                ;;
            *)
                echo "Overwriting existing version..."
                cp "$WALLPAPER_SRC" "$TARGET_BIN"
                chmod +x "$TARGET_BIN"
                echo "✅ Successfully updated wallpaper executable!"
                ;;
        esac
    fi
else
    # Direct Copy if file does not exist
    echo "📦 Installing 'wallpaper' to $TARGET_DIR..."
    cp "$WALLPAPER_SRC" "$TARGET_BIN"
    chmod +x "$TARGET_BIN"
    echo "✅ Installed wallpaper executable."
fi

# 5. Shell PATH Configuration (Bash, Zsh, Fish)
echo "⚙️ Checking PATH configuration for your shell..."

# Check Fish shell config
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -d "$HOME/.config/fish" ] || [ -f "$FISH_CONFIG" ]; then
    mkdir -p "$HOME/.config/fish"
    if ! grep -q '\.local/bin' "$FISH_CONFIG" 2>/dev/null; then
        echo 'fish_add_path ~/.local/bin' >> "$FISH_CONFIG"
        echo "✅ Added ~/.local/bin to Fish path ($FISH_CONFIG)."
    fi
fi

# Check Bash config (~/.bashrc)
BASH_CONFIG="$HOME/.bashrc"
if [ -f "$BASH_CONFIG" ]; then
    if ! grep -q '\.local/bin' "$BASH_CONFIG"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASH_CONFIG"
        echo "✅ Added ~/.local/bin to Bash path ($BASH_CONFIG)."
    fi
fi

# Check Zsh config (~/.zshrc)
ZSH_CONFIG="$HOME/.zshrc"
if [ -f "$ZSH_CONFIG" ]; then
    if ! grep -q '\.local/bin' "$ZSH_CONFIG"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSH_CONFIG"
        echo "✅ Added ~/.local/bin to Zsh path ($ZSH_CONFIG)."
    fi
fi

# 6. Set up Autostart on Login
echo "⚙️ Setting up autostart daemon..."
mkdir -p "$AUTOSTART_DIR"

cat <<EOF > "$DESKTOP_ENTRY"
[Desktop Entry]
Type=Application
Name=Wallhaven Wallpaper Daemon
Exec=$TARGET_BIN -D
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Automatically changes desktop wallpaper in background
EOF

chmod +x "$DESKTOP_ENTRY"

echo ""
echo "🎉 Setup complete!"
echo "• Installed at: $TARGET_BIN"
echo "• Autostart entry: $DESKTOP_ENTRY"
echo ""
echo "💡 If 'wallpaper --help' is not found immediately, restart your terminal or run:"
echo "   source ~/.bashrc   # For Bash"
echo "   source ~/.zshrc    # For Zsh"
