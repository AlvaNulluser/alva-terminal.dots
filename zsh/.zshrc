# Ensure PATH includes common executable locations for multiplexer detection
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

#==========================================
# MULTIPLEXER (Gentleman.Dots architecture)
#==========================================
WM_VAR="$HERDR_ENV"
WM_CMD="herdr"

function start_if_needed() {
    if [[ $- == *i* ]] &&
       command -v "$WM_CMD" >/dev/null 2>&1 &&
       [[ -z "$TMUX" ]] &&
       [[ -z "$ZELLIJ" ]] &&
       [[ -z "$HERDR_ENV" ]] &&
       [[ -z "$SSH_CLIENT" ]] &&
       [[ -z "$SSH_TTY" ]] &&
       [[ -t 1 ]]; then
        $WM_CMD
        local exit_code=$?
        if [[ $exit_code -eq 0 ]]; then
            exit 0
        else
            echo -e "\033[1;33m⚠️  $WM_CMD falló al iniciar (código $exit_code).\033[0m"
            echo -e "\033[0;36m💡 Cayendo a shell interactiva estándar. Tip: Revisá 'herdr status' o logs en ~/.config/herdr/\033[0m\n"
        fi
    fi
}

start_if_needed

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#==========================================
#CONFIGURACIONES
#==========================================

export ZSH="$HOME/.oh-my-zsh"

# Tema Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

#plugins
plugins=(
    git
    python 
    docker
    vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Configuración del plugin vi-mode antes de cargar Oh My Zsh
# Forzamos que el cursor sea un bloque parpadeante en todos los modos (1 = blinking block)
# Esto es CRUCIAL para que los shaders de Ghostty puedan renderizar la estela con el tamaño correcto.
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=1
VI_MODE_CURSOR_VISUAL=1
VI_MODE_CURSOR_INSERT=1
VI_MODE_CURSOR_OPPEND=1
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true

#inicia oh-my-zsh
source $ZSH/oh-my-zsh.sh

#menú de autocompletado
zstyle ':completion:*' menu select

#variables de Entorno y PATH
if [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# Evita pisar la prioridad del venv: solo añade si no existen en el PATH
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
[[ ":$PATH:" != *":$HOME/.opencode/bin:"* ]] && export PATH="$HOME/.opencode/bin:$PATH"

#Alias de lsd
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

# Detectar comandos fd y bat de forma dinámica según el sistema operativo (Debian/Arch/Termux)
if command -v fdfind &>/dev/null; then
    alias fd='fdfind'
    export FD_CMD='fdfind'
elif command -v fd &>/dev/null; then
    export FD_CMD='fd'
else
    export FD_CMD='fd'
fi

if command -v batcat &>/dev/null; then
    alias bat='batcat'
    export BAT_CMD='batcat'
elif command -v bat &>/dev/null; then
    export BAT_CMD='bat'
else
    export BAT_CMD='bat'
fi
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Alias de alerta para comandos largos
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Cargar aliases externos si existen (¡Excelente para tus dotfiles!)
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# Prompt configurado con Powerlevel10k (cargado automáticamente por Oh My Zsh)



# bun completions
[ -s "/home/null_creed/.bun/_bun" ] && source "/home/null_creed/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/null_creed/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# fnm
FNM_PATH="/home/null_creed/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# Go 
export PATH=$PATH:/usr/local/go/bin


# Added by Antigravity CLI installer
export PATH="/home/null_creed/.local/bin:$PATH"

# Pi
export PATH="/home/null_creed/.local/share/fnm/node-versions/v24.15.0/installation/bin:$PATH"



# Renombrar pestañas en Zellij según el proceso activo
if [[ -n $ZELLIJ ]]; then
  function rename_zellij_tab_preexec() {
    local cmd="${1%% *}"
    cmd="${cmd##*/}"
    (zellij action rename-tab "$cmd" >/dev/null 2>&1 &)
  }

  function rename_zellij_tab_precmd() {
    local dir_name="${PWD##*/}"
    [[ -z "$dir_name" ]] && dir_name="/"
    (zellij action rename-tab "$dir_name" >/dev/null 2>&1 &)
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook preexec rename_zellij_tab_preexec
  add-zsh-hook precmd rename_zellij_tab_precmd
fi

#==========================================
# INTEGRACIÓN DE FZF Y ZOXIDE
#==========================================

# FZF: Configuración y comandos por defecto usando fdfind directamente (para evitar fallas de alias)
export FZF_DEFAULT_COMMAND="$FD_CMD --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FD_CMD --type d --hidden --strip-cwd-prefix --exclude .git"

# BAT: Configuración del tema por defecto (Catppuccin-Mocha)
export BAT_THEME="Catppuccin-Mocha"

# FZF: Cargar scripts de completado e integración de teclas (Debian paths)
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh

# FZF: Aliases con preview dinámico (usando bat/batcat si existen, sino cat)
alias fzfbat='fzf --preview="$BAT_CMD --color=always {} || cat {}"'
alias fzfnvim='nvim $(fzf --preview="$BAT_CMD --color=always {} || cat {}")'

# ZOXIDE: Inicialización
eval "$(zoxide init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

