# -*- coding: utf-8 -*-
#
# @file 
# @brief  HTMLの描画ルーチン
# @author ongaeshi
# @date   2010/10/17

require 'rubygems'
require 'rack'
require File.join(File.dirname(__FILE__), 'grep')

module Grenweb
  class HTMLRendeler
    include Rack::Utils

    def self.header(title, header1, isCenter = false)
      <<EOS
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <!-- <meta name="robot" content="noindex,nofollow" /> -->
  <title>#{title}</title>
</head>
<body>
#{(isCenter) ? "<div align=\"center\">\n" : ""}<div class="header">
  <h1>
    <a href="/"><img src="/images/gren-icon.png" alt="gren-icon" border="0"/></a>
    #{header1}
  </h1>
</div>

<div class="content">
EOS
    end
    
    def self.footer(isCenter = false)
      <<EOS
</div>

<div class="footer">
#{(isCenter) ? "</div>\n" : ""}</div>
</body>
</html>
EOS
    end
    
    def self.result_record(record, patterns, nth=1)
      if (patterns.size > 0)
        <<EOS
    <dt class='result-record'><a href='#{"/::view/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
    <dd>
      <pre class='lines'>
#{result_record_match_line(record, patterns, nth)}
      </pre>
    </dd>
EOS
      else
        <<EOS
    <dt class='result-record'><a href='#{"/::view/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
EOS
      end
    end

    def self.result_record_match_line(record, patterns, nth)
      str = ""
      
      grep = Grep.new(record.content)
      lines = grep.match_lines_or(patterns)

      unless (lines.empty?)
        index = lines[0].index
        
        (index - nth..index + nth).each do |i|
          if (0 <= i && i < grep.content.size)
            match_datas = (i == index) ? lines[0].match_datas : []
            str << line(i + 1, grep.content[i], match_datas) + "\n"
          end
        end
      end

      str
    end

    def self.record_content(record)
      <<EOS
<pre>
#{record_content_line(record)}
</pre>
EOS
    end
    
    def self.record_content_line(record)
      str = ""

      grep = Grep.new(record.content)
      grep.content.each_with_index do |l, index|
        str << line(index + 1, l, []) + "\n"
      end

      str
    end

    def self.line(lineno, line, match_datas)
      sprintf("%5d: %s", lineno, match_strong(Rack::Utils::escape_html(line), match_datas))
    end

    def self.match_strong(line, match_datas)
      match_datas.each do |m|
        line = line.split(m[0]).join('<strong>' + m[0] + '</strong>') unless (m.nil?)
      end
      
      line
    end

    def self.pagination_link(page, label)
      href = "./?page=#{page}"
      pagination_span("<a href='#{href}'>#{label}</a>")
    end

    def self.pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def self.empty_summary()
      <<EOS
  <div class='search-summary'>
    <p>gren web検索</p>
  </div>
EOS
    end

    def self.search_summary(keyword, total_records, range, elapsed)
      <<EOS
  <div class='search-summary'>
    <p>
      <span class="keyword">#{keyword}</span>の検索結果:
      <span class="total-entries">#{total_records}</span>件中
      <span class="display-range">#{range.first} - #{range.last}</span>件（#{elapsed}秒）
    </p>
  </div>
EOS
    end

    def self.view_summary(path, elapsed)
      <<EOS
  <div class='search-summary'>
    <p>
      <span class="keyword">#{path}</span>（#{elapsed}秒）
    </p>
  </div>
EOS
    end

    def self.search_box(text = "")
      <<EOS
<form method="post" action="/::search">
  <p>
    <input name="query" type="text" size="60" value="#{text}" />
    <input type="submit" value="検索" />
  </p>
</form>
EOS
    end

  end

end


