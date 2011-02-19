# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/cli.rb")
require 'fileutils'

class TestMkgrendb < Test::Unit::TestCase
  include Mkgrendb

  def test_000
    FileUtils.cd('test/testdb') do |dir|
      CLI.execute($stdout, ["init"])
      CLI.execute($stdout, ["update"])
      CLI.execute($stdout, ["add"])
      CLI.execute($stdout, ["list"])
      CLI.execute($stdout, ["rebuild"])
    end
  end
end


