# =============================================================================
# AIMS OS — default bash aliases for new user home directories
# =============================================================================
# Sourced automatically by Debian's stock /etc/skel/.bashrc whenever a
# new user is created (live session, Calamares install, `useradd`). We
# deliberately keep this small and uncontroversial — pure conveniences,
# nothing surprising.
#
# Users can override or extend by editing ~/.bash_aliases in their own
# home; nothing here is locked.
# =============================================================================

# ---- ls family --------------------------------------------------------------
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# ---- safety nets (interactive prompts before clobbering) --------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ---- apt shortcuts ----------------------------------------------------------
alias install='sudo apt install'
alias update='sudo apt update && sudo apt upgrade'
alias search='apt search'
alias show='apt show'

# ---- git shortcuts (most-used 5) --------------------------------------------
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -n 20'
alias gco='git checkout'
alias gcm='git commit -m'

# ---- scientific shells ------------------------------------------------------
alias py='python3'
alias ipy='ipython3'
alias jl='jupyter lab'
alias jn='jupyter notebook'

# ---- AIMS OS helpers --------------------------------------------------------
alias aims-version='cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d \"'
alias aims-welcome='cat ~/.config/aims/welcome.txt 2>/dev/null || echo "Welcome to AIMS OS — see /etc/motd"'
