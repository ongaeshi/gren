# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/grendbyaml.rb")
require 'fileutils'

class TestGrendbYAML < Test::Unit::TestCase
  include Mkgrendb

  def setup
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
  end

  def test_000
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
