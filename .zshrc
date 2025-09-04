# are we fast yet? - show benchmarks via: ZPROF=1 zsh -i -c exit
[ -z "$ZPROF" ] || zmodload zsh/zprof

# export FZF_DEFAULT_OPTS="--exact --no-sort --case=smart"
# export FZF_DEFAULT_COMMAND='fd --type d --hidden'
  # zstyle ':z4h:command-not-found' to-file                "$TTY"
# zstyle ':z4h:'                  term-shell-integration yes
# zstyle ':z4h:'                  prompt-height          4

# zstyle ':z4h:'                  term-vresize           top
# Recursively traverse directories when TAB-completing files.
# zstyle ':z4h:fzf-dir-history'                fzf-bindings       tab:repeat
# zstyle ':z4h:fzf-complete'                   fzf-bindings       tab:repeat
# zstyle ':z4h:cd-down'                        fzf-bindings       tab:repeat
zstyle ':z4h:'                               start-tmux         no
zstyle ':z4h:'                               auto-update        no
zstyle ':z4h:'                               auto-update-days   28
zstyle ':z4h:*'                              channel            testing
zstyle ':z4h:term-title:ssh'                 precmd             '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'
zstyle ':z4h:term-title:ssh'                 preexec            '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:direnv'                         enable             yes
zstyle ':completion:*'                       verbose yes
zstyle ':z4h:fzf-complete'                   recurse-dirs       'yes'
zstyle ':z4h:*'                              fzf-flags          --color=hl:11,hl+:11

zstyle ':zle:up-line-or-beginning-search'    leave-cursor       no
zstyle ':zle:down-line-or-beginning-search'  leave-cursor       no

zstyle ':completion:*'                       sort               false
zstyle ':completion:*'                       special-dirs       true
zstyle ':completion:*:ls:*'                  list-dirs-first    true
zstyle ':completion:*:ssh:argument-1:'       tag-order          hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order          hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts
zstyle ':z4h:*'                              fzf-command        fzf
zstyle ':completion:*'                       insert-slash       true
zstyle ':completion:*'                       add-space          false
zstyle ':completion:*'                       squeeze-slashes    true
zstyle ':completion:*'                       completer          _complete
zstyle ':completion:*'                       matcher-list       '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':z4h:*'                              find-command       fd
zstyle ':z4h:ssh:*'                          enable             yes
zstyle ':z4h:ssh:*'                          ssh-command        command ssh
zstyle ':z4h:ssh:*'                          send-extra-files   '~/.alias ~/.config/nvim/'
zstyle -e ':z4h:ssh:*'                       retrieve-history   'reply=($ZDOTDIR/.zsh_history.${(%):-%m}:$z4h_ssh_host)'
zstyle ':z4h:'                               propagate-cwd      yes
zstyle ':fzf-tab:complete:cd:*'              fzf-preview        'lsd $realpath'

ZSH_PROMPT_STYLE=starship  # comment to use powerline10k
if [[ $ZSH_PROMPT_STYLE == "starship" && $+commands[starship] ]]; then
  # Disable z4h prompt (P10K)
  zstyle ':z4h:powerlevel10k' channel none
fi


# HIER GEHTS LOS
#######################################
z4h init || return

z4h bindkey z4h-accept-line         Enter
z4h bindkey z4h-fzf-dir-history     Shift+Down
z4h bindkey z4h-exit                Ctrl+D
z4h bindkey z4h-quote-prev-zword    Alt+Q
z4h bindkey copy-prev-shell-word    Alt+C

setopt glob_dots magic_equal_subst no_multi_os no_local_loops

fpath=($Z4H/romkatv/archive $fpath)
[[ -d ~/dotfiles/functions ]] && fpath=(~/dotfiles/functions $fpath)
autoload -Uz -- zmv archive lsarchive unarchive ~/dotfiles/functions/[^_]*(N:t)


export EDITOR=nvim
export PAGER=moar
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export SYSTEMD_LESS=moar
export MANOPT=--no-hyphenation
export RIP_GRAVEYARD=$HOME/.graveyard
PROMPT_EOL_MARK='%F{red}⏎%f'

() {
  local hist
  for hist in ~/.zsh_history*~$HISTFILE(N); do
    fc -RI $hist
  done
}

compdef _directories md
compdef _default     open

# sync remote history
function z4h-ssh-configure() {
  (( z4h_ssh_enable )) || return 0
  local file
  for file in $ZDOTDIR/.zsh_history.*:$z4h_ssh_host(N); do
    (( $+z4h_ssh_send_files[$file] )) && continue
    z4h_ssh_send_files[$file]='"$ZDOTDIR"/'${file:t}
  done
}

[[ -e ~/.ssh/control-master ]] || zf_mkdir -p -m 700 ~/.ssh/control-master
function skip-csi-sequence() {
  local key
  while read -sk key && (( $((#key)) < 0x40 || $((#key)) > 0x7E )); do
    # empty body
  done
}

# zle -N skip-csi-sequence
# bindkey '\e[' skip-csi-sequence

# TODO: When moving this to z4h, condition it on _z4h_zle.
setopt ignore_eof

if (( $+functions[toggle-dotfiles] )); then
  zle -N toggle-dotfiles
  z4h bindkey toggle-dotfiles Ctrl+P
fi

# ignore copied symbols
alias '$'=' '
alias '%'=' '

# find every executable in the current pwd
path=(. $path)

z4h bindkey z4h-fzf-dir-history Alt+Down

# Check if starship is installed
if [[ $ZSH_PROMPT_STYLE == "starship" && $+commands[starship] ]]; then
  # Check if cache file exists
  if [[ ! -f ~/.cache/starship-init.zsh ]]; then
    echo "Creating Starship init cache..."
    mkdir -p ~/.cache
    starship init zsh > ~/.cache/starship-init.zsh
  fi

  # Load cached initialization with z4h
  z4h source -c -- ~/.cache/starship-init.zsh
fi

z4h source -c -- $ZDOTDIR/.alias
z4h source -c -- $ZDOTDIR/.zsh-profile  # for local changes that wont be synced
z4h source -c -- $ZDOTDIR/.zshrc-private
z4h compile -- $ZDOTDIR/{.zshenv,.zprofile,.zshrc,.alias,.zshrc-private}

# show benchmark results
[ -z "$ZPROF" ] || zprof

