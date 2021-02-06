FZF_GIT_TOOLDIR=${FZF_GIT_TOOLDIR-${0:A:h}}

function fzf-git-branch() {
    out=$(fzfyml3 run $FZF_GIT_TOOLDIR/fzfyml/git-branch.yml "$*")
    if [[ -n "$out" ]]; then
        if echo "$out" | grep -q '^remotes/'; then
            remote_branch="${out#*/}"
            git checkout -b "${remote_branch#*/}" "$remote_branch"
        else
            git checkout "$out"
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

