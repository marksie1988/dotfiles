autoload -U compinit

if [ -f '~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' ]; then
    echo "Installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
fi

if [ -f '~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ]; then
    echo "Installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highliting
fi

plugins=(
    zsh-autosuggestions
    zsh-syntax-highlighting
)

for plugin ($plugins); do
    plugin_path=~/.zsh/plugins/$plugin/$plugin.zsh
    if [ -f $plugin_path ]; then
        fpath=(~/.zsh/plugins/$plugin $fpath)
        source $plugin_path
    else
        echo "Plugin $plugin not found at $plugin_path"
    fi
done

compinit
