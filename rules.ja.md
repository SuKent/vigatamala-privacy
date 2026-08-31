# Vigatamala ブロックルール

[繁體中文](/rules.zh-Hant) · [简体中文](/rules.zh-Hans) · [日本語](/rules.ja) · [한국어](/rules.ko)

ここには Vigatamala iOS ブラウザが使用する広告とトラッカーのブロックルールを置いています。

この二つのリストは**App に同梱されておらず**、利用者が App 内でダウンロードします —— つまり、下記のファイルは App が実際に取得することになるその変換済みの成果物そのものであり、どなたでも直接ダウンロードし、内容を確認し、ご自身で利用することもできます(下記のライセンスを参照)。

## ダウンロード

| ファイル | 説明 |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList の content blocker 版(二次的著作物) |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | 氏名表示と上流の著作権表示 |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy の content blocker 版(二次的著作物) |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | 同上 |
| [easylist.json.sig](https://privacy.link2us.link/rules/easylist.json.sig) | Ed25519 署名(App 側の検証用) |
| [easyprivacy.json.sig](https://privacy.link2us.link/rules/easyprivacy.json.sig) | 同上 |

## これは何か

上記の二つの JSON は [EasyList](https://easylist.to/) と EasyPrivacy の**二次的著作物**です:当方は Adblock Plus のフィルター構文を Apple の Safari content blocker の JSON 形式に変換しており、その過程で:

- その形式では表現できないルールの型(scriptlet の注入、高度なオプションなど)を破棄しました;
- 65,000 件で切り詰めています —— これは**当方が自分で選んだ**保守的な上限であり(古い機種でのコンパイル時間とメモリを考慮したもの)、形式上の限界ではありません。今日の上流でいえば、この上限で**実際に切り落とされたものはありません**(easylist は 60,928 件、easyprivacy は 55,895 件で、いずれも上限の内側です)。WebKit は現在、解析の段階で 150,000 件を超えるリストを受け付けませんが、その数字は WebKit の実装上の詳細であり(Apple のドキュメントには記載がなく、2020 年末にようやく 50,000 から引き上げられました)、しかも「コンパイル処理の約 150 MB というメモリ予算」に合わせて定められた上界です —— コンパイルできる件数と、コンパイルする価値のある件数は同じことではなく、当方はその線に近づけるつもりはありません。

したがってこれは上流のリストと**同一ではなく**、ブロックの効果も完全には同じではありません。
完全な原版が必要な場合は[上流の取得元](https://easylist.to/)を直接お使いください。

## ライセンス

上流は GPLv3 または CC BY-SA 3.0 Unported のデュアルライセンスで公開されており、利用者がどちらかを選びます。
**本二次的著作物は CC BY-SA 3.0 Unported を採用することを明示します。**

- 氏名表示:The EasyList authors (https://easylist.to/)
- ライセンス全文:<https://creativecommons.org/licenses/by-sa/3.0/legalcode>
- 原著作者は本二次的著作物を**推奨していません**。

各ルールの隣にある `.NOTICE.txt` は、上流のファイルヘッダにある著作権表示(Title / Version / Last modified / Commit / Homepage / Licence)を一字一句そのまま保持しています。content blocker の JSON は裸のトップレベル配列でコメントの構文がなく、ファイルの中に書き戻せないためです。それらの NOTICE には、各回の変換が依拠した上流のバージョンと commit も記録されており、版ごとに監査できます。

**ライセンスの範囲は `rules/` ディレクトリに限られます**;本サイトのその他の内容(プライバシーポリシーなど)は著作権を留保します。

## 完全性の検証

ルールファイルは Ed25519 で署名されており(`.sig` は 64 バイトの raw 署名を base64 にしたものです)、Vigatamala App は対応する公開鍵を内蔵していて、ミラーの取得元は署名の検証を通過しない限り採用されません。

## 再現方法

`rules/converter/` は単独でビルドできる変換器です(App 内で使っているものと同じソースコードであり、同じ入力からバイト単位で同一の出力を生成します):

```bash
cd rules/converter
swift build -c release
.build/release/RuleConverter <入力.txt> <出力.json> 65000
```

本 repo のルールは GitHub Actions によって毎日自動で同期されており(`.github/workflows/` を参照)、使っているのはまさにこの変換器です。
