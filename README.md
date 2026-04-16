# zenn-post — Claude Code Plugin

Claude Code から Zenn に記事を投稿するスキルです。

「Zennに上げて」と言うだけで、Notion のページや指定したテーマをもとに記事を書いて公開まで完結します。

## できること

- Notion ページの内容を Zenn 記事に変換して投稿
- テーマを口頭で伝えるだけで記事を執筆・公開
- 公開前にプレビューして確認 → OK で `git push` まで自動実行

## 使い方

```
「このNotionページをZennに上げて」
「Zennに投稿して」
「〇〇についてZennに書いて」
```

## インストール

### 前提

- [Claude Code](https://claude.ai/code) がインストール済み
- Zenn アカウントと zenn-content リポジトリが GitHub に存在すること
  - 参考: [ZennとGitHubリポジトリを連携する](https://zenn.dev/zenn/articles/connect-to-github)

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

**3. Claude Code のプラグインマーケットプレイスに登録**

```bash
claude plugin marketplace add ~/.claude/plugins/zenn-post
claude plugin install zenn-post
```

## ライセンス

MIT
