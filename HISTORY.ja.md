# 1.0.1 2013/04/21

* 起動時間の短縮。色付けしない時は termcolor の読み込みを外す

# 1.0.1 2013/04/08

* 一部ファイルを検索時にエンコードエラーが出る問題を修正
* 入力文字列、標準入力もエンコード変換するように
* Windowsプラットフォームの時はpipe?を無効に(cygwin対策)

# 1.0.0 2013/04/06

* gren
  * デフォルトでは詳細表示をOFF
    * --verbose オプションを追加
  * 小文字の単語は大文字小文字を無視する
    * test -> 'ignore' , Test -> 'not ignore'
  * パイプをサポート
    * ls | gren test

* Support Ruby 1.9
  * prec_i -> to_i, prec_f -> to_f

* File rename & add
  * History.*.txt -> HISTORY.*.md
  * README.rdoc -> README.md
  * Add README.ja.md
  * require join -> require 'gren/..'
  * Add test_cli.rb
  * gren/gren/cli -> gren/cli
  * Delete display_util.rb

* etc
  * hoe -> bundler に移行
  * Delete grendb(rroonga, rack) dependency

# 0.3.2 2011/02/20

* mkgrendb
  * Bugfix : yamlに記述されたディレクトリが存在しない時にハングアップするバグを修正
  * Bugfix : --fullオプションが正しく動作しない問題を修正

# 0.3.1 2010/11/20

* grenweb
  * 相対パスで動作するように

# 0.3.0 2010/11/02

* grenweb
  * webベースのソースコード検索エンジンを追加

* mkgrendb
  * 結果表示画面に追加されたファイルの数を追加

# 0.2.4 2010/10/09

* mkgrendb
  * データベースの形式を変更
    * 古いmkgrendbで作成したデータベースは、 'mkgrendb --full' で再構築をして下さい。
  * yamlに、ディレクトリではなく単一ファイルの指定もOKに

* grendb
  * マッチ対象を行では無くファイルとする --match-file モードを追加 
    * 今までのモードは --match-line
    * デフォルトのモードを --match-file に変更
    * 今までの行マッチモードを使う場合は、 -l or --ml or --match-line と指定する
  * 拡張子をキーとする検索モードを追加
    * -s, --suffix
  * --groonga-only オプションを作成
    * 実際のファイルを辿らず、データベースの情報のみで探索出来るように
  * 検索結果を更新時刻順で表示するように

# 0.2.3 2010/09/25

* mkgrendb
  * ymal入力時にパスを展開していないバグを修正
  * mkgrendbの最後に表示する基本情報を整理
    * 入力ファイル
    * 出力ファイル
    * かかった時間
    * ファイル数
    * 更新ファイル数
  * データベースの生成オプションを整理
    * パトリシア木 .. テーブルの記録方式、ハッシュに比べて遅くなるが、前方一致検索可能に
    * 正規化 .. 各語彙を正規化して登録(大文字、小文字を区別しない)
    * with_position .. 転置索引に出現位置情報を合わせて格納

# 0.2.2 2010/09/14

* mkgrendb
  * 複数引数に対応
  * 引数に、.rb, .yamlどちらを渡しても正しく動作するように
  * --ddb, --defaultオプションを追加 (GRENDB_DEFAULT_DBで指定されているデータベースを更新)
  * --dump    データベースの中身をダンプする
  * --full    データベースを一度削除してから再構築
  * --delete  データベースを削除(yamlは消さない)
  * ファイルのタイムスタンプを比較して、すでに更新されているものは再生成しないように

# 0.2.1 2010/09/13

* デフォルトのignoreファイル追加 .d, .map, .MAP
* オプション名変更 : --sub → --not

# 0.2.0 2010/09/13

* grooongaを利用して超高速検索を実現した、grendbをリリース
  * mkgrendbでデータベース生成
  * grendbでデータベース検索

# 0.1.4 2010/08/14

* snipモード
  * 一行が長過ぎる場合は適当に省略する機能を追加
  * 圧縮したJavascript等で効果を発揮

# 0.1.3 2010/08/13

* 含まれない検索、OR検索に対応
  * --subで指定したキーワードは''含まれない''
  * --orで指定したキーワードは''いずれかを含む''

* 自動エンコードに対応
  * ファイルの文字コードがばらばらでも、自動的にシェルで使用している文字コードにあわせてくれるようにした
  * -e, --encode ENCODE              Specify encode(none, auto, jis, sjis, euc, ascii, utf8, utf16). Default is "auto"

# 0.1.2 2010/08/05

* Bug fix.
* 読み込み禁止ディレクトリがあるとハングアップする問題を修正

# 0.1.1 2010/08/04

* --depth, --this(== "--depth 0")、探索する階層数を指定出来るように
* -sでサイレントモード、マッチした行のみを表示する
* -f, --if, --idオプションを何個でも設定出来るように
* -cで色付き表示

# 0.1.0 2010/08/02

* Update README.doc (to English).

# 0.0.6 2010/07/29

* update github
  * http://github.com/ongaeshi/gren

# 0.0.1 2010-07-22

* 1 major enhancement:
  * Initial release
