# Gren (grep next)

[gren](http://gren.ongaeshi.me)はgrepの置き換えを目指して作ったコマンドラインツールです。

## 特徴

* 基本はfind+grep
  * 指定ディレクトリ以下にある全てのファイルの中身を調べます。 
  * ユーザーが指定する項目を最小限に
  * デフォルトで除外ディレクトリが設定されています
  * AND検索、
* バイナリファイルの自動判別
  * The binary or the text or the tool judges it from the automatic operation. 
* grepとの互換性  
  
* Convenient retrieval result

## インストール

```
$ gem install gren
```

## オプション

```
$ gren -h
gren [option] pattern
        --not PATTERN                Keyword is not included.
        --or PATTERN                 Either of keyword is contained.
    -d, --directory DIR              Start directory. (deafult:".")
        --depth DEPTH                Limit search depth. 
        --this                       "--depth 0"
    -i, --ignore                     Ignore case.
    -s, --silent                     Silent. Display match line only.
        --debug                      Debug display.
    -c, --color                      Color highlight.
    -f, --file-regexp REGEXP         Search file regexp. (Enable multiple call)
        --if, --ignore-file REGEXP   Ignore file pattern. (Enable multiple call)
        --id, --ignore-dir REGEXP    Ignore dir pattern. (Enable multiple call)
    -e, --encode ENCODE              Specify encode(none, auto, jis, sjis, euc, ascii, utf8, utf16). Default is "auto"
        --no-snip                    There being a long line, it does not snip.
```

## エディタとの連携
### Emacs

```lisp
(global-set-key (kbd "C-x C-g") 'grep-find) ; your favarite key
(setq grep-find-command "gren ")            ; "gren.bat" for Windows
```

### ライセンス
See LISENCE.txt

### 作者
[ongaeshi](http://ongaeshi.me)
