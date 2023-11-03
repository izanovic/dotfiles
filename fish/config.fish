source ~/.profile
clear

fish_vi_key_bindings

#######################################
# Shortcuts | Abbreviations | Aliases #
#######################################
# Projects 
abbr rcache 'sudo sudo chown -R izanovic:izanovic /home/izanovic/projects/web-api/var/cache'

set -x PATH /Users/julian/projects/docker-devtools/bin $PATH
set -gx PATH "~/.tmuxifier/bin" $PATH
set -gx PATH ~/nvim-macos/bin/ $PATH
set -gx EDITOR nvim
set PATH $PATH $GOPATH/bin

# General
abbr :q exit
abbr tunnelbrick 'sudo ifconfig en0 down && sudo route flush && sudo ifconfig en0 up &&'
alias v '~/nvim-macos/bin/nvim'

# Mogelijk
abbr is 'ionic serve'
abbr andr 'ionic cap run android'
abbr fios 'perl -i -pe\'s/PLACEHOLDER_BUILD_NUMBER/$(CLI_BUILD_NUMBER)/g\' \'/Users/julian/Projects/mogelijk/mogelijk-app/ios/App/App/Info.plist\''
abbr ios 'perl -i -pe\'s/$(CLI_BUILD_NUMBER)/PLACEHOLDER_BUILD_NUMBER/g\' \'/Users/julian/Projects/mogelijk/mogelijk-app/ios/App/App/Info.plist\' && ionic cap run ios'

# Projects

abbr pe 'cd ~/projects/pro-dotenv-mono/'
abbr ps 'cd ~/projects/stichting-ambulance-wens/'
abbr pwf 'cd ~/projects/wgm-mijn/'
abbr pwb 'cd ~/projects/wgm-api/'
abbr fe 'cd ~/projects/pro-dotenv-mono/nuxt/src/'
abbr be 'cd ~/projects/pro-dotenv-mono/api/src/'


# Git 
abbr g git
abbr ga 'git add'
abbr gaa 'rm swap-pane; git add --all -- :!packages/investors/schema.json'
abbr gb "git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format='%(color:blue)%(refname:short)%(color: white) - %(contents:subject) %(color:green)(%(committerdate:relative))'"
abbr gol "git checkout (git for-each-ref --count=1 --sort=-committerdate refs/heads/ --format='%(refname:short)')"
abbr gd 'git branch -D'
abbr gbl 'git blame'
abbr gc 'git commit -n -m "feat("(git branch --show-current | cut -d/ -f2-)"):'
abbr gcf 'git commit -n -m "fix("(git branch --show-current | cut -d/ -f2-)"):'
abbr gca 'git commit --amend'
abbr go 'git checkout'
abbr gom 'git checkout master'
abbr god 'git checkout develop'
abbr gop 'git checkout possible'
abbr gob 'git checkout -b'
abbr gcp 'git cherry-pick'
abbr gd 'git diff'
abbr gf 'git fetch'
abbr gl 'git log'
abbr gm 'git merge'
abbr gmm 'git merge master'
abbr gmp 'git merge develop'
abbr gp 'git push'
abbr gpu 'git push --set-upstream origin HEAD'
abbr gpf 'git push --force-with-lease'
abbr gpl 'git pull'
abbr gr 'git remote'
abbr grb 'git rebase'
abbr gst 'git status'
abbr gsta 'git stash'

# Yarn
abbr yb 'yarn build'
abbr yd 'kill -9 (lsof -ti:3000); yarn dev --port=3000'
abbr ya 'yarn add'
abbr yr 'yarn remove'

# Kitty
abbr cl 'printf "\033[2J\033[3J\033[1;1H"'

alias note=" ~/.joplin-bin/lib/node_modules/joplin/main.js"
alias ngt="mono /usr/local/bin/nuget.exe"

starship init fish | source

source /Users/julian/.docker/init-fish.sh || true # Added by Docker Desktop
