# AGENTS.md

このリポジトリは、Levenshtein 距離に基づいて英単語の typo 候補を検出する
小さな Ruby プログラムです。

## Codex との作業ルール

- 重要な変更に入る前に、`README.md` と `docs/` 配下の関連ファイルを読む。
- 変更は小さく、焦点を絞り、レビューしやすい単位に保つ。
- ユーザーが大きな再設計を求めていない限り、現在の軽量な構成を尊重する。
- できるだけ素の Ruby と標準ライブラリを使う。依存関係を追加する場合は理由を説明する。
- 振る舞いを変えた場合は、`test/` にテストを追加または更新する。
- 作業を終える前に、その変更に対して最小限で妥当な検証を実行する。

## プロジェクト構成

- `lib/typochecker.rb` — gem 読み込み時の入口
- `lib/typochecker/` — ライブラリ本体
- `exe/typochecker` — gem install 後に使える CLI
- `typochecker.gemspec` — gem のメタデータ
- `typochecker.rb` — 旧来の直接実行との互換用入口
- `words.txt` — 同梱辞書データ
- `keyword.txt` — プロジェクト固有の許可語
- `test/typochecker_test.rb` — Minitest による自動テスト
- `docs/` — Agent と人間が共有するプロジェクト文脈
- `prompts/` — Codex 向けの再利用プロンプト

## 最初に読む順番

1. `docs/project-overview.md`
2. 実装に触れる場合は `docs/architecture.md`
3. 振る舞いやテストを変える前に `docs/development.md`
4. 大きめの作業を始めるときは `prompts/` のテンプレートを使う

## 検証

標準のテストは次で実行できます。

```sh
rake test
```

gem のビルド確認が必要な変更では、あわせて次も実行してください。

```sh
gem build typochecker.gemspec
```

CLI 変更時は、必要に応じて次も確認してください。

```sh
ruby -Ilib exe/typochecker -d words.txt -k keyword.txt test/test.txt
```
