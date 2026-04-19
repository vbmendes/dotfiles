# GitHub SSH Setup

Interactive script to configure SSH keys for GitHub authentication and commit signing.

## What it does

1. Generates an `ed25519` SSH key
2. Adds the key to the SSH agent
3. Guides you through adding the key to GitHub as an **Authentication Key**
4. Guides you through adding the same key as a **Signing Key**
5. Configures Git to automatically sign all commits (and optionally tags)
6. Sets up a local `allowed_signers` file for signature verification
7. Runs a test signed commit to confirm everything works

## Usage

```bash
./setup_github_ssh.sh
```

The script is interactive — it will prompt you for your email address and key path, then walk you through each step, opening GitHub in your browser at the right moments.

## Prerequisites

- `git` installed and accessible in `$PATH`
- A GitHub account
- `ssh-keygen` available (standard on macOS and most Linux distros)

## Result

After the script completes, every new commit will be automatically signed. Signed commits show a **Verified** badge on GitHub.

The following globals are set in `~/.gitconfig`:

```ini
[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.config/git/allowed_signers

[user]
    signingkey = ~/.ssh/id_ed25519.pub

[commit]
    gpgsign = true

[tag]
    gpgsign = true   # only if you opted in
```
