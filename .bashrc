# ================== interactive shells only ==================
case $- in *i*) ;; *) return ;; esac

# ================== Oh My Bash config =======================
# Path to your oh-my-bash installation.
export OSH="$HOME/.oh-my-bash"

# Theme
OSH_THEME="powerbash10k"



# OMB options
COMPLETION_WAITING_DOTS="true"
OMB_USE_SUDO=true
OMB_PROMPT_SHOW_PYTHON_VENV=true
OMB_PROMPT_SHOW_SPACK_ENV=true

# Completions to load
completions=(
  composer
)

# Aliases groups to load
aliases=(
  general
)

# Plugins to load
plugins=(
  git
  bashmarks
  fzf
  pyenv
)


# ---- Load Oh My Bash (load once, after the vars above) -----
if [[ -r "$OSH/oh-my-bash.sh" ]]; then
  source "$OSH/oh-my-bash.sh"
fi

# =================== Shell QoL / tools ======================
# Avoid Ctrl-S freezing the terminal
stty -ixon 2>/dev/null

# fzf shell integration (keybindings + fuzzy completion for Bash)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# bash-completion (argument-aware completions)
[[ -r /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion

# ===================== PATH tweaks ==========================
# Add ~/.local/bin to PATH if not already present
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac


# =================== GUI niceties ===========================
if [[ -n ${DISPLAY:-} ]]; then
  command -v xmodmap >/dev/null 2>&1 && xmodmap ~/.Xmodmap &>/dev/null
fi

# =================== Editing mode / editors =================
set -o vi
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"
export PAGER='less'
export LESS='-R'
unset MANPAGER

# ======================= aliases ============================
alias ff='/home/duck/.config/fastfetch/fastfetch_random.sh'
alias ports='ss -tulpn | bat --file-name "LISTENING PORTS"'
alias v='nvim'
alias start='sudo systemctl start'
alias stop='sudo systemctl stop'
alias grep='grep --color=auto'
alias myip="$HOME/Scripts/ip_lookup.sh"
alias la='ls -A'
alias lsa='ls -als'
alias l='ls -CF'
alias ..='cd ..'
alias update='yay -Syu && yay -Scc --noconfirm && yay -Yc --noconfirm'
alias services='systemctl list-units --type=service --state=running'
alias newvenv='python3 -m venv .venv && . .venv/bin/activate'
alias activate='. .venv/bin/activate'
alias y='yazi'
alias yori='aichat -r yori'
alias hconf='v /home/duck/.config/hypr/hyprland.conf'
alias bconf='v /home/duck/.bashrc'
alias kconf='v /home/duck/.config/kitty/kitty.conf'
alias tconf='v /home/duck/.tmux.conf'
alias downloads='cd ~/Downloads/ && ls -alsh'
alias ifconfig='ip -c a'
alias ga='git add'
alias gpl='git pull'
alias gps='git push'
alias gst='git status'
alias gsw='git switch'
alias kali='distrobox enter --root kali'
ssh() {
    ~/.local/bin/ssh-kitty "$@"
}

sshp() {
    SSH_KITTY_INTERACTIVE_AUTH=1 ~/.local/bin/ssh-kitty "$@"
}

sshraw() {
    SSH_KITTY_INTERACTIVE_AUTH=1 SSH_KITTY_NO_REMOTE_TMUX=1 ~/.local/bin/ssh-kitty "$@"
}

sshr() {
    command ssh "$@"
}
