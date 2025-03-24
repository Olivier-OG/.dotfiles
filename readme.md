# Dotfiles

TODO: Create a script to execute these commands

Start by cloning the repository:

```bash
git clone git@github.com:Olivier-OG/.dotfiles.git
```

Then, install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Use the Brewfile to install all the necessary packages:

```bash
brew bundle install --file=.dotfiles/Brewfile
```

Finally, create symlinks to the dotfiles:

```bash
ln -s .dotfiles/.zshrc .zshrc
ln -s .dotfiles/.zprofile .zprofile
ln -s .dotfiles/.gitconfig .gitconfig
ln -s .dotfiles/.gitignore .gitignore
```
