i# dotfiles

WSL2 (Ubuntu/Debian系) 環境向けの dotfiles リポジトリです。  
[chezmoi](https://www.chezmoi.io/) を使用して設定ファイルの管理と環境構築の自動化を行っています。SSH秘密鍵などの機密情報は [age](https://github.com/FiloSottile/age) で暗号化して安全にGit管理しています。

## 特徴・主な構成ツール

- **ドットファイル管理**: `chezmoi` + `age` (暗号化) + 自動Git同期 (`autoCommit` / `autoPush`)
- **ランタイム・ツール管理**: `mise` (`config.toml` の変更を検知して自動インストール)
  - Neovim (`latest`)
  - Node.js (`26`)
- **シェル**: `bash` (管理ファイルの自動検知ラッパー・起動時の未反映チェック機能付き)
- **ターミナルマルチプレクサ**: `tmux` (+ TPM プラグイン自動導入)
- **システムパッケージ (apt)**: `age`, `build-essential`, `curl`, `git`, `tmux`, `unzip`, `ripgrep`, `fd-find`
- **WSL設定**: `/etc/wsl.conf` の自動構成・更新 (`etc_wsl.conf` の変更を検知して自動反映)
- **Git設定**: Windows側の Git Credential Manager と連携

## 事前準備

新しい環境でセットアップを行う前に、以下の準備が必要です。

1. **Windows 側への Git for Windows のインストール**  
   `.gitconfig` にて Windows 側の `git-credential-manager.exe` を参照するため、Windows 側に Git がインストールされている必要があります。
2. **復号用マスターキー (`key.txt`) の配置**  
   暗号化された SSH 秘密鍵などを復号するため、事前にパスワードマネージャー等からバックアップしてある秘密鍵（`key.txt`）を配置してください（`age` 本体はスクリプトにより自動インストールされます）。

```bash
mkdir -p ~/.config/chezmoi
vi ~/.config/chezmoi/key.txt # バックアップから復号キー(AGE-SECRET-KEY-...)を貼り付け
chmod 600 ~/.config/chezmoi/key.txt
```

## セットアップ手順 (Quick Start)

事前準備が完了したら、以下のワンライナーを実行して chezmoi のインストールと dotfiles の適用を一括で行います。

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply suita0400
```
*(※ネットワーク不調で止まる場合は `curl -4 -fsLS get.chezmoi.io | sh -s -- -b "$HOME/.local/bin" init --apply suita0400` を試してください)*

### 自動実行される処理 (`chezmoi apply` 時)
1. **システムセットアップ (`run_onchange_before_01-setup-system.sh`)**
   - `apt` による基本パッケージ（`age` 含む）のインストールと `fd` コマンドのシンボリックリンク作成
   - `etc_wsl.conf` から `/etc/wsl.conf` の生成・更新
   - `mise` のインストール
2. **設定ファイルの配置**
   - `.bashrc`, `.gitconfig`, `.tmux.conf`, `.ssh/`, `.config/` 等の展開および復号
3. **ツールインストール (`run_onchange_after_02-install-tools.sh`)**
   - `mise` 経由での Neovim, Node.js のインストール
   - Tmux Plugin Manager (TPM) のクローンとプラグインの自動インストール

## セットアップ後の作業

1. **WSL の再起動**  
   `/etc/wsl.conf` の設定（`systemd` の有効化など）を反映させるため、Windows 側のターミナル（PowerShell 等）から WSL を再起動してください。
   ```powershell
   wsl --shutdown
   ```

---

## 日常の運用コマンド

`autoCommit` と `autoPush` を有効化しているため、`chezmoi` 経由でファイルを変更・追加すると**自動的に Git Commit & Push まで完了**します。

### 1. 既存の管理ファイルを編集する
`.bashrc` にラッパー関数を設定しているため、普段通り `nvim` や `vim` で開くだけで自動的に `chezmoi edit --apply` に切り替わり、保存して閉じると本番反映と Git Push まで自動で行われます。

```bash
nvim ~/.bashrc
# または明示的に実行する場合
chezmoi edit --apply ~/.bashrc
```

### 2. 新しいファイルを管理対象に追加する
新しく作った設定ファイルを chezmoi の管理下に置きたい場合に使用します。

```bash
chezmoi add ~/.config/nvim/init.lua
```

### 3. 直接編集してしまったファイルを取り込む (`re-add`)
ラッパーを通さず（VSCodeや別ツール等で）ホームディレクトリのファイルを直接書き換えた場合、ターミナル起動時に警告が表示されます。以下のコマンドで変更を chezmoi 側へ吸い上げます。

```bash
# 差分を確認する
chezmoi diff

# すべての変更を chezmoi に取り込む（自動で Push されます）
chezmoi re-add

# 特定のファイルだけ取り込む場合
chezmoi re-add ~/.bashrc
```
*(※逆に、直接編集した内容を破棄して chezmoi 側の状態に戻したい場合は `chezmoi apply <ファイル名>` を実行します)*

### 4. 管理対象からファイルを外す (`forget`)
ホームディレクトリ上の実体ファイルは残したまま、chezmoi の管理（追跡）からだけ外したい場合に使用します。

```bash
chezmoi forget ~/.config/some_file
```

### 5. `mise` で管理するツール（言語・CLI）を追加・更新する
`~/.config/mise/config.toml` を開いてツールを追記し、保存して閉じるだけで、`run_onchange_` スクリプトが変更を検知して自動的に `mise install` を実行します。

```bash
nvim ~/.config/mise/config.toml
```

### 6. `/etc/wsl.conf` や初期構築スクリプトを編集する
ホームディレクトリ外の設定（`etc_wsl.conf`）や、`run_onchange_` スクリプト、`README.md` 自体を編集する場合は、`chezmoi cd` でリポジトリに直接入って作業します。

```bash
chezmoi cd

# 例: WSLの設定を変更する
nvim etc_wsl.conf
chezmoi apply # 変更が検知され、sudo cp で /etc/wsl.conf が更新されます

# 手動で Git へ反映して戻る（chezmoi cd 内での直接編集は自動コミットされないため）
git add .
git commit -m "Update wsl.conf"
git push
exit
```

### 7. 別環境での変更を取り込む / トラブルシューティング
別PCで更新した内容を取り込む場合や、表と裏で編集が競合してしまった場合のコマンドです。

```bash
# リモート（GitHub）の最新状態を取得して即座に環境に適用する
chezmoi update

# 現在の状態（未反映のファイルや未実行スクリプトの有無）を確認する
chezmoi status

# 表側と裏側の両方を編集してしまい競合したファイルをマージする
chezmoi merge ~/.bashrc
```

---

## `age` による機密ファイルの暗号化管理

SSHの秘密鍵やクラウドの認証情報（`~/.aws/credentials` など）、APIトークンを含むファイルは、`age` を使って暗号化した状態で GitHub に保存できます。

### 1. 新しい機密ファイルを暗号化して追加する (`--encrypt`)
`chezmoi add` に `--encrypt` オプションを付けるだけで、裏側のリポジトリには `encrypted_<ファイル名>.age` として暗号化されて保存され、自動で Push されます。

```bash
# 例: SSH秘密鍵を暗号化して追加（パーミッション600も自動で維持されます）
chezmoi add --encrypt ~/.ssh/id_ed25519

# 例: AWSの認証情報を暗号化して追加
chezmoi add --encrypt ~/.aws/credentials
```

### 2. 暗号化されているファイルを編集・閲覧する
すでに暗号化管理されているファイルも、通常のファイルと全く同じように編集できます。`chezmoi` が裏で自動的に復号してエディタで開き、保存して閉じると**自動的に再暗号化**して本番反映＆Pushしてくれます。

```bash
# ラッパー経由で開く（自動で復号して開きます）
nvim ~/.ssh/id_ed25519

# または明示的にコマンドで開く
chezmoi edit --apply ~/.ssh/id_ed25519
```

### 3. 直接書き換えた暗号化ファイルを取り込む
`ssh-keygen` 等で鍵を作り直したり、ホームディレクトリ上の機密ファイルを直接書き換えた場合も、一度 `--encrypt` で登録したファイルであれば通常の `re-add`（または再度 `add --encrypt`）で再暗号化して取り込めます。

```bash
chezmoi re-add ~/.ssh/id_ed25519
# または
chezmoi add --encrypt ~/.ssh/id_ed25519
```

### 4. （参考）`age` マスターキー（`key.txt`）の新規作成・ローテーション手順
もし将来マスターキー自体を新しく作り直したい場合は、以下の手順で行います。

```bash
# 1. 新しい鍵ペア（key.txt）を生成する
age-keygen -o ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt

# 2. 生成されたファイルの中身を確認し、公開鍵（public key: age1...）を控える
cat ~/.config/chezmoi/key.txt

# 3. chezmoiの設定ファイル（.chezmoi.toml.tmpl）の recipient に新しい公開鍵を設定する
chezmoi cd
nvim .chezmoi.toml.tmpl # recipient = "age1..." を書き換える
exit

# 4. 設定を反映し、機密ファイルを新しい鍵で再暗号化する
chezmoi init --apply
chezmoi add --encrypt ~/.ssh/id_ed25519
```
*(⚠️ 生成した `~/.config/chezmoi/key.txt` 自体は**絶対にGitリポジトリに含めず**、1PasswordやBitwardenなどのパスワードマネージャーに安全にバックアップしてください)*
