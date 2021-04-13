# phenv shell completions

## Install completion scripts

### For zsh
The completion scripts have to be in a path that belongs to `$fpath`. Either link or copy them to an existing folder.
    If using oh-my-zsh you can do as follows:
    ```bash
    mkdir -p ~/.oh-my-zsh/completions
    chmod -R 755 ~/.oh-my-zsh/completions
    ln -s ./phenv.zsh ~/.oh-my-zsh/completions/_phenv.zsh
    ```
    Note that the leading underscore seems to be a convention. If completion doesn't work, add `autoload -U compinit && compinit` to your `.zshrc` (similar to [`zsh-completions`](https://github.com/zsh-users/zsh-completions/blob/master/README.md#oh-my-zsh)).
    If not using oh-my-zsh, you could link to `/usr/share/zsh/functions/Completion` (might require sudo), depending on the `$fpath` of your zsh installation.

### For fish
TBD

### For bash
TBD
