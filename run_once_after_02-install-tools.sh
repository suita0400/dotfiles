#!/bin/bash
set -eu

echo "==> [4/4] mise 経由で Node.js, Neovim をインストール"
~/.local/bin/mise install -y

# Tmux Plugin Manager (TPM) のクローン
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
