# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/10/21

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../lib/grenweb/query')
require 'uri'

class TestGrenWebQuery < Test::Unit::TestCase
  include Grenweb

  def test_query
    q = create_query("test fire beam")
    assert_equal q.keywords, ['test', 'fire', 'beam']
    assert_equal q.packages, []
    assert_equal q.fpaths, []
    assert_equal q.suffixs, []

    q = create_query("test fire beam f:testfile1")
    assert_equal q.keywords, ['test', 'fire', 'beam']
    assert_equal q.packages, []
    assert_equal q.fpaths, ['testfile1']
    assert_equal q.suffixs, []

    q = create_query("test fire beam f:testfile1 filepath:dir32")
    assert_equal q.keywords, ['test', 'fire', 'beam']
    assert_equal q.packages, []
    assert_equal q.fpaths, ['dir32', 'testfile1']
    assert_equal q.suffixs, []

    q = create_query("package:gren test fire beam f:testfile1 filepath:dir32 s:rb p:test suffix:pl")
    assert_equal q.keywords, ['test', 'fire', 'beam']
    assert_equal q.packages, ['gren', 'test']
    assert_equal q.fpaths, ['dir32', 'testfile1']
    assert_equal q.suffixs, ['pl', 'rb']
  end

  def create_query(query)
    Query.new(Rack::Request.new({"PATH_INFO"=>"/#{URI.escape(query)}/"}))
  end
end
