# -*- coding: utf-8 -*-
#
# @file 
# @brief  groongaラッパー
# @author ongaeshi
# @date   2010/10/13

require 'singleton'
require File.join(File.dirname(__FILE__), '../findgrep/findgrep')

class GroongaWrapper
  include Singleton

  def initialize
    # @todo 引数や環境変数で渡せるようにする
    # Groonga::Database.new(File.expand_path("~/grendb/grendb.db"))
  end
  
  def search(query, page, limit = 20)
    before = Time.now
    
    records = documents.select do |record|
      record["content"].match(query)
    end

    total_records = records.size
    
    records = records.sort([["_score", "descending"],
                            ["timestamp", "descending"]],
                           :offset => page * limit,
                           :limit => limit)

    elapsed = Time.now - before

    return records, total_records, elapsed
  end

  def searchAndPrint(query, io)
    option = FindGrep::FindGrep::DEFAULT_OPTION
    option.dbFile = ENV['GRENDB_DEFAULT_DB']
    
    # デフォルトのマッチモードは'File'
    option.isMatchFile = true

    # ファイルは探索しない
    option.groongaOnly = true
    
    # 探索
    findGrep = FindGrep::FindGrep.new(query, option)
    findGrep.searchAndPrint(io)
  end

  def searchPath(path)
    records = documents.select do |record|
      record.path == path
    end

    records.each do |record|
      return record
    end
  end

  private 

  def documents
    Groonga::Context.default["documents"]
  end
end

