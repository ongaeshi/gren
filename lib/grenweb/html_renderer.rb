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
    
    def self.result_record(record, patterns)
      <<EOS
    <dt class='search-result'>#{record.path}</dt>
    <dd>
      <pre class='lines'>
#{result_record_match_line(record, patterns)}
      </pre>
    </dd>
EOS
    end

    private

    def self.result_record_match_line(record, patterns)
      lines = Grep.new(record.content).match_lines_or(patterns)

      unless (lines.empty?)
        "#{lines[0].index + 1} : #{CGI.escapeHTML(lines[0].line)}" # 最小にマッチした行の前後を表示
      end
    end
  end

end


