# Defined in /home/jf/.config/fish/config.fish @ line 54
function pp --wraps=rm --description 'alias to project frontend folder'
    cd ~/projects/$argv && cd $argv.UI.Frontend
end
