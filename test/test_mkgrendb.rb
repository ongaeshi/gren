# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'test/unit'
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/cli.rb")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/mkgrendb2.rb")
require 'fileutils'
require 'stringio'

class TestMkgrendb < Test::Unit::TestCase
  include Mkgrendb

  def setup
    @prev_dir = Dir.pwd
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
    FileUtils.cd(@tmp_dir.to_s)
  end

   def test_create
     db_path = Pathname.new('.') + 'db'
     database = Groonga::Database.create(:path => db_path.to_s)
     assert_equal database, Groonga::Context.default.database
   end

   def test_mkgrendb2
     io = StringIO.new
     obj = Mkgrendb2.new(io)
    
     # Mkgrendb2#init
     obj.init
     assert_equal <<EOF, io.string
create     : grendb.yaml
create     : db/grendb.db created.
EOF
     
     io.rewind
     obj.init
     assert_match "Can't create Grendb Database (Not empty)", io.string

     obj.add('test1.html', 'test2.html')
  end

  def test_cli
       CLI.execute($stdout, ["init"])
       CLI.execute($stdout, ["update"])
       CLI.execute($stdout, ["add"])
       CLI.execute($stdout, ["list"])
       CLI.execute($stdout, ["rebuild"])
  end

  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end


