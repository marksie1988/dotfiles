#!/bin/zsh

# SSH and GPG Key Management

echo "Checking SSH keys..."
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  echo -n "No Ed25519 SSH key found. Generate one? (y/n) "
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ssh-keygen -t ed25519 -C "$(hostname)"
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo "SSH key generated. Add this public key to your GitHub/GitLab account:"
    cat "$HOME/.ssh/id_ed25519.pub"
  fi
else
  echo "SSH key id_ed25519 already exists."
fi

echo "Checking SSH commit signing..."
signers_file="$HOME/.ssh/allowed_signers"
signer_email="$(git config --global user.email)"
if [[ -f "$HOME/.ssh/id_ed25519.pub" && -n "$signer_email" ]]; then
  signer_line="$signer_email $(cut -d' ' -f1,2 "$HOME/.ssh/id_ed25519.pub")"
  touch "$signers_file"
  if ! grep -qxF "$signer_line" "$signers_file"; then
    echo "$signer_line" >>"$signers_file"
    echo "Added $signer_email to $signers_file."
  else
    echo "Commit signer already present in $signers_file."
  fi
  echo "Add id_ed25519.pub to GitHub as a Signing Key (Settings > SSH and GPG keys) so commits show as verified."
else
  echo "Skipping commit signing setup: missing SSH public key or git user.email."
fi

echo "Checking GPG keys..."
if ! gpg --list-secret-keys >/dev/null 2>&1; then
  echo -n "No GPG keys found. Generate one? (y/n) "
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    gpg --full-generate-key
  fi
else
  echo "GPG keys found."
fi
