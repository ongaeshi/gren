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
     
     # Mkgrendb2#add, remove
     obj.add('test1.html', 'test2.html')
     assert_equal ['test1.html', 'test2.html'], GrendbYAML.load.directory
     assert_match /WARNING.*test1.html/, io.string
     assert_match /WARNING.*test2.html/, io.string

     obj.remove('test1.html', 'test2.html')
     assert_equal [], GrendbYAML.load.directory
     
     # Mkgrendb2#add
     io.rewind
     obj.add('../../lib/findgrep', '../../lib/common')
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string

     # Mkgrendb2#update
     io.rewind
     obj.update
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string     
  end

  def test_cli
    io = StringIO.new
    CLI.execute(io, ["init"])
    CLI.execute(io, ["update"])
    CLI.execute(io, ["add"])
    CLI.execute(io, ["list"])
    CLI.execute(io, ["rebuild"])
  end

  def teardown
    teardown_custom(true)
  end
end


