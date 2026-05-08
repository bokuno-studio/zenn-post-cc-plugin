# zenn-post - Claude Code Plugin

Claude Code から Zenn・Qiita・dev.to・Hashnode に記事を投稿するスキルです。

「記事公開して」と言うだけで、Notion のページや指定したテーマをもとに記事を書いて **Zenn・Qiita（日本語）と dev.to・Hashnode（英訳）の4媒体に同時公開**します。

## できること

- Notion ページの内容を Zenn 記事に変換して投稿
- テーマを口頭で伝えるだけで記事を執筆・公開
- 日本語: Zenn + Qiita に同時投稿
- 英語: Zenn 記事を英訳して dev.to + Hashnode に同時投稿（翻訳は1回）
- Hashnode には Zenn を canonical URL として設定（SEO 対策）
- Mermaid 図を自動で PNG 変換（外部サービス不要・ローカル完結）
- 公開前にプレビューして確認 → OK で `git push` まで自動実行

## 使い方

```
「このNotionページをZennに上げて」
「記事公開して」          ← Zenn + Qiita + dev.to + Hashnode の4媒体に投稿
「日本語だけ投稿して」    ← Zenn + Qiita のみ
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

**3. API キーを設定する**

```bash
cat > ~/.claude/plugins/zenn-post/.env << 'EOF'
DEVTO_API_KEY=your_devto_api_key
QIITA_ACCESS_TOKEN=your_qiita_token
HASHNODE_API_TOKEN=your_hashnode_token
HASHNODE_PUBLICATION_ID=your_publication_id
EOF
echo ".env" >> ~/.claude/plugins/zenn-post/.gitignore
```

- **dev.to**: Settings → Extensions → DEV API Keys
- **Qiita**: 設定 → アプリケーション → 個人用アクセストークン（スコープ: `read_qiita` + `write_qiita`）
- **Hashnode**: Account Settings → Developer → Personal Access Tokens。Publication ID はダッシュボードの URL から確認

**4. Claude Code のプラグインマーケットプレイスに登録**

```bash
claude plugin marketplace add ~/.claude/plugins/zenn-post
claude plugin install zenn-post
```

## 開発・配布メモ

### ローカルマーケットプレイスへ同期

このリポジトリを更新したら、ローカルマーケットプレイスのコピーも明示的に同期します。

```bash
./scripts/sync-local.sh
```

- 同期先の既定値: `~/.claude/local-marketplace/plugins/zenn-post`
- `.env` と `.git/` は同期対象外です
- 既存の `skills/zenn-post/SKILL.md` にある「環境情報」ブロックは既定で保持します
- 同期後は `claude plugin update zenn-post@local` を実行し、Claude Code を再起動してキャッシュへ反映します

別の同期先を使う場合:

```bash
./scripts/sync-local.sh /path/to/local-marketplace/plugins/zenn-post
```

「環境情報」ブロックもソースで上書きしたい場合:

```bash
PRESERVE_SKILL_ENV_BLOCK=0 ./scripts/sync-local.sh
```

### リリース時の確認

`skills/zenn-post/SKILL.md` の description や仕様を変えた場合は、同じPRで `.claude-plugin/plugin.json` の `version` も更新します。

```bash
./scripts/validate-plugin.sh
claude plugin validate .
```

`./scripts/validate-plugin.sh` は、manifest の version が README の最新改定履歴と一致していること、manifest と skill description が4媒体（Zenn/Qiita/dev.to/Hashnode）を明示していることを確認します。

## Mermaid 図の扱いについて

- **Zenn・Qiita**: Mermaid をそのままレンダリングするため変換不要
- **dev.to・Hashnode**: Mermaid 非対応のため、このスキルは自動的に以下を行います

1. `npx @mermaid-js/mermaid-cli` で Mermaid コードを PNG に変換（ローカル完結）
2. PNG を zenn-content の `images/` ディレクトリに保存して push
3. dev.to・Hashnode 記事内の mermaid ブロックを `![図](raw.githubusercontent.com/...)` に置き換え

## ライセンス

MIT

---

## 改定履歴

### v0.3.0 (2026-04-27)
- Qiita への同時投稿機能を追加（日本語、Zenn 記法変換のみ・翻訳不要）
- Hashnode への同時投稿機能を追加（英語、dev.to の英訳を再利用）
- Hashnode 投稿時に Zenn を canonical URL として設定（SEO 対策）
- 投稿先を「日本語: Zenn + Qiita」「英語: dev.to + Hashnode」の4媒体に整理
- `.env` に Qiita・Hashnode の認証情報を追加

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
