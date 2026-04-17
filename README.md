# zenn-post — Claude Code Plugin

Claude Code から Zenn と dev.to に記事を投稿するスキルです。

「記事公開して」と言うだけで、Notion のページや指定したテーマをもとに記事を書いて **Zenn（日本語）と dev.to（英訳）の両方に同時公開**します。

## できること

- Notion ページの内容を Zenn 記事に変換して投稿
- テーマを口頭で伝えるだけで記事を執筆・公開
- Zenn 公開と同時に英訳して dev.to にも投稿
- Mermaid 図を自動で PNG 変換（外部サービス不要・ローカル完結）
- 公開前にプレビューして確認 → OK で `git push` まで自動実行

## 使い方

```
「このNotionページをZennに上げて」
「記事公開して」          ← Zenn + dev.to 両方に投稿
「Zennだけに投稿して」    ← Zenn のみ
```

## インストール

### 前提

- [Claude Code](https://claude.ai/code) がインストール済み
- Zenn アカウントと zenn-content リポジトリが GitHub に存在すること（**public** リポジトリ）
  - 参考: [ZennとGitHubリポジトリを連携する](https://zenn.dev/zenn/articles/connect-to-github)
- dev.to アカウントと API キー（dev.to → Settings → Extensions → DEV API Keys）

### 手順

**1. このリポジトリをクローン**

```bash
git clone https://github.com/bokuno-studio/zenn-post-cc-plugin ~/.claude/plugins/zenn-post
```

**2. SKILL.md の環境情報を書き換える**

`skills/zenn-post/SKILL.md` の「環境情報」セクションを自分の環境に合わせて編集する。

```
- リポジトリ: `/path/to/your/zenn-content`  ← 自分のパスに変更
- GitHub: `your-github-username/zenn-content`  ← 自分のリポジトリに変更
- Zenn: `https://zenn.dev/your_username`  ← 自分のURLに変更
```

**3. dev.to API キーを設定する**

```bash
echo "DEVTO_API_KEY=your_api_key_here" > ~/.claude/plugins/zenn-post/.env
echo ".env" >> ~/.claude/plugins/zenn-post/.gitignore
```

**4. Claude Code のプラグインマーケットプレイスに登録**

```bash
claude plugin marketplace add ~/.claude/plugins/zenn-post
claude plugin install zenn-post
```

## Mermaid 図の扱いについて

dev.to は Mermaid をレンダリングしないため、このスキルは自動的に以下を行います：

1. `npx @mermaid-js/mermaid-cli` で Mermaid コードを PNG に変換（ローカル完結）
2. PNG を zenn-content の `images/` ディレクトリに保存して push
3. dev.to 記事内の mermaid ブロックを `![図](raw.githubusercontent.com/...)` に置き換え

## ライセンス

MIT

---

## 改定履歴

### v0.2.0 (2026-04-17)
- dev.to への同時投稿機能を追加
- 「記事公開して」で Zenn + dev.to 両方に投稿するよう変更
- Mermaid 図の自動 PNG 変換（`mermaid-cli` 使用）を追加
- `.env` による dev.to API キー管理を追加
- zenn-content リポジトリを画像ホスティングに活用する仕組みを追加

### v0.1.0 (2026-04-15)
- 初回リリース
- Zenn への記事投稿（Notion → Zenn）
- `published: true` にする前のユーザー確認フロー
