source ~/.profile;clear;

fish_vi_key_bindings

#######################################
# Shortcuts | Abbreviations | Aliases #
#######################################
abbr b 'prevd'
# Projects 
abbr o 'composer'
abbr p 'cd ~/projects/'
abbr c 'cd ~/.config/'
abbr pf 'cd ~/projects/ && cd FonqResponsive/Fonq.Presentation.Frontend/'
abbr b7 'cd ~/projects/bouw7' 
abbr api 'cd ~/projects/web-api'
abbr migrate 'php yii migrate'
abbr rcache 'sudo sudo chown -R izanovic:izanovic /home/izanovic/projects/web-api/var/cache'
abbr hjs './bin/update-heimdall-js.sh http://web-api.julian.local.office.bouw7.nl/api/spec.json'
abbr cover 'http://web-api.julian.local.office.bouw7.nl/phpunit/index.html'
abbr lto 'cd ~/projects/LTO/LTO.UI.SeasonalWork'
abbr ltoapi 'cd ~/projects/LTO/LTO.UI.SeasonalWorkApi'
abbr rlto 'cd ~/projects/LTO/LTO.UI.SeasonalWorkApi && dotnet run'
abbr rfonq 'cd /mnt/c/_repositories/Fonq/Fonq.Presentation.Frontend && cmd.exe /c gulp watch && npm run watch:fonq && npm run build --colors=always && dotnet msbuild ../Fonq.sln'
# Git 
abbr g 'git'
abbr ga 'git add'
abbr gb 'git branch'
abbr gbd 'git branch -D'
abbr gbl 'git blame'
abbr gc 'git commit'
abbr gca 'git commit --amend'
abbr go 'git checkout'
abbr gom 'git checkout master'
abbr god 'git checkout develop'
abbr gb 'git checkout -b'
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

alias ngt="mono /usr/local/bin/nuget.exe"

function pp --wraps rm --description 'alias to project frontend folder'
    cd ~/projects/$argv && cd $argv.UI.Frontend
end
funcsave pp

export BAT_THEME="Darcula"

starship init fish | source
