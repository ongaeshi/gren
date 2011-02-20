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
    @prev_dir = Dir.pwd
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
    FileUtils.cd(@tmp_dir.to_s)
  end

  def test_000
    # create
    yaml = GrendbYAML.create
    assert_equal yaml.directory, []
    assert_equal yaml.version, 0.1
    assert_raise(GrendbYAML::YAMLAlreadyExist) { GrendbYAML.create }

    # load
    yaml = GrendbYAML.load
    assert_equal yaml.directory, []
    assert_equal yaml.version, 0.1

    # load fail
    FileUtils.mkdir 'loadtest'
    FileUtils.cd 'loadtest' do
      assert_raise(GrendbYAML::YAMLNotExist) { GrendbYAML.load }
    end

    # add
    yaml.add('dir1')
    yaml.add('dir2', 'dir3')
    assert_equal ['dir1', 'dir2', 'dir3'], yaml.directory

    # remove
    yaml.add('dir2', 'dir4', 'dir5')
    yaml.remove('dir5')
    yaml.remove('dir2', 'dir3')
    assert_equal ['dir1', 'dir4'], yaml.directory

    # save
    yaml.save
    assert_equal <<EOF, open('grendb.yaml').read
--- 
directory: 
- dir1
- dir4
version: 0.1
EOF
  end

  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
