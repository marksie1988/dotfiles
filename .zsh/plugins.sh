autoload -U compinit

plugins=(
    zsh-autosuggestions
)

for plugin ($plugins); do
    fpath=(~/.zsh/plugins/$plugin $fpath)
    source ~/.zsh/plugins/$plugin/$plugin.zsh
done

compinit
