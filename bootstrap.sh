#!/usr/bin/env bash
#
# Bootstrap a fresh (work-primary) Mac from this repo.
# Idempotent: safe to re-run.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES/home"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }

# 1. Homebrew ---------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Packages ---------------------------------------------------------------
log "Installing packages from Brewfile"
brew bundle install --file="$DOTFILES/Brewfile"

# 3. Link plain dotfiles; collect templates for step 4 ----------------------
log "Linking dotfiles into \$HOME"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

templates=""
while IFS= read -r -d '' src; do
  rel="${src#"$HOME_SRC"/}"
  case "$rel" in
    *.tmpl) templates="$templates$rel"$'\n'; continue ;;
  esac
  dest="$HOME/$rel"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  info "linked   ~/$rel"
done < <(find "$HOME_SRC" -type f -print0)

# 4. Render secret templates from 1Password ---------------------------------
log "Rendering secrets from 1Password"
if ! op vault list >/dev/null 2>&1; then
  cat <<'EOF'
    1Password CLI cannot read the vault yet.
    Complete the one-time 1Password setup, then re-run ./bootstrap.sh:
      1. Sign in to the 1Password app
      2. Settings > Security  > enable Touch ID
      3. Settings > Developer > Integrate with 1Password CLI
      4. Settings > Developer > Use the SSH Agent
      5. Settings > General   > Start at login
EOF
  exit 1
fi

printf '%s' "$templates" | while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  dest="$HOME/${rel%.tmpl}"
  mkdir -p "$(dirname "$dest")"
  rm -f "$dest"
  op inject -f -i "$HOME_SRC/$rel" -o "$dest"
  chmod 600 "$dest"
  info "rendered ~/${rel%.tmpl}"
done

# 5. macOS defaults ---------------------------------------------------------
log "Applying macOS defaults"
"$DOTFILES/macos.sh"

log "Done."
info "Restart your shell; log out/in for keyboard & Finder settings to fully apply."
