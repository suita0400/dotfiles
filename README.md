# dotfiles

WSL2 (Ubuntu/Debian系) 環境向けの dotfiles リポジトリです。  
[chezmoi](https://www.chezmoi.io/) を使用して設定ファイルの管理と環境構築の自動化を行っています。SSH秘密鍵などの機密情報は [age](https://github.com/FiloSottile/age) で暗号化して管理しています。

## 特徴・主な構成ツール

- **ドットファイル管理**: `chezmoi` + `age` (暗号化)
- **ランタイム・ツール管理**: `mise`
  - Neovim (`latest`)
  - Node.js (`26`)
- **シェル**: `bash`
- **ターミナルマルチプレクサ**: `tmux` (+ TPM)
- **システムパッケージ (apt)**: `build-essential`, `curl`, `git`, `tmux`, `unzip`, `ripgrep`, `fd-find`
- **WSL設定**: `/etc/wsl.conf` の自動構成 (`systemd` 有効化、マウントオプション設定など)
- **Git設定**: Windows側の Git Credential Manager と連携

## 事前準備

新しい環境でセットアップを行う前に、以下の準備が必要です。

1. **Windows 側への Git for Windows のインストール**  
   `.gitconfig` にて Windows 側の `git-credential-manager.exe` を参照するため、Windows 側に Git がインストールされている必要があります。
2. **`age` パッケージのインストールとマスターキーの配置**  
   暗号化された SSH 秘密鍵を復号するため、事前に `age` のインストールと秘密鍵（`key.txt`）の配置を行ってください。

```bash
# age のインストール
sudo apt update && sudo apt install -y age

# 復号用キーの配置
mkdir -p ~/.config/chezmoi
vi ~/.config/chezmoi/key.txt # バックアップから復号キーを貼り付け
chmod 600 ~/.config/chezmoi/key.txt
```

## セットアップ手順 (Quick Start)

事前準備が完了したら、以下のワンライナーを実行して chezmoi のインストールと dotfiles の適用を一括で行います。

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply suita0400
```
*(※リポジトリ名が `dotfiles` 以外の場合は、`suita0400/<リポジトリ名>` を指定してください)*

### 自動実行される処理 (`chezmoi apply` 時)
1. **システムセットアップ (`run_once_before_01-setup-system.sh`)**
   - `apt` による基本パッケージのインストールと `fd` コマンドのシンボリックリンク作成
   - `/etc/wsl.conf` の生成
   - `mise` のインストール
2. **設定ファイルの配置**
   - `.bashrc`, `.gitconfig`, `.tmux.conf`, `.ssh/`, `.config/` 等の展開および復号
3. **ツールインストール (`run_once_after_02-install-tools.sh`)**
   - `mise` 経由での Neovim, Node.js のインストール
   - Tmux Plugin Manager (TPM) のクローン

## セットアップ後の作業

1. **WSL の再起動**  
   `/etc/wsl.conf` の設定（`systemd` の有効化など）を反映させるため、Windows 側のターミナル（PowerShell 等）から WSL を再起動してください。
   ```powershell
   wsl --shutdown
   ```
2. **シェルの再読み込み（再起動しない場合）**
   ```bash
   source ~/.bashrc
   ```
3. **Tmux プラグインのインストール**  
   `tmux` を起動し、プレフィックスキー（`Ctrl+t`）を押した後に `I`（Shift + i）を押してプラグインをインストールしてください。

## 日常の運用コマンド

- **設定ファイルの編集**:
  ```bash
  chezmoi edit ~/.bashrc
  ```
- **変更内容の確認・適用**:
  ```bash
  chezmoi diff
  chezmoi apply
  ```
- **新規ファイルの追加**:
  ```bash
  chezmoi add ~/.config/nvim/init.lua
  # 暗号化して追加する場合
  chezmoi add --encrypt ~/.ssh/id_ed25519
  ```
- **リポジトリへのプッシュ**:
  ```bash
  chezmoi cd
  git add .
  git commit -m "Update dotfiles"
  git push
  ```
