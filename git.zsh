FZF_GIT_TOOLDIR=${FZF_GIT_TOOLDIR-${0:A:h}}

function fzf-git-branch() {
    local query=""
    if [ $# -gt 0 ]; then
        if git branch | sed -e 's/^\s*\*//' | grep "^\s*$selected" >/dev/null 2>&1; then
            git checkout $1
            return
        else
            echo "No such branch: $1" >&2
            return 1
        fi
    fi
    local selected
    selected=$(git branch -a --color=always | fzf --no-sort --reverse --ansi --query="$query" | sed -e 's/^\s*\*\?\s\+//' -e 's/ .*$//')
    if grep '\S' <<< "$selected" >/dev/null 2>&1; then
        if [[ "$selected" =~ ^remotes/origin/ ]]; then
            local basename
            basename=$(sed -e 's/^remotes\/origin\///' <<< "$selected")
            if git branch | sed -e 's/^\s*\*//' | grep "^\s*$basename$" >/dev/null 2>&1; then
                git checkout $basename
            else
                git checkout -b $basename origin/$basename
            fi
        else
            git checkout $selected
        fi
    fi
}
alias gb='fzf-git-branch'

function fzf-git-log-widget() {
    local out
    out=$(fzfyml3 run $FZF_GIT_TOOLDIR/fzfyml/git-log.yml)
    if [[ -n "$out" ]]; then
        BUFFER+="$out"
        CURSOR+=${#out}
        zle redisplay
    fi
}
zle -N fzf-git-log-widget
bindkey "^g^l" fzf-git-log-widget

function fzf-git-reflog-widget() {
    local out
    out=$(fzfyml3 run $FZF_GIT_TOOLDIR/fzfyml/git-reflog.yml)
    if [[ -n "$out" ]]; then
        BUFFER+="$out"
        CURSOR+=${#out}
        zle redisplay
    fi
}
zle -N fzf-git-reflog-widget
bindkey "^g^r" fzf-git-reflog-widget

function fzf-git-status-widget() {
    local out
    out=$(fzfyml3 run $FZF_GIT_TOOLDIR/fzfyml/git-status.yml)
    if [[ -n "$out" ]]; then
        BUFFER+="$out"
        CURSOR=${#BUFFER}
        zle redisplay
        typeset -f zle-line-init >/dev/null && zle zle-line-init
    fi
}
zle -N fzf-git-status-widget
bindkey "^g^s" fzf-git-status-widget

