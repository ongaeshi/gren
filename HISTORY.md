# 1.0.1 2013/04/21

* Faster startup. Don't require 'termcolor' not coloring.

# 1.0.1 2013/04/08

* Fix encoding error
* Encode input string & stdin
* Disable pipe? in Windows environment (because cygwin)

# 1.0.0 2013/04/06

* gren
  * Do not drill in the default
    * Add --verbose options
  * Lowercase word ignores capitalization
    * test -> 'ignore' , Test -> 'not ignore'
  * Support pipe
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
  * hoe -> bundler
  * Delete grendb(rroonga, rack) dependency

# 0.3.2 2011/02/20

* mkgrendb
  * Bugfix

# 0.3.1 2010/11/20

* grenweb

# 0.3.0 2010/11/02

* grenweb
* mkgrendb

# 0.2.4 2010/10/09

* mkgrendb
* grendb

# 0.2.3 2010/09/25

* mkgrendb

# 0.2.2 2010/09/14

* mkgrendb

# 0.2.1 2010/09/13

* gren

# 0.2.0 2010/09/13

* grendb

# 0.1.4 2010/08/14

* gren
  * snip-mode

# 0.1.3 2010/08/13

* gren

# 0.1.2 2010/08/05

* gren
  * Bug fix.

# 0.1.1 2010/08/04

* gren

# 0.1.0 2010/08/02

* Update README.doc (to English).

# 0.0.6 2010/07/29

* update github
  * http://github.com/ongaeshi/gren

# 0.0.1 2010-07-22

* 1 major enhancement:
  * Initial release
