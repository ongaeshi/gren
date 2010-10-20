# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../lib/grenweb/query')
require 'uri'

class TestGrenWebQuery < Test::Unit::TestCase
  include Grenweb

  def test_query
    q = create_query("test fire beam")
    assert_equal q.keywords, ['test', 'fire', 'beam']
    assert_equal q.package, []
    assert_equal q.filepath, []
    assert_equal q.suffix, []

    q = create_query("test fire beam f:sort")
  end

  def create_query(query)
    Query.new(Rack::Request.new({"PATH_INFO"=>"/#{URI.escape(query)}/"}))
  end
end
