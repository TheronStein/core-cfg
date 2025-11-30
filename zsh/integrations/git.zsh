# ~/.core/zsh/modules/git.zsh
#
# Git Integration - comprehensive aliases, functions, and workflow helpers

#=============================================================================
# CHECK FOR GIT
#=============================================================================
(($+commands[git])) || return 0

#=============================================================================
# ENVIRONMENT
#=============================================================================
export GIT_PAGER="delta" # Use delta for diffs (if available)

#=============================================================================
# BASE ALIASES
#=============================================================================
alias g='git'
alias gs='git status -sb'
alias gst='git status'

#=============================================================================
# ADD/STAGE
#=============================================================================
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gai='git add --interactive'
alias gau='git add --update'

#=============================================================================
# COMMIT
#=============================================================================
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcam='git commit -am'
alias gcf='git commit --fixup'
alias gcs='git commit --squash'
alias gcv='git commit -v'
alias gcw='git commit -m "WIP"'
alias gcempty='git commit --allow-empty -m'

#=============================================================================
# BRANCH
#=============================================================================
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbm='git branch -m'
alias gbc='git branch --contains'
alias gbr='git branch -r'
alias gbl='git branch -l'
alias gbv='git branch -vv'

#=============================================================================
# CHECKOUT/SWITCH
#=============================================================================
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout main'
alias gcod='git checkout develop'
alias gco-='git checkout -'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch main'
alias gswd='git switch develop'
alias grs='git restore'
alias grss='git restore --staged'

#=============================================================================
# DIFF
#=============================================================================
alias gd='git diff'
alias gds='git diff --staged'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'
alias gdt='git difftool'
alias gdh='git diff HEAD'
alias gd1='git diff HEAD~1'
alias gd2='git diff HEAD~2'
alias gdn='git diff --name-only'
alias gdns='git diff --name-status'

#=============================================================================
# LOG
#=============================================================================
alias gl='git log --oneline -20'
alias gla='git log --oneline --all'
alias glg='git log --graph --oneline --all'
alias gll='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --all'
alias gls='git log --stat'
alias glp='git log -p'
alias glf='git log --follow -p --'
alias gl1='git log --oneline -1'
alias glast='git log -1 HEAD --stat'
alias gcount='git shortlog -sn'

#=============================================================================
# PUSH/PULL
#=============================================================================
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpff='git push --force'
alias gpu='git push -u origin HEAD'
alias gpt='git push --tags'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gpla='git pull --all'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gfp='git fetch --prune'

#=============================================================================
# REBASE
#=============================================================================
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbm='git rebase main'
alias grbd='git rebase develop'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbs='git rebase --skip'
alias grbo='git rebase --onto'

#=============================================================================
# MERGE
#=============================================================================
alias gm='git merge'
alias gmm='git merge main'
alias gmd='git merge develop'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gmn='git merge --no-ff'

#=============================================================================
# RESET
#=============================================================================
alias grst='git reset'
alias grsth='git reset --hard'
alias grsts='git reset --soft'
alias grstm='git reset --mixed'
alias grst1='git reset HEAD~1'
alias grst2='git reset HEAD~2'
alias gundo='git reset --soft HEAD~1'

#=============================================================================
# STASH
#=============================================================================
alias gss='git stash save'
alias gsp='git stash pop'
alias gsl='git stash list'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsc='git stash clear'
alias gsshow='git stash show -p'

#=============================================================================
# CHERRY-PICK
#=============================================================================
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcpn='git cherry-pick --no-commit'

#=============================================================================
# REMOTE
#=============================================================================
alias gr='git remote'
alias grv='git remote -v'
alias gra='git remote add'
alias grrm='git remote remove'
alias grset='git remote set-url'

#=============================================================================
# TAG
#=============================================================================
alias gt='git tag'
alias gtl='git tag -l'
alias gta='git tag -a'
alias gtd='git tag -d'
alias gtv='git tag -v'

#=============================================================================
# WORKTREE
#=============================================================================
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'
alias gwtp='git worktree prune'

#=============================================================================
# CLEAN
#=============================================================================
alias gcln='git clean -fd'
alias gclnn='git clean -fdn' # Dry run
alias gclnx='git clean -fdx' # Include ignored

#=============================================================================
# BISECT
#=============================================================================
alias gbs='git bisect'
alias gbss='git bisect start'
alias gbsg='git bisect good'
alias gbsb='git bisect bad'
alias gbsr='git bisect reset'
alias gbsl='git bisect log'

#=============================================================================
# SUBMODULE
#=============================================================================
alias gsm='git submodule'
alias gsmi='git submodule init'
alias gsmu='git submodule update'
alias gsma='git submodule add'
alias gsms='git submodule status'
alias gsmf='git submodule foreach'

#=============================================================================
# BLAME
#=============================================================================
alias gbl='git blame'
alias gblc='git blame --color-by-age --color-lines'

#=============================================================================
# FUNCTIONS
#=============================================================================

# Git root directory
function groot() {
  local root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$root" ]]; then
    cd "$root"
  else
    echo "Not in a git repository"
    return 1
  fi
}

# Quick commit with message
function gcq() {
  git add -A && git commit -m "${1:-Quick commit}"
}

# Amend with all changes
function gamend() {
  git add -A && git commit --amend --no-edit
}

# Interactive branch delete
function gbdf() {
  local branches
  branches=$(git branch | grep -v '^\*' \
    | fzf --multi --header '╭─ Select branches to delete ─╮')

  if [[ -n "$branches" ]]; then
    echo "$branches" | xargs -r git branch -d
  fi
}

# Interactive checkout
function gcof() {
  local branch
  branch=$(git branch --all | grep -v HEAD \
    | fzf --header '╭─ Select branch ─╮' \
      --preview 'git log --oneline --graph -20 $(echo {} | sed "s/.* //" | sed "s#remotes/origin/##")' \
    | sed 's/.* //' | sed 's#remotes/origin/##')

  [[ -n "$branch" ]] && git checkout "$branch"
}

# Interactive commit selection
function gcpf() {
  local commit
  commit=$(git log --oneline --all \
    | fzf --header '╭─ Select commit ─╮' \
      --preview 'git show --color=always $(echo {} | cut -d" " -f1)' \
    | cut -d' ' -f1)

  [[ -n "$commit" ]] && git cherry-pick "$commit"
}

# Interactive stash
function gssf() {
  local stash
  stash=$(git stash list \
    | fzf --header '╭─ Select stash ─╮' \
      --preview 'git stash show -p $(echo {} | cut -d: -f1)' \
    | cut -d: -f1)

  [[ -n "$stash" ]] && git stash pop "$stash"
}

# Git log with file
function glf() {
  git log --follow -p -- "$1"
}

# Show commit details
function gshow() {
  local commit="${1:-HEAD}"
  git show "$commit" --stat
}

# Git diff with file selector
function gdf() {
  local file
  file=$(git diff --name-only \
    | fzf --header '╭─ Modified files ─╮' \
      --preview 'git diff --color=always -- {}')

  [[ -n "$file" ]] && git diff -- "$file"
}

# Clean merged branches
function gbclean() {
  git branch --merged | grep -v '^\*\|main\|master\|develop' | xargs -r git branch -d
  echo "Cleaned merged branches"
}

# Prune remote tracking branches
function gbprune() {
  git remote prune origin
  echo "Pruned remote tracking branches"
}

# Git stats
function gstats() {
  echo "╭─ Git Repository Statistics ─╮"
  echo "  Commits: $(git rev-list --count HEAD)"
  echo "  Branches: $(git branch | wc -l)"
  echo "  Tags: $(git tag | wc -l)"
  echo "  Contributors: $(git shortlog -sn | wc -l)"
  echo "  First commit: $(git log --reverse --format=%ci | head -1)"
  echo "  Last commit: $(git log -1 --format=%ci)"
  echo "╰─────────────────────────────╯"
}

# List contributors
function gcontrib() {
  git shortlog -sn --all "$@"
}

# Git open in browser
function gopen() {
  local url=$(git remote get-url origin 2>/dev/null \
    | sed 's/git@/https:\/\//' \
    | sed 's/\.git$//' \
    | sed 's/\.com:/.com\//')

  if [[ -n "$url" ]]; then
    xdg-open "$url" 2>/dev/null || open "$url" 2>/dev/null
  else
    echo "No remote found"
    return 1
  fi
}

# Git ignore generator
function gignore() {
  local types="$*"
  if [[ -z "$types" ]]; then
    curl -sL "https://www.toptal.com/developers/gitignore/api/list" | tr ',' '\n'
  else
    curl -sL "https://www.toptal.com/developers/gitignore/api/$types"
  fi
}

# Create PR branch
function gpr() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    # echo "Usage: gpr <branch-name>"
    return 1
  fi
  git checkout -b "$branch"
  git push -u origin "$branch"
}

# Sync fork with upstream
function gsync() {
  local branch="${1:-main}"
  git fetch upstream
  git checkout "$branch"
  git merge upstream/"$branch"
  git push origin "$branch"
}

# Interactive rebase with fixup
function gfix() {
  local commit
  commit=$(git log --oneline -20 \
    | fzf --header '╭─ Select commit to fixup ─╮' \
    | cut -d' ' -f1)

  if [[ -n "$commit" ]]; then
    git commit --fixup="$commit"
    git rebase -i --autosquash "$commit"~1
  fi
}

# WIP commit and push
function gwip() {
  git add -A
  git commit -m "WIP: ${1:-work in progress}"
}

# Undo WIP
function gunwip() {
  if git log -1 --format=%s | grep -q "^WIP:"; then
    git reset --soft HEAD~1
    echo "WIP commit undone"
  else
    echo "Last commit is not a WIP"
  fi
}
