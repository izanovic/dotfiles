# General
alias :q = exit
# NOTE: tunnelbrick has multiple statements → keep commented or convert to def if needed
# def tunnelbrick [] {
#     sudo ifconfig en0 down
#     sudo route flush
#     sudo ifconfig en0 up
# }

alias c = cd ~/.config
alias la = ls -la

def v [] { ^~/nvim-macos/bin/nvim }

# Project navigation
def pe [] { cd ~/projects/pro-dotenv-mono/ }
def ps [] { cd ~/projects/stichting-ambulance-wens/ }
def pwf [] { cd ~/projects/wgm-mijn/ }
def pwb [] { cd ~/projects/wgm-api/ }
def pr [] { cd ~/projects/ }

def p [name: string] {
  cd $"~/projects/($name)"
}

def fe [name: string] {
  cd $"~/projects/($name)"
  volta pin node@lts
  if (zellij list-sessions --short | lines | any { |l| $l == $name }) {
    zellij attach $name
  }
  zellij -l frontend-layout -s $name
}

def be [name: string] {
  cd $"~/projects/($name)"
  volta pin node@lts
  if (zellij list-sessions --short | lines | any { |l| $l == $name }) {
    zellij attach $name
  }
  zellij -l backend-layout -s $name
}

# Git
alias g = git
alias ga = git add

def gaa [] {
  rm swap-pane
  git add --all -- :!packages/investors/schema.json
}

def gb [] {
  git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format="%(refname:short) - %(contents:subject) (%(committerdate:relative))"
}

def gol [] {
  git checkout (git for-each-ref --count=1 --sort=-committerdate refs/heads/ --format="%(refname:short)")
}

alias gd = git diff
alias gbl = git blame
alias gca = git commit --amend
alias go = git checkout
alias gom = git checkout main
alias god = git checkout develop
alias gop = git checkout possible
alias gob = git checkout -b
alias gcp = git cherry-pick
alias gf = git fetch
alias gl = git log
alias gm = git merge
alias gmm = git merge main
alias gmp = git merge develop
alias gp = git push
alias gpu = git push --set-upstream origin HEAD
alias gpf = git push --force-with-lease
alias gpl = git pull
alias gr = git remote
alias grb = git rebase
alias gst = git status
alias gsta = git stash

def gc [] {
  let inside = (^git rev-parse --is-inside-work-tree | str trim)
  if $inside == "true" {
    let branch = (^git rev-parse --abbrev-ref HEAD | str trim)
    let suffix = if ($branch | str contains "/") { ($branch | split row "/") | last } else { $branch }
    git commit -n -m $"feat($suffix):"
  } else {
    print "Not inside a git repository."
  }
}

def gcf [] {
  let inside = (^git rev-parse --is-inside-work-tree | str trim)
  if $inside == "true" {
    let branch = (^git rev-parse --abbrev-ref HEAD | str trim)
    let suffix = if ($branch | str contains "/") { ($branch | split row "/") | last } else { $branch }
    git commit -n -m $"fix($suffix):"
  } else {
    print "Not inside a git repository."
  }
}

# Yarn
def yb [] { yarn build }

def yd [] {
  kill -9 (lsof -ti:3000)
  yarn dev --port=3000
}

def ya [] { yarn add }
def yr [] { yarn remove }

# Kitty
def cl [] {
  printf '\x1b[2J\x1b[3J\x1b[1;1H'
}
