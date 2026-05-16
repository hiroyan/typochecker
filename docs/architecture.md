# アーキテクチャ

## 全体の流れ

```text
入力ファイル
  -> 単語抽出
  -> 短い語を除外
  -> 辞書照合
  -> 未知語に対する候補生成
  -> 候補を辞書で絞り込み
  -> typo レポート
```

## 主要コンポーネント

### `Typochecker::SpellingSupport`

共有ヘルパーと定数を持ちます。

- アルファベット / 母音 / 子音の定義
- 語形変化ルール
- 辞書構築
- 単語抽出

### `Typochecker::TypoChecker`

typo 検出の振る舞いを担当します。

- 実行時設定
- 辞書アクセス
- typo 結果のキャッシュ
- ファイル単位 / 行単位の検査
- Levenshtein 候補生成

### `exe/typochecker`

gem install 後に使える CLI です。`-d` と `-k` を解釈し、チェッカーを生成して、
対象ファイルの結果を表示します。

### `typochecker.rb`

旧来の直接実行・`require` 利用との互換用入口です。
実装本体は `lib/` 配下へ移っています。

## ファイル境界

- `lib/typochecker.rb` — ライブラリ読込の入口と既定辞書パス
- `lib/typochecker/spelling_support.rb` — 辞書構築、語形変化、単語抽出
- `lib/typochecker/typo_checker.rb` — typo 検出本体
- `lib/typochecker/version.rb` — gem バージョン
- `exe/typochecker` — CLI
- `typochecker.rb` — 後方互換用入口

## データモデル

- 辞書: `Hash<String, true>`
- typo 候補キャッシュ: `Hash<String, Array<String>>`
- typo 結果: `TypoInfo = Struct.new(:word, :suggestions)`

## 設計上の特徴

- 候補語は先に生成し、その後で辞書に存在するものだけへ絞り込みます。
- 辞書の語形展開は検索時ではなく、読み込み時に行います。
- 単語抽出は正規表現ベースで、意図的に単純です。

## 変更時の見方

変更するときは、どの境界に触れているかを意識してください。

- 単語抽出
- 辞書読み込み / 語形展開
- 候補生成
- 結果整形
- CLI

複数の境界を同時に変更する場合は、なぜその広さが必要なのかを説明してください。
