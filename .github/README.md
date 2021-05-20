<h1 align="center">
  <br>
  marksie1988 DotFiles
</h1>

<h4 align="center">DotFiles for developers.</h4>

<p align="center">
    <a href="https://github.com/marksie1988/dotfiles/commits/master">
    <img src="https://img.shields.io/github/last-commit/marksie1988/dotfiles.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub last commit">
    <a href="https://github.com/marksie1988/dotfiles/issues">
    <img src="https://img.shields.io/github/issues-raw/marksie1988/dotfiles.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub issues">
    <a href="https://github.com/marksie1988/dotfiles/pulls">
    <img src="https://img.shields.io/github/issues-pr-raw/marksie1988/dotfiles.svg?style=flat-square&logo=github&logoColor=white"
         alt="GitHub pull requests">
</p>

<p align="center">
  <a href="#about">About</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#author">Author</a> •
  <a href="#support">Support</a> •
  <a href="#donate">Donate</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

---

## About

<table>
<tr>
<td>

This repository contains dotfiles that I use within my development environments.

I utilise Fish as the shell and neovim as the text editor, I also have various plugins
that improve the visualisation of fish.

</td>
</tr>
</table>

## Configuration

In order to use these dotfiles:

Install a powerline patched font: [Nerd fonts](https://github.com/ryanoasis/nerd-fonts) Powerline-patched fonts ( I like Sauce Code Pro)

```sh
sudo apt install fish neovim peco
sh -c "$(wget -qO- https://raw.githubusercontent.com/marksie1988/dotfiles/master/install.sh)"
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jethrokuan/z
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
```

## Author

| [![TotalDebug](https://totaldebug.uk/assets/images/logo.png)](https://linkedin.com/in/marksie1988) 	|
|:-------------------------:     |
| **marksie1988 (Steven Marks)** |

## Support

Reach out to me at one of the following places:

- [Discord](https://discord.gg/6fmekudc8Q)
- [Issues](https://github.com/marksie1988/dotfiles/issues/new/choose)

## Donate

Please consider supporting this project by sponsoring, or just donating a little via [our sponsor page](https://github.com/sponsors/marksie1988)

## Credits
 - [craftzdog](https://github.com/craftzdog) Origional source for base dotfiles

## License

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-orange.svg?style=flat-square)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

- Copyright © [Total Debug](https://totaldebug.uk "Total Debug").
