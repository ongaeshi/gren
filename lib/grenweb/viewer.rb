# -*- coding: utf-8 -*-
#
# @file 
# @brief  ソースコードを表示する
# @author ongaeshi
# @date   2010/10/13

require File.join(File.dirname(__FILE__), 'grn_db')

class Viewer
  include Rack::Utils

  def initialize
  end
  
  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    response["Content-Type"] = "text/html; charset=UTF-8"
    query = req2query(request)
    record = GrnDB.instance.record(query)

    response.write(<<-EOF)
<ol>
  <li>ファイルパス: #{record.path}
  <li>更新時刻: #{record.timestamp}
  <li>拡張子: #{record.suffix}
</ul>
<pre>
#{record.content}
</pre>
EOF
    
    response.to_a
  end

  private

  def req2query(request)
    unescape(request.path_info.gsub(/\/\z/, ''))
  end
end
