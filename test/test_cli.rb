# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'gren/gren/cli'
require 'test_helper'

class TestCLI < Test::Unit::TestCase
  def setup
    @old = Dir.pwd
    Dir.chdir(File.join(File.dirname(__FILE__), "data"))
  end

  def teardown
    Dir.chdir(@old)
  end
  
  def test_help
    # command("-h")  # 呼ぶとexitするのでコメントアウト
  end
  
  def test_simple
    assert_equal <<EOF, command("aaa")
aaa.txt:1:aaa
EOF
  end

  def test_and_search
    assert_equal <<EOF, command("def abc")
abc.rb:1:def abc
EOF
  end

  def test_not
    assert_equal <<EOF, command("abc --not def")
abc.rb:6:abc
EOF
  end

  def test_verbose
    assert_match /dir.*match.*files/m, command("aaa --verbose")
  end

  def test_directory
    assert_equal <<EOF, command("ccc")
ccc.c:1:ccc
sub/ccc.txt:1:ccc
EOF

    assert_equal <<EOF, command("ccc -d sub")
sub/ccc.txt:1:ccc
EOF
  end

  def test_files
    assert_equal <<EOF, command("bb")
abc.rb:4:bb
bbb.txt:1:bbb
EOF

    assert_equal <<EOF, command("bb -f abc")
abc.rb:4:bb
EOF

    assert_equal <<EOF, command("bb --if abc")
bbb.txt:1:bbb
EOF
  end

  private

  def command(arg)
    io = StringIO.new
    CLI.execute(io, arg.split)
    io.string
  end
end
