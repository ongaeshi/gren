# -*- coding: utf-8 -*-
#
# @file 
# @brief  HTMLの描画ルーチン
# @author ongaeshi
# @date   2010/10/17

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
<span>#{record.content.split("\n")[0]}</span>
<span>#{record.content[1]}</span>
<span>#{record.content[2]}</span>
      </pre>
    </dd>
EOS
    end
  end
  
end


