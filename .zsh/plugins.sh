autoload -U compinit

# Parallel plugin management
manage_plugin() {
    local name=$1
    local url=$2
    local path=~/.zsh/plugins/$name
    
    if [ ! -d "$path" ]; then
        echo "Cloning $name..."
        git clone --depth 1 "$url" "$path" >/dev/null 2>&1
    else
        # Background update
        (git -C "$path" pull >/dev/null 2>&1 &)
    fi
}

# Define plugins
# Using standard array for compatibility if associative arrays cause issues in some zsh versions
# though associative arrays are standard in modern zsh.
# The error "bad subscript" often occurs if the shell isn't in zsh mode or syntax is slightly off.
typeset -A plugin_urls
plugin_urls=(
    zsh-autosuggestions "https://github.com/zsh-users/zsh-autosuggestions"
    zsh-syntax-highlighting "https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

# Install/Update plugins in parallel
for name in ${(k)plugin_urls}; do
    manage_plugin "$name" "${plugin_urls[$name]}" &
done
wait

# Load plugins
for name in ${(k)plugin_urls}; do
    plugin_path=~/.zsh/plugins/$name/$name.zsh
    if [ -f "$plugin_path" ]; then
        fpath=(~/.zsh/plugins/$name $fpath)
        source "$plugin_path"
    fi
done

compinit
