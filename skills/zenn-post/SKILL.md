---
name: zenn-post
description: Zennに記事を書いて公開する。「Zennに上げて」「Zennに投稿して」「Zennに出して」と言われたら使う。NotionページをZennに投稿する場合も使う。「dev.toにも上げて」と言われたらdev.toにも英訳して投稿する。
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

---

## dev.to への同時投稿（オプション）

「dev.toにも上げて」と言われた場合、Zenn 記事の公開後に以下を実行する。

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
source /path/to/.env  # DEVTO_API_KEY を読み込む

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

## 注意事項

- 公開前に必ずユーザー確認（`published: true` にする前）
- 画像を使う場合は `images/` ディレクトリに置いて `![alt](../images/xxx.png)` で参照
- zenn-content リポジトリは **public** にしておくこと（private だと raw.githubusercontent.com の画像が外部から見えない）
- dev.to API キーは `.env` に書き、`.gitignore` で除外する
