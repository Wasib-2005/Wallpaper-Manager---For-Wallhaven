# Wallhaven Wallpaper CLI & Daemon

A powerful, customizable CLI tool and background daemon that automatically fetches and applies high-quality desktop wallpapers from [wallhaven.cc](https://wallhaven.cc).

It supports Linux (KDE, GNOME, feh), macOS, and Windows.

## ✨ Features

- **Advanced Filtering:** Filter by search query, resolution, aspect ratio, purity (SFW/Sketchy/NSFW), and categories.
- **Background Daemon:** Run silently in the background and change your wallpaper on a customizable timer.
- **Immediate Refresh:** Instantly skip to the next wallpaper without waiting for the timer.
- **Persistent Configuration:** Saves your settings so you don't have to type them every time.
- **Automatic Cleanup:** Deletes old wallpapers automatically to save disk space.
- **Smart Logging:** Built-in log rotation with customizable file size limits.

---

## 🚀 Installation (Linux / macOS)

A setup script is provided to easily install the tool, add it to your `PATH`, and set it to automatically start on login.

1. Clone or download this repository.
2. Make the scripts executable:
   ```bash
   chmod +x setup.sh uninstall.sh wallpaper
   ```
3. Run the installer:
   ```bash
   ./setup.sh
   ```
4. *Note: If `wallpaper` is not recognized immediately, restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`).*

---

## 📖 Usage

You can run the script manually, or set it up to run as a daemon.

### Basic Examples

**Set a random nature wallpaper immediately:**
```bash
wallpaper -Q "nature"
```

**Start the background daemon, changing a Cyberpunk wallpaper every 30 minutes:**
```bash
wallpaper -Q "cyberpunk" -T 30 -D
```

**Exclude anime wallpapers, set resolution to 4K, and run in the background:**
```bash
wallpaper -Q "-anime" -R 3840x2160 -D
```

**Pull from the all-time top-rated wallpapers instead of random:**
```bash
wallpaper -S toplist --top-range 1y
```

**Save settings without running (updates your default config):**
```bash
wallpaper -Q "landscape" -R 2560x1440 --set
```

---

## ⚙️ Service & Management Commands

Once the daemon is running in the background (`-D`), you can control it using these commands:

| Command | Description |
| :--- | :--- |
| `wallpaper --now` | Instantly fetches and applies a new wallpaper. |
| `wallpaper --status` | Checks if the background daemon is currently running. |
| `wallpaper --stop` | Stops the running background daemon. |
| `wallpaper --set` | Saves the passed flags to config without running or starting the daemon. |
| `wallpaper -LOG` | Prints the last 50 lines of the daemon's log. |
| `wallpaper -f` | Live streams the background service logs. |

---

## 🛠️ Configuration Options

| Flag | Name | Description | Example |
| :--- | :--- | :--- | :--- |
| `-Q` | `--query` | Search term(s). Use `-` to exclude (e.g., `-anime`). | `-Q "cars"` |
| `-T` | `--timer` | Refresh timer in minutes. | `-T 15` (15 mins) |
| `-R` | `--resolution`| Minimum resolution. | `-R "1920x1080"` |
| `-A` | `--ratio` | Aspect ratio(s) separated by commas. | `-A "16x9,21x9"` |
| `-P` | `--purity` | Purity bitmask (100=SFW, 010=Sketchy, 001=NSFW). | `-P "110"` |
| `-C` | `--categories`| Category bitmask (100=General, 010=Anime, 001=People). | `-C "100"` |
| `-S` | `--sort` | Sorting method (random, date_added, toplist, etc.). | `-S "random"` |
| | `--top-range` | Timeframe when `--sort toplist` is used (1d, 3d, 1w, 1M, 3M, 6M, 1y). | `--top-range 1M` |
| `-K` | `--key` | Wallhaven API Key (Required for NSFW / 001 content). | `-K "your_api_key"` |
| `-M` | `--keep` | Max downloaded images to keep in `~/Pictures/Wallhaven`. Default: 1. | `-M 5` |
| `-L` | `--max-log-size`| Maximum log file size limit before rotation. | `-L "5MB"` |

> **Note on Clearing Configs:** If you want to reset a saved setting back to default, pass `none` or an empty string. Example: `wallpaper -K none` will remove your saved API key. This also applies to numeric flags like `-M`/`--keep`: passing `-M 0` with `--set` won't persist as "unlimited" — it clears the setting back to the default (`1`) instead. `-M 0` still works for a single one-off run without `--set`.

---

## 📂 File Locations

- **Executable:** `~/.local/bin/wallpaper`
- **Config & Logs:** `~/.config/wallhaven/`
  - `config.json` (Saved settings)
  - `wallpaper.log` (Service logs)
- **Wallpapers:** `~/Pictures/Wallhaven/`
- **Autostart Entry:** `~/.config/autostart/wallhaven-daemon.desktop`

---

## 🗑️ Uninstallation

If you wish to remove the script, autostart entries, and (optionally) your configurations, simply run the included uninstall script:

```bash
./uninstall.sh
```
