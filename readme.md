# Dotfiles

Reproducible setup for a fresh (work-primary) Mac. One command stands up Homebrew,
packages, dotfiles, secrets (via 1Password), and macOS defaults.

## Bootstrap a fresh Mac

```bash
git clone https://github.com/Olivier-OG/.dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh
```

The first `git` call prompts to install the Xcode Command Line Tools — accept it.

### One-time 1Password setup

Secrets (cerm git identity, SSH public keys, Bryntum token) are pulled from the
`dotfiles` vault in 1Password at bootstrap time. Do this once in the 1Password app
before the secret step can run:

1. Sign in to 1Password
2. Settings → Security → enable **Touch ID**
3. Settings → Developer → **Integrate with 1Password CLI**
4. Settings → Developer → **Use the SSH Agent**
5. Settings → General → **Start at login**

If the vault isn't reachable yet, `bootstrap.sh` links everything else and stops at the
secret step with these instructions — finish the setup and re-run it.

## What `bootstrap.sh` does

In order, idempotent (safe to re-run):

1. Installs Homebrew
2. `brew bundle` from the [Brewfile](Brewfile)
3. Symlinks the plain dotfiles under [`home/`](home/) into `$HOME`
4. Renders the secret files (`*.tmpl`) from 1Password via `op inject`
5. Applies macOS defaults ([macos.sh](macos.sh))

## Layout

`home/` mirrors `$HOME`:

- **Non-`.tmpl` files are symlinked** — edit in place, `git commit` when you like.
- **`*.tmpl` files hold `op://` references** and are rendered to real files by `op inject`.
  Edit the `.tmpl` and re-run `bootstrap.sh` to re-render.

Top level: `Brewfile` (packages), `macos.sh` (system defaults), `bootstrap.sh` (orchestrator).

## Updating

- Plain dotfile: edit the symlinked file, then `git commit`.
- Secret template: edit `home/**/*.tmpl`, then `~/.dotfiles/bootstrap.sh` to re-render.
- Package: edit `Brewfile`, then `brew bundle --file=~/.dotfiles/Brewfile`.
