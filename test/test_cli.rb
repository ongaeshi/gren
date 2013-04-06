# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'gren/gren/cli'
require 'test_helper'

class TestCLI < Test::Unit::TestCase
  def test_help
    # command("-h")  # 呼ぶとexitするのでコメントアウト
  end
  
  def test_simple
    command("test")
  end

  def test_and_search
    command("test gem")
  end

  def test_not
    command("test --not gem")
  end

  def test_verbose
    command("test gem --verbose")
  end

  def test_directory
    command("test -d test")
  end

  def test_files
    command("test -f cli")
  end

  private

  def command(arg)
    io = StringIO.new
    CLI.execute(io, arg.split)
    io.string
  end
end
