# -*- coding: utf-8 -*-
#
# @file 
# @brief  HTMLの描画ルーチン
# @author ongaeshi
# @date   2010/10/17

require File.join(File.dirname(__FILE__), 'grep')
require 'cgi'

module Grenweb
  class HTMLRendeler
    def self.header(title)
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
<div class="header">
  <h1>#{title}</h1>
</div>

<div class="content">
EOS
    end
    
    def self.footer()
      <<EOS
</div>

<div class="footer">
</div>
</body>
</html>
EOS
    end
    
    def self.result_record(record, patterns, nth=1)
      <<EOS
    <dt class='result-record'><a href='#{"../::view/" + CGI.escapeHTML(record.shortpath)}'>#{record.shortpath}</a></dt>
    <dd>
      <pre class='lines'>
#{result_record_match_line(record, patterns, nth)}
      </pre>
    </dd>
EOS
    end

    private

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

    def self.line(lineno, line, match_datas)
      sprintf("%5d: %s", lineno, match_strong(CGI.escapeHTML(line), match_datas))
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

    def self.search_box(rootpath, imgsrc, imgalt, text)
      <<EOS
<form method="post" action="#{rootpath}">
  <p>
    <a href="#{rootpath}">
      <img src="#{imgsrc}" alt="#{imgalt}"/>
    </a>
    <input name="query" type="text" value="#{text}" />
    <input type="submit" value="検索" />
  </p>
</form>
EOS
    end

  end

end


