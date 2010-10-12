# -*- mode: ruby; coding: utf-8 -*-
#
# @file   
# @brief  gren web検索
# @author ongaeshi
# @date   2010/10/13

require 'rubygems'
require 'rack'
require 'groonga'

require 'rack/lobster'

use Rack::CommonLogger          
use Rack::Runtime
use Rack::Static, :urls => ["/css", "/images"], :root => "public"
use Rack::ContentLength

# @todo 引数や環境変数で渡せるようにする
Groonga::Database.new(File.expand_path("~/grendb/grendb.db"))

map '/' do
  run Rack::Lobster.new
end

map '/::view' do
  run Rack::Lobster.new
end
