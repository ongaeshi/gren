# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "file_test_utils")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/cli.rb")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/mkgrendb2.rb")
require 'stringio'

class TestMkgrendb < Test::Unit::TestCase
  include Mkgrendb
  include FileTestUtils

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
end


