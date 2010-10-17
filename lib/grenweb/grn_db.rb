# -*- coding: utf-8 -*-
#
# @file 
# @brief  Groongaデータベースラッパー(Singletonとして動作する)
# @author ongaeshi
# @date   2010/10/17

require File.join(File.dirname(__FILE__), 'grn_record')
require File.join(File.dirname(__FILE__), '../common/util')
require 'singleton'

class GrnDB
  include Singleton

  def initialize
    open("~/grendb/grendb.db")  # @todo 環境変数やクラス変数に逃がす
  end

  def open(dbFile)
    dbfile = Pathname(File.expand_path(dbFile))
    
    if dbfile.exist?
      Groonga::Database.open(dbfile.to_s)
    else
      raise "error    : #{dbfile.to_s} not found!!"
    end

    @documents = Groonga::Context.default["documents"]
  end

  def record(path)
    table = @documents.select { |record| record.path == path }
    table.records[0]
  end

  def search(patterns)
    Result = Struct.new(:record, :lines)
    searchFromDB(patterns)
  end

  private

  def searchFromDB(patterns)
    # 全てのパターンを検索
    table = @documents.select do |record|
      expression = nil

      # キーワード
      patterns.each do |word|
        sub_expression = record.content =~ word
        if expression.nil?
          expression = sub_expression
        else
          expression &= sub_expression
        end
      end
      
      # 検索式
      expression
    end
    
    # スコアとタイムスタンプでソート
    records = table.sort([{:key => "_score", :order => "descending"},
                          {:key => "timestamp", :order => "descending"}])

    # 検索にヒットしたファイルを実際に検索
    records.each do |record|
      searchData(patterns, record)
    end
  end

  def searchData(patterns, record)
    data = record.content

    data.each_with_index { |line, index|
      result, match_datas = match?(patterns, line)

      if ( result )
        line_no = index + 1
        line = GrenSnip::snip(line, match_datas) unless (@option.noSnip)
        
        stdout.puts <<EOF
<h2><a href="../::view#{path}">#{path}</a></h2>
<pre>
#{line_no} : #{CGI.escapeHTML(line)}
</pre>
EOF
      end
    }
  end
  
  def match?(patterns, line)
    match_datas = []
    patterns.each {|v| match_datas << v.match(line)}

    unless (@option.isMatchFile)
      result = match_datas.all? && !sub_matchs.any? && (or_matchs.empty? || or_matchs.any?)
    else
      result = first_condition(match_datas, sub_matchs, or_matchs)
    end
    result_match = match_datas + or_matchs
    result_match.delete(nil)

    return result, result_match
  end
end
