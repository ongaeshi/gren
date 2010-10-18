# -*- coding: utf-8 -*-
#
# @file 
# @brief  ソースコードを表示する
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')

module Grenweb
  class Viewer
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      record = Database.instance.record(req2query)

      @response.write(<<-EOF)
<ol>
  <li>ファイルパス: #{record.shortpath}
  <li>更新時刻: #{record.timestamp}
  <li>拡張子: #{record.suffix}
</ul>
<pre>
#{record.content}
</pre>
EOF

      @response.to_a
    end

    private

    def req2query
      unescape(@request.path_info.gsub(/\A\/|\/z/, ''))
    end
  end
end
