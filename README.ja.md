# Gren (grep next)

[gren](http://gren.ongaeshi.me)はgrepの置き換えを目指して作ったコマンドラインツールです。

## 特徴

* Rubyがあれば簡単にインストール可能
  * Windowsでも使える
* とにかく簡単
  * ユーザーの指定する項目を最小限に
* ディレクトリ以下の全てのファイルを検索
* 不要なファイルは検索しない
  * .git, .svn, CVS, バイナリ
* AND、NOT、OR、正規表現
* 複数の文字エンコードが混ざっていても大丈夫
  * utf-8, utf-16, sjis, euc ..
* もっと高速に検索したい時は [Milkode](http://milkode.ongaeshi.me) をどうぞ

## インストール

```
$ gem install gren
```

重たいgemは使っていないのでRubyが動けばどこでも使えるはずです。

## オプション

```
$ gren -h
gren [option] pattern
        --not PATTERN                Keyword is not included.
        --or PATTERN                 Either of keyword is contained.
    -c, --color                      Color highlight.
        --cs, --case-sensitive       Case sensitivity.
    -d, --directory DIR              Start directory. (deafult:".")
        --debug                      Debug display.
        --depth DEPTH                Limit search depth. 
    -e, --encode ENCODE              Specify encode(none, auto, jis, sjis, euc, ascii, utf8, utf16). 
    -f, --file-regexp REGEXP         Search file regexp. (Enable multiple call)
    -i, --ignore                     Ignore case.
        --id, --ignore-dir REGEXP    Ignore dir pattern. (Enable multiple call)
        --if, --ignore-file REGEXP   Ignore file pattern. (Enable multiple call)
        --no-snip                    There being a long line, it does not snip.
        --silent                     Silent. Display match line only.
        --this                       "--depth 0"
    -v, --verbose                    Set the verbose level of output.
```

## チュートリアル

### ディレクトリ以下にある全てのファイルを検索

```
$ cd ~/gren/test/data
$ gren abc
abc.rb:1:def abc
abc.rb:6:abc
```

### ヒューリスティックな大文字、小文字の区別

```shell
# 全て小文字の場合は大文字、小文字の区別をしない
$ gren testcase
testcase.txt:1:testcase
testcase.txt:2:TestCase
testcase.txt:3:TESTCASE

# 大文字混じりの文字は厳密に検索
$ gren TestCase
testcase.txt:2:TestCase

$ gren TESTCase
Not found..

# 厳密に小文字を検索したい時は --cs(--case-sensitive) を使う
$ gren testcase --cs
testcase.txt:1:testcase
```

### キーワードを重ねてAND検索

```
$ gren abc def
abc.rb:1:def abc
```

### NOT検索

```
$ gren abc --not def
abc.rb:6:abc
```

### OR検索

```
$ gren --or aaa --or bbb
aaa.txt:1:aaa
bbb.txt:1:bbb
```

### 開始ディレクトリを指定

```
$ gren ccc -d sub
sub/ccc.txt:1:ccc
```

### ファイル名で絞り込み

```
$ gren bb 
abc.rb:4:bb
bbb.txt:1:bbb

$ gren bb -f abc
abc.rb:4:bb

$ gren bb --if abc
bbb.txt:1:bbb
```

### ディレクトリ名で絞り込み

```
$ gren ccc --id sub
ccc.c:1:ccc
```

### 詳細表示

```
$ gren a --verbose
aaa.txt:1:aaa
abc.rb:1:def abc
abc.rb:3:a
abc.rb:6:abc

dir   : /Users/ongaeshi/Documents/gren/test/data (0.0sec)
files : 5 in 5 (54Byte in 54Byte)
match : 2 files, 4 hit
```

## エディタとの連携
### Emacs

```lisp
(global-set-key (kbd "C-x C-g") 'grep-find) ; your favarite key
(setq grep-find-command "gren ")            ; "gren.bat" for Windows
```

## ライセンス
See LISENCE.txt

## 作者
[ongaeshi](http://ongaeshi.me)
