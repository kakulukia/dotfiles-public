# are we fast yet? - show benchmarks via: ZPROF=1 zsh -i -c exit
[ -z "$ZPROF" ] || zmodload zsh/zprof

# export FZF_DEFAULT_OPTS="--exact --no-sort --case=smart"
# export FZF_DEFAULT_COMMAND='fd --type d --hidden'
zstyle ':z4h:'                  auto-update            no
zstyle ':z4h:'                  auto-update-days       28
zstyle ':z4h:*'                 channel                testing
zstyle ':z4h:term-title:ssh'    precmd                 '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'
zstyle ':z4h:term-title:ssh'    preexec                '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:direnv'            enable                 yes
zstyle ':completion:*' verbose yes
  # zstyle ':z4h:command-not-found' to-file                "$TTY"
# zstyle ':z4h:'                  term-shell-integration yes
# zstyle ':z4h:'                  prompt-height          4

# zstyle ':z4h:'                  start-tmux             no
# zstyle ':z4h:'                  term-vresize           top
# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete'                   recurse-dirs       'yes'
# zstyle ':z4h:fzf-dir-history'                fzf-bindings       tab:repeat
# zstyle ':z4h:fzf-complete'                   fzf-bindings       tab:repeat
# zstyle ':z4h:cd-down'                        fzf-bindings       tab:repeat
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
zstyle ':completion:*' add-space false
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' completer _complete
# zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':z4h:*'    find-command fd
zstyle    ':z4h:ssh:*' enable           yes
zstyle    ':z4h:ssh:*' ssh-command      command ssh
zstyle    ':z4h:ssh:*' send-extra-files '~/.zshenv-private' '~/.zshrc-private' '~/.alias'
zstyle -e ':z4h:ssh:*' retrieve-history 'reply=($ZDOTDIR/.zsh_history.${(%):-%m}:$z4h_ssh_host)'
zstyle ':z4h:'                  propagate-cwd          yes
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd $realpath'


# zstyle ':z4h:*'    find-flags   -H -t f -E .git -E __pycache__
## das funktioniuert nur, wenn ich danach nicht ein level weiter will :/
# _files() {
#     local files=($(fd --hidden --follow --type=f --maxdepth 1))
#     compadd -a -f files
# }

# _cd() {
#     local dirs=($(fd --hidden --follow --type=d --maxdepth 1))
#     compadd -a -f dirs
# }

ZSH_PROMPT_STYLE=starship  # comment to use powerline10k
if [[ $ZSH_PROMPT_STYLE == "starship" && $+commands[starship] ]]; then
  # Disable z4h prompt (P10K)
  zstyle ':z4h:powerlevel10k' channel none
fi


# () {
#   local var proj dir
#   for var proj in P10K powerlevel10k ZSYH zsh-syntax-highlighting ZASUG zsh-autosuggestions; do
#     if [[ ${(P)var} == 0 ]]; then
#       zstyle ":z4h:$proj" channel none
#     elif [[ -e ${dir::=~/$proj} || -e ${dir::=~/zsh4humans/deps/$proj} ]]; then
#       zstyle ":z4h:$proj" channel command "zf_ln -s -- ${(q)dir} \$Z4H_PACKAGE_DIR"
#     fi
#   done
# }

# z4h install romkatv/archive romkatv/zsh-prompt-benchmark



# HIER GEHTS LOS
#######################################
z4h init || return


# # Set style for valid paths: white foreground, no underline
# ZSH_HIGHLIGHT_STYLES[path]=grey
# ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=11'
# # ZSH_HIGHLIGHT_STYLES[path_approx]='fg=9'


z4h bindkey z4h-accept-line         Enter
# z4h bindkey z4h-backward-kill-word  Ctrl+Backspace
# z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace
# z4h bindkey z4h-cd-back             Alt+Left
# z4h bindkey z4h-cd-forward          Alt+Right
# z4h bindkey z4h-cd-up               Alt+Up
z4h bindkey z4h-fzf-dir-history     Shift+Down
z4h bindkey z4h-exit                Ctrl+D
z4h bindkey z4h-quote-prev-zword    Alt+Q
z4h bindkey copy-prev-shell-word    Alt+C

setopt glob_dots magic_equal_subst no_multi_os no_local_loops
# setopt rm_star_silent rc_quotes glob_star_short

# ulimit -c $(((4 << 30) / 512))  # 4GB

fpath=($Z4H/romkatv/archive $fpath)
[[ -d ~/dotfiles/functions ]] && fpath=(~/dotfiles/functions $fpath)
autoload -Uz -- zmv archive lsarchive unarchive ~/dotfiles/functions/[^_]*(N:t)


export EDITOR=nvim
export PAGER=moar
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export SYSTEMD_LESS=moar
export MANOPT=--no-hyphenation
PROMPT_EOL_MARK='%F{red}⏎%f'

# merge history files for a combined history
() {
  local hist
  for hist in ~/.zsh_history*~$HISTFILE(N); do
    fc -RI $hist
  done
}

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }

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

# () {
#   local key keys=(
#     "^B"   "^D"   "^F"   "^N"   "^O"   "^P"   "^Q"   "^S"   "^T"   "^W"
#     "^X*"  "^X="  "^X?"  "^XC"  "^XG"  "^Xa"  "^Xc"  "^Xd"  "^Xe"  "^Xg"  "^Xh"  "^Xm"  "^Xn"
#     "^Xr"  "^Xs"  "^Xt"  "^Xu"  "^X~"  "^[ "  "^[!"  "^['"  "^[,"  "^[<"  "^[>"  "^[?"
#     "^[A"  "^[B"  "^[C"  "^[D"  "^[F"  "^[G"  "^[L"  "^[M"  "^[N"  "^[P"  "^[Q"  "^[S"  "^[T"
#     "^[U"  "^[W"  "^[_"  "^[a"  "^[b"  "^[d"  "^[f"  "^[g"  "^[l"  "^[n"  "^[p"  "^[q"  "^[s"
#     "^[t"  "^[u"  "^[w"  "^[y"  "^[z"  "^[|"  "^[~"  "^[^I" "^[^J" "^[^_" "^[\"" "^[\$" "^X^B"
#     "^X^F" "^X^J" "^X^K" "^X^N" "^X^O" "^X^R" "^X^U" "^X^X" "^[^D" "^[^G")
#   for key in $keys; do
#     bindkey $key z4h-do-nothing
#   done
# }

[[ -e ~/.ssh/control-master ]] || zf_mkdir -p -m 700 ~/.ssh/control-master
function skip-csi-sequence() {
  local key
  while read -sk key && (( $((#key)) < 0x40 || $((#key)) > 0x7E )); do
    # empty body
  done
}
zle -N skip-csi-sequence
bindkey '\e[' skip-csi-sequence

# TODO: When moving this to z4h, condition it on _z4h_zle.
setopt ignore_eof

if (( $+functions[toggle-dotfiles] )); then
  zle -N toggle-dotfiles
  z4h bindkey toggle-dotfiles Ctrl+P
fi

alias '$'=' '
alias '%'=' '
path=(. $path)


(( $+commands[rsync] )) && alias rsync='rsync -rz --info=FLIST,COPY,DEL,REMOVE,SKIP,SYMSAFE,MISC,NAME,PROGRESS,STATS'

# POSTEDIT=$'\n\e[2A'
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

# # Initialize fnm with caching
# if (( $+commands[fnm] )); then
#   # Check if cache file exists
#   if [[ ! -f ~/.cache/fnm-init.zsh ]]; then
#     echo "Creating fnm init cache..."
#     mkdir -p ~/.cache
#     fnm env --use-on-cd --shell zsh > ~/.cache/fnm-init.zsh
#   fi
#   # Load cached initialization with z4h
#   z4h source -c -- ~/.cache/fnm-init.zsh
# fi

# Lazy-init fnm on first Node-related command
for cmd in node npm npx yarn pm2; do
  eval "function $cmd {\
    unset -f node npm npx yarn pm2;\
    eval \"\$(fnm env --use-on-cd --shell zsh)\";\
    command $cmd \"\$@\";\
  }"
done

z4h source -c -- $ZDOTDIR/.alias
z4h source -c -- $ZDOTDIR/.zshrc-private
z4h compile -- $ZDOTDIR/{.zshenv,.zprofile,.zshrc}

# show benchmark results
[ -z "$ZPROF" ] || zprof
