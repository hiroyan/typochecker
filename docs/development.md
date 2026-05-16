# Codex 向け開発ガイド

## 環境

- 言語: Ruby
- 実行時依存: 標準ライブラリのみ
- 現在の検証方法: Minitest

## よく使うコマンド

```sh
# 標準テストを実行
rake test

# gem をビルド
gem build typochecker.gemspec

# CLI 実装を直接確認
ruby -Ilib exe/typochecker -d words.txt -k keyword.txt test/test.txt

# 後方互換用入口を確認
ruby typochecker.rb -d words.txt -k keyword.txt test/test.txt
```

## 編集方針

- タスクで明示されない限り、既存の公開挙動は保つ。
- 大きな抽象化を足すより、小さなヘルパーの抽出を優先する。
- パッケージ化や UX 改善が目的でない限り、簡素な CLI を保つ。
- 実装の正本は `lib/` 配下とし、`typochecker.rb` には互換用以上の責務を増やさない。
- バグ修正や、単語抽出 / 候補生成の挙動変更では、焦点を絞ったテストを追加する。
- 性能が論点になる場合は、最適化の前に候補数の増え方を観測する。

## 将来の改善候補

以下は今後の候補であり、毎回必ず片づけるべき cleanup ではありません。

1. 行番号を 0 始まりにするか 1 始まりにするか明確化する
2. 辞書が大きくなる、または既定距離を上げる場合に、より効率的な探索方法を検討する

## Codex タスクの完了条件

通常、完了時には次を含めます。

- 何を変えたかの簡潔な説明
- なぜその変更が必要だったか
- 実行した検証
- 残るトレードオフや、知っておくべき次の一手

gem の配布や CLI に関わる変更では、`rake test` に加えて
`gem build typochecker.gemspec` と CLI 実行確認も行います。
