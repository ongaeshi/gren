# -*- mode: ruby; coding: utf-8 -*-
#
# @file   
# @brief  gren web検索
# @author ongaeshi
# @date   2010/10/13

require 'rubygems'
require 'rack'
require 'groonga'

# require 'rack/lobster'
require File.join(File.dirname(__FILE__), 'searcher')
require File.join(File.dirname(__FILE__), 'viewer')

use Rack::CommonLogger          
use Rack::Runtime
use Rack::Static, :urls => ["/css", "/images"], :root => "public"
use Rack::ContentLength

map '/' do
  run Searcher.new
end

map '/::view' do
  run Viewer.new
end
