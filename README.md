# Gren (grep next)

[gren](http://gren.ongaeshi.me) is a next grep tool.

## Features

* Need Ruby, only
  * It is available on Windows
* Easy to use
  * Search files in the directory below
* Don't search the unnecessary files
  * .git, .svn, CVS, binary
* AND, NOT, OR, Regexp
* Search mixed character encoding
  * utf-8, utf-16, sjis, euc ..
  
If you want to search  many files faster, Please use [Milkode](http://milkode.ongaeshi.me).

## Installation

```
$ gem install gren
```

Not use any heavy gem :-)

## Usage

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

## Tutorial

### Search for all files in the directory below

```
$ cd ~/gren/test/data

$ gren abc
abc.rb:1:def abc
abc.rb:6:abc
```

### Heuristic, case-sensitive

```shell
# The case-insensitive when all lower case
$ gren testcase
testcase.txt:1:testcase
testcase.txt:2:TestCase
testcase.txt:3:TESTCASE

# Character mixed capitalization is strictly Search
$ gren TestCase
testcase.txt:2:TestCase
$ gren TESTCase
Not found..

# If you would like to search case strictly, use --cs(--case-sensitive)
$ gren testcase --cs
testcase.txt:1:testcase
```
### AND search in piles keyword

```
$ gren abc def
abc.rb:1:def abc
```

### NOT

```
$ gren abc --not def
abc.rb:6:abc
```

### OR

```
$ gren --or aaa --or bbb
aaa.txt:1:aaa
bbb.txt:1:bbb
```

### Specify starting directory

```
$ gren ccc -d sub
sub/ccc.txt:1:ccc
```

### Filter by filename

```
$ gren bb 
abc.rb:4:bb
bbb.txt:1:bbb

$ gren bb -f abc
abc.rb:4:bb

$ gren bb --if abc
bbb.txt:1:bbb
```

### Fileter by directory

```
$ gren ccc --id sub
ccc.c:1:ccc
```

### Detail display

```
$ gren a --verbose
aaa.txt:1:aaa
abc.rb:1:def abc
abc.rb:3:a
abc.rb:6:abc

dir   : /path/to/gren/data/test (0.0sec)
files : 5 in 5 (54Byte in 54Byte)
match : 2 files, 4 hit
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
