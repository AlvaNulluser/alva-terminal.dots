#!/usr/bin/env bash

# Interactive TUI Installer & Restorer for alva-terminal-dots
# Powered by Gum (Charmbracelet) with pure Bash fallback.
# Manages package dependencies, backups, and symlinks for Ghostty, Zellij, Herdr, Zsh, and Neovim.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUM_VERSION="v2.0.1"
GUM_BIN="${HOME}/.local/bin/gum"

# Ensure ~/.local/bin is in PATH for this script execution
export PATH="${HOME}/.local/bin:${PATH}"

# Theme colors (Tokyo Night / Catppuccin inspired)
COLOR_PRIMARY="#89b4fa"
COLOR_SECONDARY="#cba6f7"
COLOR_SUCCESS="#a6e3a1"
COLOR_WARNING="#f9e2af"
COLOR_MUTED="#6c7086"

# -----------------------------------------------------------------------------
# Dependency: Gum bootstrap
# -----------------------------------------------------------------------------
ensure_gum() {
  if command -v gum >/dev/null 2>&1; then
    return 0
  fi

  if [ -x "$GUM_BIN" ]; then
    return 0
  fi

  echo "Gum TUI engine not found. Bootstrapping standalone binary..."
  mkdir -p "${HOME}/.local/bin"

  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
  Linux) os="Linux" ;;
  Darwin) os="Darwin" ;;
  *)
    echo "Warning: Unsupported OS ($os) for automatic gum download. Using standard CLI fallback."
    return 1
    ;;
  esac

  case "$arch" in
  x86_64 | amd64) arch="x86_64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Warning: Unsupported architecture ($arch) for automatic gum download. Using standard CLI fallback."
    return 1
    ;;
  esac

  local download_url="https://github.com/charmbracelet/gum/releases/download/${GUM_VERSION}/gum_${GUM_VERSION#v}_${os}_${arch}.tar.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if curl -sL --fail "$download_url" | tar -xz -C "$tmp_dir" --strip-components=1 2>/dev/null; then
    mv "$tmp_dir/gum" "$GUM_BIN"
    chmod +x "$GUM_BIN"
    rm -rf "$tmp_dir"
    echo "Gum successfully installed to $GUM_BIN"
    return 0
  else
    rm -rf "$tmp_dir"
    echo "Warning: Could not download Gum. Falling back to non-TUI mode."
    return 1
  fi
}

# -----------------------------------------------------------------------------
# Package Manager Detection & Installation
# -----------------------------------------------------------------------------
detect_pm() {
  if command -v apt-get &>/dev/null || command -v apt &>/dev/null; then
    echo "apt"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v pkg &>/dev/null; then
    echo "pkg"
  else
    echo ""
  fi
}

install_packages() {
  local packages=("$@")
  if [ ${#packages[@]} -eq 0 ]; then
    return 0
  fi

  local pm
  pm=$(detect_pm)
  if [ -z "$pm" ]; then
    echo "Warning: No supported package manager found (apt, pacman, pkg). Please install: ${packages[*]} manually."
    return 0
  fi

  case "$pm" in
  apt)
    local apt_pkgs=()
    for pkg in "${packages[@]}"; do
      if [ "$pkg" = "fd" ]; then
        apt_pkgs+=("fd-find")
      else
        apt_pkgs+=("$pkg")
      fi
    done
    sudo apt-get update
    sudo apt-get install -y "${apt_pkgs[@]}"
    ;;
  pacman)
    sudo pacman -Sy --needed --noconfirm "${packages[@]}"
    ;;
  pkg)
    pkg update
    pkg install -y "${packages[@]}"
    ;;
  esac
}

# -----------------------------------------------------------------------------
# Zellij Plugins
# -----------------------------------------------------------------------------
install_zellij_plugins() {
  local plugins_dir="$REPO_ROOT/zellij/plugins"
  mkdir -p "$plugins_dir"

  local zjstatus_path="$plugins_dir/zjstatus.wasm"
  if [ ! -f "$zjstatus_path" ]; then
    curl -sL --fail \
      "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" \
      -o "$zjstatus_path" || echo "Warning: Failed to download zjstatus.wasm."
  fi

  local zellij_forgot_path="$plugins_dir/zellij_forgot.wasm"
  if [ ! -f "$zellij_forgot_path" ]; then
    curl -sL --fail \
      "https://github.com/karimould/zellij-forgot/releases/latest/download/zellij_forgot.wasm" \
      -o "$zellij_forgot_path" || echo "Warning: Failed to download zellij_forgot.wasm."
  fi
}

# -----------------------------------------------------------------------------
# Backup & Symlinks
# -----------------------------------------------------------------------------
# Receives an associative/paired array of source and target paths
backup_selected_configs() {
  local -n configs_ref=$1
  local backup_dir="$HOME/.config/alva-terminal-dots-backup-$(date +%Y%m%d_%H%M%S)"
  local backup_created=false

  for ((i = 0; i < ${#configs_ref[@]}; i += 2)); do
    local target="${configs_ref[i+1]}"
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ "$backup_created" = false ]; then
        mkdir -p "$backup_dir"
        backup_created=true
        echo "Created backup directory: $backup_dir"
      fi
      echo "Backing up: $target -> $backup_dir/"
      mv "$target" "$backup_dir/"
    fi
  done
}

link_selected_configs() {
  local -n configs_ref=$1
  for ((i = 0; i < ${#configs_ref[@]}; i += 2)); do
    local src="$REPO_ROOT/${configs_ref[i]}"
    local target="${configs_ref[i+1]}"

    mkdir -p "$(dirname "$target")"

    if [ -d "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    echo "Linking: $target -> $src"
    ln -sfn "$src" "$target"
  done
}

restore_configs() {
  local backups
  backups=($(find "$HOME/.config" -maxdepth 1 -name "alva-terminal-dots-backup-*" 2>/dev/null | sort || true))

  if [ ${#backups[@]} -eq 0 ]; then
    echo "Error: No backup directories found matching ~/.config/alva-terminal-dots-backup-*" >&2
    exit 1
  fi

  local latest_backup="${backups[-1]}"
  echo "Restoring from latest backup: $latest_backup"

  # Standard target paths to check for restoration
  local targets=(
    "$HOME/.zshrc"
    "$HOME/.config/ghostty"
    "$HOME/.config/zellij"
    "$HOME/.config/nvim"
    "$HOME/.config/herdr"
  )

  for target in "${targets[@]}"; do
    local basename_target
    basename_target=$(basename "$target")
    local backup_item="$latest_backup/$basename_target"

    if [ -L "$target" ] || [ -e "$target" ]; then
      rm -rf "$target"
    fi

    if [ -e "$backup_item" ] || [ -L "$backup_item" ]; then
      echo "Restoring: $target <- $backup_item"
      mv "$backup_item" "$target"
    fi
  done

  if [ -d "$latest_backup" ] && [ -z "$(ls -A "$latest_backup")" ]; then
    rmdir "$latest_backup"
  fi

  echo "Restore completed successfully."
}

# -----------------------------------------------------------------------------
# Interactive TUI Workflow (via Gum)
# -----------------------------------------------------------------------------
run_interactive_tui() {
  # Header Banner
  gum style \
    --border double \
    --margin "1 0" \
    --padding "1 2" \
    --border-foreground "$COLOR_PRIMARY" \
    --foreground "$COLOR_PRIMARY" \
    --bold \
    " •  alva-terminal-dots  • "

  # Step 1: Package Dependencies
  gum style --foreground "$COLOR_SECONDARY" --bold "1. Select CLI utilities to install:"
  local available_pkgs=("fzf" "zoxide" "lsd" "bat" "fd" "curl")
  local selected_pkgs_str
  selected_pkgs_str=$(gum choose --no-limit \
    --cursor.foreground="$COLOR_PRIMARY" \
    --selected.foreground="$COLOR_SUCCESS" \
    --selected="fzf,zoxide,lsd,bat,fd,curl" \
    "${available_pkgs[@]}")

  readarray -t selected_pkgs <<<"$selected_pkgs_str"

  # Step 2: Terminal Emulator
  echo ""
  gum style --foreground "$COLOR_SECONDARY" --bold "2. Terminal Emulator configuration:"
  local term_choice
  term_choice=$(gum choose \
    --cursor.foreground="$COLOR_PRIMARY" \
    --selected.foreground="$COLOR_SUCCESS" \
    "Ghostty (Catppuccin Mocha + Cursor Smear Shader)" \
    "Skip terminal configuration")

  # Step 3: Multiplexers
  echo ""
  gum style --foreground "$COLOR_SECONDARY" --bold "3. Select Multiplexer configuration(s) [Space to toggle, Enter to confirm]:"
  local mux_choice_str
  mux_choice_str=$(gum choose --no-limit \
    --cursor.foreground="$COLOR_PRIMARY" \
    --selected.foreground="$COLOR_SUCCESS" \
    --selected="Zellij (Ctrl+a, locked mode, auto tab rename)" \
    "Zellij (Ctrl+a, locked mode, auto tab rename)" \
    "Herdr (AI agents & workspace orchestrator)")

  # Step 4: Shell Configuration
  echo ""
  gum style --foreground "$COLOR_SECONDARY" --bold "4. Shell Configuration:"
  local shell_choice
  shell_choice=$(gum choose \
    --cursor.foreground="$COLOR_PRIMARY" \
    --selected.foreground="$COLOR_SUCCESS" \
    "Zsh (Oh My Zsh + Powerlevel10k + vi-mode cursor sync)" \
    "Skip shell configuration")

  # Step 5: Editor (Neovim)
  echo ""
  gum style --foreground "$COLOR_SECONDARY" --bold "5. Neovim (IDE) configuration:"
  local nvim_choice
  nvim_choice=$(gum choose \
    --cursor.foreground="$COLOR_PRIMARY" \
    --selected.foreground="$COLOR_SUCCESS" \
    "Link repository Neovim config (~/.config/nvim -> nvim/)" \
    "Skip (manage Neovim manually / work on custom config)")

  # Build the selected CONFIGS mapping
  local active_configs=()

  if [[ "$term_choice" =~ "Ghostty" ]]; then
    active_configs+=("ghostty" "$HOME/.config/ghostty")
  fi

  if [[ "$mux_choice_str" =~ "Zellij" ]]; then
    active_configs+=("zellij" "$HOME/.config/zellij")
  fi

  if [[ "$mux_choice_str" =~ "Herdr" ]]; then
    active_configs+=("herdr" "$HOME/.config/herdr")
  fi

  if [[ "$shell_choice" =~ "Zsh" ]]; then
    active_configs+=("zsh/.zshrc" "$HOME/.zshrc")
  fi

  if [[ "$nvim_choice" =~ "Link" ]]; then
    active_configs+=("nvim" "$HOME/.config/nvim")
  fi

  # Detailed Summary & Confirmation
  local summary_pkgs
  if [ ${#selected_pkgs[@]} -eq 0 ] || [ -z "${selected_pkgs[0]:-}" ]; then
    summary_pkgs="None (Skipped)"
  else
    summary_pkgs="${selected_pkgs[*]}"
  fi

  local summary_term
  if [[ "$term_choice" =~ "Ghostty" ]]; then
    summary_term="Ghostty (Catppuccin Mocha + Cursor Smear)"
  else
    summary_term="None (Skipped)"
  fi

  local mux_list=()
  [[ "$mux_choice_str" =~ "Zellij" ]] && mux_list+=("Zellij")
  [[ "$mux_choice_str" =~ "Herdr" ]] && mux_list+=("Herdr")
  local summary_mux
  if [ ${#mux_list[@]} -eq 0 ]; then
    summary_mux="None (Skipped)"
  else
    summary_mux="${mux_list[*]}"
  fi

  local summary_shell
  if [[ "$shell_choice" =~ "Zsh" ]]; then
    summary_shell="Zsh (~/.zshrc)"
  else
    summary_shell="None (Skipped)"
  fi

  local summary_nvim
  if [[ "$nvim_choice" =~ "Link" ]]; then
    summary_nvim="Neovim (~/.config/nvim -> nvim/)"
  else
    summary_nvim="None (Skipped)"
  fi

  echo ""
  gum style \
    --border rounded \
    --padding "1 2" \
    --border-foreground "$COLOR_WARNING" \
    "📋 Installation Plan Summary:" \
    "  • CLI Packages : $summary_pkgs" \
    "  • Terminal     : $summary_term" \
    "  • Multiplexer  : $summary_mux" \
    "  • Shell        : $summary_shell" \
    "  • Editor (IDE) : $summary_nvim" \
    "" \
    "Total configurations to link: $((${#active_configs[@]} / 2))"

  if ! gum confirm --prompt.foreground="$COLOR_PRIMARY" "Proceed with installation?"; then
    echo "Installation aborted by user."
    exit 0
  fi

  # Execution Phase
  if [ ${#selected_pkgs[@]} -gt 0 ] && [ -n "${selected_pkgs[0]}" ]; then
    gum spin --spinner dot --title.foreground="$COLOR_PRIMARY" --title "Installing package dependencies..." -- \
      bash -c "$(declare -f detect_pm install_packages); install_packages ${selected_pkgs[*]}"
  fi

  if [[ "$mux_choice_str" =~ "Zellij" ]]; then
    gum spin --spinner dot --title.foreground="$COLOR_PRIMARY" --title "Downloading Zellij WASM plugins..." -- \
      bash -c "$(declare -f install_zellij_plugins); REPO_ROOT='$REPO_ROOT' install_zellij_plugins"
  fi

  if [ ${#active_configs[@]} -gt 0 ]; then
    gum spin --spinner dot --title.foreground="$COLOR_PRIMARY" --title "Backing up and symlinking configurations..." -- \
      bash -c "$(declare -f backup_selected_configs link_selected_configs); \
               REPO_ROOT='$REPO_ROOT'; \
               configs=(${active_configs[*]}); \
               backup_selected_configs configs; \
               link_selected_configs configs"
  fi

  gum style \
    --foreground "$COLOR_SUCCESS" \
    --bold \
    "✔ Installation completed successfully! Enjoy your environment."
}

# -----------------------------------------------------------------------------
# Fallback / Non-interactive Workflow
# -----------------------------------------------------------------------------
run_default_unattended() {
  local default_configs=(
    "zsh/.zshrc" "$HOME/.zshrc"
    "ghostty" "$HOME/.config/ghostty"
    "zellij" "$HOME/.config/zellij"
    "herdr" "$HOME/.config/herdr"
  )
  local default_pkgs=("fzf" "zoxide" "lsd" "bat" "fd" "curl")

  echo "Running non-interactive installation..."
  install_packages "${default_pkgs[@]}"
  backup_selected_configs default_configs
  install_zellij_plugins
  link_selected_configs default_configs
  echo "Installation completed successfully."
}

show_help() {
  cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --interactive, -i  Launch interactive Gum TUI installer (default if run directly).
  --non-interactive  Run unattended installation with default configurations.
  --restore          Restore configurations from the latest backup directory.
  --help, -h         Show this help message.

EOF
}

# -----------------------------------------------------------------------------
# Main Entry Point
# -----------------------------------------------------------------------------
main() {
  if [ $# -gt 0 ]; then
    case "$1" in
    --restore)
      restore_configs
      ;;
    --non-interactive | -y)
      run_default_unattended
      ;;
    --interactive | -i)
      if ensure_gum; then
        run_interactive_tui
      else
        run_default_unattended
      fi
      ;;
    --help | -h)
      show_help
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 1
      ;;
    esac
  else
    if [ -t 0 ] && ensure_gum; then
      run_interactive_tui
    else
      run_default_unattended
    fi
  fi
}

main "$@"
