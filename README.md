# Takuya's dotfiles

**Warning**: Don’t blindly use my settings unless you know what that entails. Use at your own risk!

## Contents

- vim (NeoVim) config
  - Plugins are managed with [dein.vim](https://github.com/Shougo/dein.vim)
- tmux config
- git config
- fish config

## Vim setup

- [dein.nvim](https://github.com/Shougo/dein.vim) for managing plugins
- [coc.nvim](https://github.com/neoclide/coc.nvim) for autocompletion, imports and type definitions
- [defx.nvim](https://github.com/Shougo/defx.nvim) for exploring files
- [denite.nvim](https://github.com/Shougo/denite.nvim) for searching files
- [jiangmiao/auto-pairs](https://github.com/jiangmiao/auto-pairs) for inserting brackets, parens, quotes in pair

## Shell setup

- [Fish shell](https://fishshell.com/)
- [Fisher](https://github.com/jorgebucaran/fisher) - Plugin manager
- [Shellder](https://github.com/simnalamburt/shellder) - Shell theme
- [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) - Powerline-patched fonts
- [z for fish](https://github.com/jethrokuan/z) - Directory jumping
- [Exa](https://the.exa.website/) - `ls` replacement
- [ghq](https://github.com/x-motemen/ghq) - Local Git repository organizer
- [peco](https://github.com/peco/peco) - Interactive filtering

## How to use

Install the NerdFonts on your local machine

```
sudo apt install fish neovim exa peco git curl
git clone https://github.com/marksie1988/dotfiles-new.git
cd  ~/dotfiles-new/
cp -rf `ls -A | grep -v ".git"` ~/
chsh -s $(which fish)
fish
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jethrokuan/z
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
```

