TOOLDIR=${TOOLDIR-${0:A:h}}

function __get_branch() {
  local cur_line
  cur_line=$(git branch | grep '^\s*\*' | strutil shift)
  if [[ "$cur_line" =~ rebasing ]]; then
    echo -n "${cur_line%)}" | sed 's/^.*rebasing//'
  else
    echo -n "${cur_line}"
  fi
}


function git-fetch() {
    local branch
    branch=$(__get_branch)
    git fetch 2>&1
    git diff $branch origin/$branch
}
alias gf='git-fetch'

if which fzf >/dev/null 2>&1; then
    function fzf-git-add() {
        local selected
        selected=($(unbuffer git status -s | fzf --no-sort --reverse --ansi --preview="$TOOLDIR/fzfyml/preview-git.sh {2..}" --preview-window=up:70% -m | strutil island -- -1))
        if grep '\S' <<< "$selected" >/dev/null 2>&1; then
            sed -e 's/\s\+/\n/g' -e 's/^/add /' <<< "$selected"
            git add $selected
        fi
    }
    alias ga='fzf-git-add'

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
        out=$(fzfyml3 run $TOOLDIR/fzfyml/git-log.yml)
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
        out=$(fzfyml3 run $TOOLDIR/fzfyml/git-reflog.yml)
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
        out=$(fzfyml3 run $TOOLDIR/fzfyml/git-status.yml)
        if [[ -n "$out" ]]; then
            BUFFER+="$out"
            CURSOR=${#BUFFER}
            zle redisplay
            typeset -f zle-line-init >/dev/null && zle zle-line-init
        fi
    }
    zle -N fzf-git-status-widget
    bindkey "^g^s" fzf-git-status-widget
else
    alias ga='git add'
    alias gb='git branch; git chechout'
fi

precmd_git() {
    git branch >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        local branch
        branch=$(__get_branch)
        if [[ "$branch[1]" = " " ]]; then
          branch=${branch# }
          PROMPT=$(strutil replace "%gb" " [32m($change$branch)[0m" <<< $PROMPT)
        else
          local change=""
          if git branch -a | grep "^\s*remotes/origin/$branch" >/dev/null 2>&1; then
              if [ $(git diff $branch origin/$branch | wc -l) -gt 0 ]; then
                  change+="!"
              fi
          else
              change+="?"
          fi
          if [ $(git status -s | wc -l) -gt 0 ]; then
              change+="+"
          fi
          PROMPT=$(strutil replace "%gb" " [35m($change$branch)[0m" <<< $PROMPT)
        fi
    else
        PROMPT=$(sed -e 's/%gb//' <<< $PROMPT)
    fi
}
