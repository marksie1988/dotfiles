autoload -U compinit

if [ ! -d ~/.zsh/plugins/zsh-autosuggestions ]; then
    echo "Installing zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions >/dev/null 2>&1
else 
    git -C ~/.zsh/plugins/zsh-autosuggestions pull >/dev/null 2>&1
fi

if [ ! -d '~/.zsh/plugins/zsh-syntax-highlighting' ]; then
    echo "Installing zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting >/dev/null 2>&1
else 
    git -C ~/.zsh/plugins/zsh-syntax-highlighting pull >/dev/null 2>&1
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
