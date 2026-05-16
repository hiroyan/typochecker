# Typo Checker

Levenshtein 距離を使って、英単語の typo 候補を検出する Ruby 製の小さなツールです。
テキストファイルから単語を抽出し、辞書に存在しない語について近い候補を提案します。

## 特徴

- 辞書ベースで typo 候補を検出
- 削除・挿入・置換による Levenshtein 候補を生成
- 過去形、現在進行形、複数形を簡易的に辞書へ展開
- 追加の許可語を `keyword.txt` から読み込み可能
- CLI からそのまま実行可能

## インストール

現時点では、リポジトリ上で gem をビルドしてローカルインストールできます。

```sh
gem build typochecker.gemspec
gem install ./typochecker-0.1.0.gem
```

インストール後は、`typochecker` コマンドとして実行できます。

## 必要なもの

- Ruby
- 追加 gem は不要です

## 使い方

gem としてインストールした後にファイルを検査する場合:

```sh
typochecker path/to/input.txt
```

任意の辞書や追加許可語を指定する場合:

```sh
typochecker -d words.txt -k keyword.txt test/test.txt
```

リポジトリ上で直接実行する場合:

```sh
ruby typochecker.rb -d words.txt -k keyword.txt test/test.txt
```

オプション:

```text
-d, --dictionary DICT      使用する辞書ファイル
-k, --keyword KEYWORD_FILE 追加で許可する語の一覧
```

## 実行例

```sh
typochecker -d words.txt -k keyword.txt test/test.txt
```

出力は次のような形式です。

```text
7: progresive is possibly typo. Did you mean: progressive
```

## ファイル構成

- `lib/` — gem として読み込まれるライブラリ本体
- `exe/typochecker` — gem install 後に使える CLI
- `typochecker.gemspec` — gem のメタデータ
- `typochecker.rb` — 旧来の直接実行との互換用入口
- `words.txt` — 同梱辞書
- `keyword.txt` — 追加で許可する語
- `test/test.txt` — サンプル入力
- `test/typochecker_test.rb` — Minitest による自動テスト

## 開発

標準のテストは次で実行できます。

```sh
rake test
```

gem のビルド確認は次で行えます。

```sh
gem build typochecker.gemspec
```

CLI の動作確認をリポジトリ上で行う場合:

```sh
ruby -Ilib exe/typochecker -d words.txt -k keyword.txt test/test.txt
```

## Agent 開発

Codex を使った開発の入口として、以下のファイルを用意しています。

- `AGENTS.md` — Codex が最初に読む作業ルール
- `docs/` — プロジェクト背景、構造、開発方針
- `prompts/` — 計画、実装、レビュー、テスト用の再利用プロンプト

Codex に作業を依頼するときは、必要に応じて `prompts/` 配下のテンプレートを
そのまま使えます。
