---
name: zenn-post
description: 記事を書いて公開する。「記事公開して」「Zennに上げて」「投稿して」と言われたら使う。デフォルトでZenn・Qiita（日本語）とdev.to・Hashnode（英訳）の4媒体に同時投稿する。「Zennだけ」「日本語だけ」など絞り込みも可。NotionページをZennに投稿する場合も使う。
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
> 2. zenn-content リポジトリを GitHub に作成し、Zenn と連携（**public** リポジトリにすること）
> 3. `npx zenn-cli init` でリポジトリを初期化
> 4. このスキルの環境情報を自分のパスに書き換える

## 投稿先の構成

| 言語 | 媒体 | 内容 |
|------|------|------|
| 日本語 | Zenn | オリジナル記事 |
| 日本語 | Qiita | Zenn 記事を Zenn 独自記法のみ変換して転載 |
| 英語 | dev.to | Zenn 記事を英訳 |
| 英語 | Hashnode | dev.to と同じ英訳を転載（翻訳は1回のみ） |

**デフォルトは4媒体すべてに投稿する。** ユーザーが絞り込んだ場合はその指定に従う。

| 指定例 | 投稿先 |
|--------|--------|
| 「Zennだけ」 | Zenn のみ |
| 「日本語だけ」 | Zenn + Qiita |
| 「英語だけ」 | dev.to + Hashnode |
| 「dev.toだけ」 | dev.to のみ |

---

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

### 5. 公開（Zenn）

OKが出たら:
1. `published: false` → `published: true` に変更
2. git commit & push

```bash
cd "/path/to/your/zenn-content"
git add articles/<slug>.md
git commit -m "feat: add article <slug>"
git push origin main
```

push 完了後、**続けて Qiita・dev.to・Hashnode にも投稿する**（下記各セクションを順に実行）。
「〇〇だけ」と明示された場合はその指定に従ってスキップする。

---

## Qiita への投稿

Zenn 公開後、日本語媒体として続けて実行する。

### Qiita 環境情報

- アクセストークン: `.env` ファイルの `QIITA_ACCESS_TOKEN`（`.gitignore` で除外すること）
  - 取得: Qiita → 設定 → アプリケーション → 個人用アクセストークン → 発行
  - 必要スコプ: `read_qiita` + `write_qiita`

### Qiita 投稿フロー

#### 1. Zenn 記法・画像パスを変換する

Zenn 独自記法と画像パスを変換する（本文は日本語のまま）：

| 変換対象 | 変換後 |
|-----------|----------------|
| `:::message` ... `:::` | `> **Note:** ...` |
| `:::message alert` ... `:::` | `> **⚠️ Warning:** ...` |
| ```` ```mermaid ``` ```` | そのまま（Qiita は Mermaid をレンダリングする） |
| `/images/<ファイル名>` | `https://raw.githubusercontent.com/your-github-username/zenn-content/main/images/<ファイル名>` |

画像パスは **必ず絶対 URL に変換すること**。相対パスのままだと Qiita では画像が表示されない。

#### 2. Qiita に投稿する

```bash
source ~/.claude/plugins/zenn-post/.env  # QIITA_ACCESS_TOKEN を読み込む

curl -X POST https://qiita.com/api/v2/items \
  -H "Authorization: Bearer $QIITA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "<日本語タイトル>",
    "body": "<本文（変換済み Markdown）>",
    "private": false,
    "tags": [
      {"name": "tag1", "versions": []},
      {"name": "tag2", "versions": []}
    ]
  }'
```

- tags は Qiita のタグ名（日本語可）。最大5つ
- 投稿後に返ってくる `url` をユーザーに伝える

---

## dev.to への投稿

英語媒体として続けて実行する。

### dev.to 環境情報

- API キー: `.env` ファイルの `DEVTO_API_KEY`（`.gitignore` で除外すること）
- 画像置き場: `zenn-content/images/`（`raw.githubusercontent.com` 経由で公開）

### dev.to 投稿フロー

#### 1. 記事を英訳する

Zenn 記事の本文を英語に翻訳する。Zenn 独自記法は以下に変換：

| Zenn 記法 | dev.to Markdown |
|-----------|----------------|
| `:::message` ... `:::` | `> **Note:** ...` |
| `:::message alert` ... `:::` | `> **⚠️ Warning:** ...` |
| ```` ```mermaid ``` ```` | → 下記手順で画像に変換 |

この英訳は Hashnode にも転用するため、後で使い回せるよう保持しておく。

#### 2. Mermaid 図を画像に変換する

記事中の mermaid コードブロックをすべて画像に変換する。
dev.to は Mermaid をレンダリングしないため、画像化が必要。

```bash
# 1. mermaid コードをファイルに書き出す
cat > /tmp/diagram.mmd << 'EOF'
<mermaidコード>
EOF

# 2. PNG 生成（外部サービス不要・ローカル完結）
npx @mermaid-js/mermaid-cli -i /tmp/diagram.mmd -o /tmp/diagram.png -t default -b white

# 3. zenn-content の images/ にコピーして push
cp /tmp/diagram.png "/path/to/your/zenn-content/images/<slug>-diagram.png"
cd "/path/to/your/zenn-content"
git add images/<slug>-diagram.png
git commit -m "feat: add diagram image for <slug>"
git push origin main
```

push 後、以下の URL で画像が公開される：
```
https://raw.githubusercontent.com/your-github-username/zenn-content/main/images/<ファイル名>
```

記事内の mermaid ブロックをこの URL の `![図の説明](URL)` に置き換える。

#### 3. dev.to に投稿する

```bash
source ~/.claude/plugins/zenn-post/.env  # DEVTO_API_KEY を読み込む

curl -X POST https://dev.to/api/articles \
  -H "api-key: $DEVTO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "article": {
      "title": "<英語タイトル>",
      "published": true,
      "tags": ["tag1", "tag2", "tag3", "tag4"],
      "body_markdown": "<本文>"
    }
  }'
```

- tags は最大4つ、英小文字のみ
- 投稿後に返ってくる `url` をユーザーに伝える

---

## Hashnode への投稿

dev.to 投稿後、同じ英訳を使って続けて実行する。翻訳は不要（dev.to で作成済みの英語版を再利用）。

### Hashnode 環境情報

- API トークン: `.env` ファイルの `HASHNODE_API_TOKEN`
  - 取得: Hashnode → Account Settings → Developer → Personal Access Tokens
- Publication ID: `.env` ファイルの `HASHNODE_PUBLICATION_ID`
  - 取得: Hashnode のブログダッシュボード URL に含まれる ID（例: `https://hashnode.com/<publication-id>/dashboard`）、または下記コマンドで確認

```bash
source ~/.claude/plugins/zenn-post/.env

# Publication ID の確認（自分のユーザー名のブログの ID を取得）
curl -X POST https://gql.hashnode.com \
  -H "Authorization: $HASHNODE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ me { publications(first: 5) { edges { node { id title } } } } }"}'
```

### Hashnode 投稿フロー

Mermaid 画像の URL は dev.to 投稿時に生成済みのものをそのまま使う。

```bash
source ~/.claude/plugins/zenn-post/.env  # HASHNODE_API_TOKEN, HASHNODE_PUBLICATION_ID を読み込む

curl -X POST https://gql.hashnode.com \
  -H "Authorization: $HASHNODE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation PublishPost($input: PublishPostInput!) { publishPost(input: $input) { post { id url } } }",
    "variables": {
      "input": {
        "title": "<英語タイトル>",
        "publicationId": "<HASHNODE_PUBLICATION_ID>",
        "contentMarkdown": "<本文（dev.to と同じ英語 Markdown）>",
        "tags": [],
        "originalArticleURL": "https://zenn.dev/your_username/articles/<slug>"
      }
    }
  }'
```

- `originalArticleURL` に Zenn の URL を設定すると canonical URL として扱われ、SEO 上 Zenn が正規記事になる
- 投稿後に返ってくる `post.url` をユーザーに伝える

---

## 注意事項

- 公開前に必ずユーザー確認（`published: true` にする前）
- 画像を使う場合は `images/` ディレクトリに置いて `![alt](/images/xxx.png)` で参照（`../images/` 相対パスはZennで表示されないため **絶対パス必須**）
- zenn-content リポジトリは **public** にしておくこと（private だと raw.githubusercontent.com の画像が外部から見えない）
- API キー・トークンはすべて `.env` に書き、`.gitignore` で除外する
- Hashnode の `originalArticleURL` は必ず設定し、Zenn を正規記事にする
