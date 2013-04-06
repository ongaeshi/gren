# Gren (grep next)

[gren](http://gren.ongaeshi.me) is a next grep tool.

## Features

* The basis is find+grep.
* The item that the user specifies to the minimum
  * The binary or the text or the tool judges it from the automatic operation. 
* Convenient retrieval result

## Installation

```
$ gem install gren
```

## Usage

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

## Editor Setting
### Emacs

```lisp
(global-set-key (kbd "C-x C-g") 'grep-find) ; your favarite key
(setq grep-find-command "gren ")            ; "gren.bat" for Windows
```

### License
See LISENCE.txt

### Author
[ongaeshi](http://ongaeshi.me)
