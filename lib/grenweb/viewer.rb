# -*- coding: utf-8 -*-
#
# @file 
# @brief  ソースコードを表示する
# @author ongaeshi
# @date   2010/10/13

class Viewer
  include Rack::Utils

  def initialize
    @documents = Groonga::Context.default["documents"]
  end
  
  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new
    response["Content-Type"] = "text/html; charset=UTF-8"
    qry = query(request)

    records = @documents.select do |record|
      record.path == qry
    end

    records.each do |record|
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
    end
    
    response.to_a
  end

  private

  def query(request)
    unescape(request.path_info.gsub(/\/\z/, ''))
  end
end
