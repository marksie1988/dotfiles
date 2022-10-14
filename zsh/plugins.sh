autoload -U compinit

plugins=(
    zsh-autosuggestions
)

for plugin ($plugins); do
    fpath=(./plugins/$plugin $fpath)
    source ./plugins/$plugin/$plugin.zsh
done

compinit
