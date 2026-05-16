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

- `typochecker.rb` — 実装本体と CLI の入口
- `words.txt` — 同梱辞書データ
- `keyword.txt` — プロジェクト固有の許可語
- `test/typocheckerSpec.rb` — 現在の検証スクリプト
- `docs/` — Agent と人間が共有するプロジェクト文脈
- `prompts/` — Codex 向けの再利用プロンプト

## 最初に読む順番

1. `docs/project-overview.md`
2. 実装に触れる場合は `docs/architecture.md`
3. 振る舞いやテストを変える前に `docs/development.md`
4. 大きめの作業を始めるときは `prompts/` のテンプレートを使う

## 検証

現時点では本格的なテストフレームワークは導入されていません。
既存の検証スクリプトは次で実行できます。

```sh
ruby test/typocheckerSpec.rb
```

将来、正式なテストスイートを導入した場合は、このファイルと
`docs/development.md` をあわせて更新してください。
