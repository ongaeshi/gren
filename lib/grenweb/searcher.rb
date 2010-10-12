# -*- coding: utf-8 -*-
#
# @file 
# @brief  検索処理本体
# @author ongaeshi
# @date   2010/10/13

require File.join(File.dirname(__FILE__), 'groonga_wrapper')

class Searcher
  include Rack::Utils

  def initialize
  end
  
  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new

    response["Content-Type"] = "text/html; charset=UTF-8"

    if request.post? or request['query']
      post_request(request, response)
    else
      search(request, response)
    end
  end

  private

  def post_request(request, response)
    query = request['query'] || ''
    if query.empty?
      request.path_info = "/"
    else
      request.path_info = "/#{escape(query)}/"
    end
    response.redirect(request.url.split(/\?/, 2)[0])
    response.to_a
  end

  def search(request, response)
    render_header(request, response)
    render_search_box(request, response)
    render_search_result(request, response)

    render_footer(request, response)
    response.to_a
  end

  def render_header(request, response)
    response.write(<<-EOH)
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <!-- <meta name="robot" content="noindex,nofollow" /> -->
  <title>gren web検索</title>
</head>
<body>
<div class="header">
  <h1>gren web検索</h1>
</div>

<div class="content">
EOH
  end

  def render_search_box(request, response)
    response.write(<<-EOF)
<form method="post" action="#{path(request, '')}">
  <p>
    <a href="#{path(request, '')}">
      <img src="#{path(request, 'images/mini-gren.png')}" alt="gren"/>
    </a>
    <input name="query" type="text" value="#{escape_html(query(request))}" />
    <input type="submit" value="検索" />
  </p>
</form>
EOF
  end

  def render_search_result(request, response)
    _query = query(request)
    _page = page(request)
    limit = 20

    if _query.empty?
      records = []
      response.write(<<-EOS)
  <div class='search-summary'>
    <p>Rubyでgroonga使って全文検索</p>
  </div>
EOS
    else
      records, total_records, elapsed = GroongaWrapper.instance.search(_query, _page, limit)
      
      response.write(<<-EOS)
  <div class='search-summary'>
    <p>
      <span class="keyword">#{escape_html(query(request))}</span>の検索結果:
      <span class="total-entries">#{total_records}</span>件中
      <span class="display-range">
        #{total_records.zero? ? 0 : (_page * limit) + 1}
        -
        #{(_page * limit) + records.size}
      </span>
      件（#{elapsed}秒）
    </p>
  </div>
EOS
    end
    
    response.write("  <div class='records'>\n")

    records.each do |record|
#      render_record(request, response, record)
    end

    response.write("  </div>\n")
    
#    render_pagination(request, response, _page, limit, total_records)
  end

  def render_footer(request, response)
    response.write(<<-EOF)
</div>

<div class="footer">
</div>
</body>
</html>
EOF
  end
  
  def query(request)
    unescape(request.path_info.gsub(/\A\/|\/\z/, ''))
  end

  def page(request)
    (request['page'] || 0).to_i
  end
  
  def path(request, component='')
    escape_html("#{request.script_name}/#{component}")
  end
  
end


