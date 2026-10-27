# dotfiles

WSL2 (Ubuntu/Debian系) 環境向けの dotfiles リポジトリです。  
[chezmoi](https://www.chezmoi.io/) を使用して設定ファイルの管理と環境構築の自動化を行っています。SSH秘密鍵などの機密情報は [age](https://github.com/FiloSottile/age) で暗号化して管理しています。

## 特徴・主な構成ツール

- **ドットファイル管理**: `chezmoi` + `age` (暗号化) + 自動Git同期 (`autoCommit` / `autoPush`)
- **ランタイム・ツール管理**: `mise` (`config.toml` の変更を検知して自動インストール)
  - Neovim (`latest`)
  - Node.js (`26`)
- **シェル**: `bash` (管理ファイルの自動検知ラッパー・未反映チェック機能付き)
- **ターミナルマルチプレクサ**: `tmux` (+ TPM プラグイン自動導入)
- **システムパッケージ (apt)**: `age`, `build-essential`, `curl`, `git`, `tmux`, `unzip`, `ripgrep`, `fd-find`
- **WSL設定**: `/etc/wsl.conf` の自動構成・更新 (`etc_wsl.conf` の変更を検知して自動反映)
- **Git設定**: Windows側の Git Credential Manager と連携

## 事前準備

新しい環境でセットアップを行う前に、以下の準備が必要です。

1. **Windows 側への Git for Windows のインストール**  
   `.gitconfig` にて Windows 側の `git-credential-manager.exe` を参照するため、Windows 側に Git がインストールされている必要があります。
2. **復号用マスターキー (`key.txt`) の配置**  
   暗号化された SSH 秘密鍵を復号するため、事前に秘密鍵（`key.txt`）を配置してください（`age` 本体はスクリプトにより自動インストールされます）。

```bash
mkdir -p ~/.config/chezmoi
vi ~/.config/chezmoi/key.txt # バックアップから復号キーを貼り付け
chmod 600 ~/.config/chezmoi/key.txt
