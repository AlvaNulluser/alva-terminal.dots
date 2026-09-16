# alva-terminal-dots

Personal dotfiles and development environment configured with the **Catppuccin Mocha** palette, GPU-accelerated terminal emulation, modular multiplexing, and an ergonomic **LazyVim** IDE setup.

[![OS - Linux / macOS](https://img.shields.io/badge/OS-Linux%20%7C%20macOS-blue?style=flat-square&logo=linux)](https://github.com)
[![Shell - Zsh](https://img.shields.io/badge/Shell-Zsh%20(Powerlevel10k)-f5c2e7?style=flat-square&logo=gnu-bash)](https://www.zsh.org)
[![Editor - Neovim](https://img.shields.io/badge/Editor-Neovim%20v0.12+-89b4fa?style=flat-square&logo=neovim)](https://neovim.io)
[![Theme - Catppuccin Mocha](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-cba6f7?style=flat-square)](https://github.com/catppuccin/catppuccin)
[![Installer - Gum TUI](https://img.shields.io/badge/Installer-Gum%20TUI-a6e3a1?style=flat-square)](https://github.com/charmbracelet/gum)

---

## Table of Contents

- [Highlights](#highlights)
- [Prerequisites](#prerequisites)
- [Installation & Quickstart](#installation--quickstart)
  - [Interactive Mode (Recommended)](#1-interactive-tui-installation)
  - [Unattended / CI Mode](#2-unattended--ci-mode)
  - [Backup & Restoration](#3-backup--restoration)
- [Managed Components](#managed-components)
- [Daily Driver Cheatsheet](#daily-driver-cheatsheet)
  - [Neovim (IDE)](#neovim-ide)
  - [Multiplexers (Zellij & Herdr)](#multiplexers-zellij--herdr)
  - [Ghostty Shader](#ghostty-shader)
- [Repository Structure](#repository-structure)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Credits & License](#credits--license)

---

## Highlights

- **Modular TUI Installer**: Interactive selection powered by [Gum](https://github.com/charmbracelet/gum) with automatic dependency detection, standalone engine bootstrap, idempotent execution, and automated timestamped backups.
- **Unified Multiplexer Muscle Memory**: Shared `Ctrl+a` prefix navigation across both [Zellij](https://zellij.dev) (locked-mode default) and [Herdr](https://github.com/gentleman-programming/herdr) (agent and workspace orchestrator).
- **Modern Neovim IDE**: Built on [LazyVim](https://www.lazyvim.org/) with transparent background integration, full LSP and tooling suite for Python (Pyright, Ruff, `venv-selector`), Web development (TypeScript, Tailwind, Prettier), file management (Neo-tree and Oil.nvim), and low-latency AI code completion via Supermaven.
- **Fluid Visual Ergonomics**: Ghostty GPU terminal configuration featuring background blur, custom GLSL cursor smear trails, and synchronized vi-mode cursor shapes.
- **Hardened Shell**: Zsh configured with Powerlevel10k, modern CLI replacement tools (`lsd`, `bat`, `fzf`, `zoxide`), and defensive multiplexer auto-spawning.

---

## Prerequisites

### Core System Requirements

Ensure the following foundational tools are present on your system before launching the installer:

| Tool | Purpose | Recommended Installation |
| :--- | :--- | :--- |
| **Ghostty** | GPU-accelerated terminal emulator | Official packages via [ghostty.org](https://ghostty.org) |
| **Neovim** | Extensible text editor (v0.12+ recommended) | Package manager or release binary from [neovim.io](https://neovim.io) |
| **Zsh** | Interactive login shell | `sudo apt install zsh` / `sudo pacman -S zsh` |
| **Git** | Version control system | `sudo apt install git` / `sudo pacman -S git` |
| **JetBrainsMono Nerd Font** | Primary typeface with powerline & glyph symbols | Download from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) |

### Automatically Provisioned by Installer

The installer automatically detects your operating system and package manager (`apt`, `pacman`, `pkg`) to bootstrap:

- **CLI Utilities**: `fzf`, `zoxide`, `lsd`, `bat`, `fd` (mapped to `fd-find` on Debian/Ubuntu), and `curl`.
- **Gum Binary**: Automatically downloaded to `~/.local/bin/gum` if not present on system PATH.
- **Zellij WebAssembly Plugins**: Auto-downloads `zjstatus.wasm` and `zellij_forgot.wasm` directly into `zellij/plugins/`.

---

## Installation & Quickstart

### 1. Interactive TUI Installation

Clone the repository and run the setup script:

```bash
git clone <repo-url> ~/work/proyectos/alva-terminal-dots
cd ~/work/proyectos/alva-terminal-dots
./install.sh
```

The interactive Gum menu will guide you step-by-step:
1. **CLI Utilities Selection**: Checkbox multi-select to choose system packages to install.
2. **Terminal Emulator**: Toggle Ghostty configuration linking and shader assets.
3. **Multiplexers**: Choose between Zellij, Herdr, both, or none.
4. **Shell Configuration**: Link Zsh configuration (`.zshrc`).
5. **Editor Setup**: Link custom LazyVim IDE configuration (`~/.config/nvim`).
6. **Execution Confirmation**: Review the planned changes before any symlink or file operation is executed.

### 2. Unattended / CI Mode

For continuous integration, Docker containers, or automated dotfile provisioning:

```bash
./install.sh --non-interactive
# or
./install.sh -y
```

This skips interactive prompts and links all standard components with safe defaults.

### 3. Backup & Restoration

Before replacing any existing configuration, the installer creates an isolated backup in:
`~/.config/alva-terminal-dots-backup-<TIMESTAMP>/`

To revert all symlinks and restore your original configuration files:

```bash
./install.sh --restore
```

---

## Managed Components

| Component | Target Path | Source Path | Description |
| :--- | :--- | :--- | :--- |
| **Ghostty** | `~/.config/ghostty/` | [`ghostty/`](./ghostty/) | Catppuccin Mocha theme, blur settings, and GLSL cursor trail shader |
| **Zellij** | `~/.config/zellij/` | [`zellij/`](./zellij/) | Locked-mode default, `Ctrl+a` bindings, custom Tokyo Night layout |
| **Herdr** | `~/.config/herdr/` | [`herdr/`](./herdr/) | Workspace multiplexer & AI agent orchestrator configuration |
| **Zsh** | `~/.zshrc` | [`zsh/.zshrc`](./zsh/.zshrc) | Oh My Zsh integration, vi-mode cursor shape sync, dynamic aliases |
| **Neovim** | `~/.config/nvim/` | [`nvim/`](./nvim/) | Custom LazyVim configuration with modular plugins in `lua/plugins/` |

---

## Daily Driver Cheatsheet

### Neovim (IDE)

Leader key is mapped to `<Space>`.

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| `<leader>e` | Toggle Neo-tree | File tree navigation in left sidebar |
| `-` | Open Oil.nvim | Edit directory structure directly as a buffer |
| `<leader><Space>` | Snacks Picker: Files | Fast fuzzy finder for project files |
| `<leader>/` | Snacks Picker: Grep | Live grep across project workspace |
| `<leader>,` | Snacks Picker: Buffers | Switch between currently open buffers |
| `<leader>cv` | Select Virtualenv | Switch Python `.venv` using `venv-selector.nvim` |
| `<leader>w` / `:w` | Save & Format | Triggers automated formatting via `conform.nvim` |
| `<C-j>` | Supermaven Accept | Accept inline AI completion suggestion |

### Multiplexers (Zellij & Herdr)

Both multiplexers share the `Ctrl+a` prefix to preserve muscle memory.

#### Zellij (Starts in LOCKED mode)

| Keybinding | Action |
| :--- | :--- |
| `Ctrl+a` then `v` | Split pane vertically |
| `Ctrl+a` then `d` | Split pane horizontally |
| `Ctrl+a` then `h` / `j` / `k` / `l` | Navigate between pane directions |
| `Ctrl+a` then `c` | Create new tab |
| `Ctrl+a` then `1` .. `9` | Jump directly to tab index |
| `Ctrl+a` then `?` | Open keybinding cheatsheet (`zellij_forgot`) |
| `Ctrl+g` | Switch between Locked mode and Normal mode |

#### Herdr

| Keybinding | Action |
| :--- | :--- |
| `Ctrl+a` then `Alt+j` | Navigate to next agent session |
| `Ctrl+a` then `Alt+k` | Navigate to previous agent session |
| `Ctrl+a` then `Ctrl+1..9` | Direct jump to agent index |

### Ghostty Shader

The custom cursor smear shader (`shaders/cursor_smear_mid.glsl`) produces a fluid motion trail on cursor jumps. 

To disable the shader while keeping the terminal theme:
1. Open `~/.config/ghostty/config`.
2. Comment out the custom shader line:
   ```text
   #custom-shader = shaders/cursor_smear_mid.glsl
   ```
3. Reload Ghostty (`Ctrl+Shift+,` or restart the terminal).

---

## Repository Structure

```text
alva-terminal-dots/
├── ghostty/
│   ├── config                      # Terminal window, font, and theme settings
│   └── shaders/
│       └── cursor_smear_mid.glsl   # GLSL cursor trail shader
├── herdr/
│   └── config.toml                 # Agent orchestrator and multiplexer layout
├── install.sh                      # Gum TUI and headless installer script
├── nvim/
│   ├── init.lua                    # Neovim entrypoint
│   └── lua/
│       ├── config/                 # Core options, keymaps, and LazyVim bootstrap
│       └── plugins/                # Modular plugin specs (ai, lsp, ui, etc.)
├── zellij/
│   ├── config.kdl                  # Zellij keybindings and mode configurations
│   ├── layouts/                    # Custom session layouts
│   └── plugins/                    # WASM plugins (zjstatus, zellij_forgot)
└── zsh/
    └── .zshrc                      # Shell prompt, vi-mode hooks, and aliases
```

---

## Troubleshooting & FAQ

### Icons and Glyphs Displaying as Broken Boxes
Ensure your terminal font is set to a patched Nerd Font. In `ghostty/config`, the default font is:
```text
font-family = "JetBrainsMono Nerd Font"
```
Install it from [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases) if symbols are not rendering correctly.

### Ghostty Cursor Smear Shader Does Not Animate in Vi-Mode
Ghostty's smear shader relies on block cursor dimensions to compute geometry. The included `zsh/.zshrc` automatically synchronizes cursor shapes on mode change:
```zsh
function zle-keymap-select() {
  echo -ne '\e[2 q' # Maintain steady block cursor for shader geometry
}
```
If you override your shell's cursor shapes with beam (`|`) or underline (`_`), the smear shader will appear static or invisible.

### Multiplexer Daemon Version Mismatch
When upgrading Herdr or Zellij, lingering background daemons on older protocol versions can cause immediate startup disconnections. Terminate existing daemon instances before relaunching:
```bash
killall herdr-server 2>/dev/null || true
zellij kill-all-sessions 2>/dev/null || true
```

### Debian / Ubuntu `fd` Binary Name
On Debian and Ubuntu, `fd` is packaged as `fdfind`. The installer configures this automatically, and `zsh/.zshrc` exports an alias `alias fd=fdfind` so scripts and Neovim plugins operate seamlessly.

---

## Credits & License

- Built upon ergonomic foundations from [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots).
- Color schemes inspired by [Catppuccin](https://github.com/catppuccin/catppuccin).
- Terminal plugins powered by [zjstatus](https://github.com/dj95/zjstatus) and [zellij-forgot](https://github.com/karimould/zellij-forgot).
- Neovim ecosystem powered by [LazyVim](https://www.lazyvim.org/).

Licensed under the [MIT License](https://opensource.org/licenses/MIT).
