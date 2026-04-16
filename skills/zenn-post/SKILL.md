---
name: zenn-post
description: Zennに記事を書いて公開する。「Zennに上げて」「Zennに投稿して」「Zennに出して」と言われたら使う。NotionページをZennに投稿する場合も使う。
argument-hint: [NotionのURLまたはタイトル、またはテーマ]
allowed-tools: [Read, Edit, Write, Bash]
---

# Zenn 記事投稿スキル

## 環境情報

以下はセットアップ時に各自の環境に合わせて設定してください。

- リポジトリ: `/path/to/your/zenn-content`（例: `~/dev/zenn-content`）
- GitHub: `your-github-username/zenn-content`
- Zenn: `https://zenn.dev/your_username`
- 公開方法: `git push origin main` → Zenn に自動反映（1〜2分）

> **セットアップ手順**
> 1. [Zenn アカウント作成](https://zenn.dev)
> 2. zenn-content リポジトリを GitHub に作成し、Zenn と連携
> 3. `npx zenn-cli init` でリポジトリを初期化
> 4. このスキルの環境情報を自分のパスに書き換える

## 実行フロー

### 0. 元ネタを特定する

まず「どのコンテンツをZennに上げるか」を確認する。

- URL が渡されている → そのNotionページを読む
- タイトルや「さっき作ったやつ」など曖昧な指定 → Notion を検索して特定し、「これですか？」と確認する
- 何も指定なし → 「どのNotionページ、またはどんなテーマで書きますか？」と聞く

Notionページが特定できたら内容を読み込んで記事の素材にする。

### 1. slug を決める

英小文字・数字・ハイフン・アンダースコアのみ、12〜50字。内容を表す英語スラッグ。
例: `claude-codex-comparison-2026`

### 2. 記事ファイルを生成

```bash
cd "/path/to/your/zenn-content"
npx zenn-cli new:article --slug <slug> --title "<タイトル>" --type tech --emoji <絵文字>
```

type は `tech`（技術記事）または `idea`（アイデア・考察）。

### 3. 記事本文を書く

生成された `articles/<slug>.md` を編集する。

**frontmatter の形式:**
```yaml
---
title: "タイトル"
emoji: "🔥"
type: "tech"
topics: ["claudecode", "ai", "codex"]
published: false
---
```

- topics は最大5つ、英小文字のZennトピック名
- 本文は Markdown 形式
- 見出しは `##` から始める（`#` はタイトルと被るので使わない）
- コードブロックには言語を明記する
- 読みやすさを意識して、導入・本文・まとめの構成にする

### 4. ユーザーに確認

記事の内容（タイトル・概要・本文）を見せて「このまま公開しますか？」と確認する。
**公開前に必ず確認を取ること。**

### 5. 公開

OKが出たら:
1. `published: false` → `published: true` に変更
2. git commit & push

```bash
cd "/path/to/your/zenn-content"
git add articles/<slug>.md
git commit -m "feat: add article <slug>"
git push origin main
```

push 完了を伝えて終了。`https://zenn.dev/your_username` に1〜2分で反映される。

## 注意事項

- 公開前に必ずユーザー確認（`published: true` にする前）
- 画像を使う場合は `images/` ディレクトリに置いて `![alt](../images/xxx.png)` で参照
