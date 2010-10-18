# -*- coding: utf-8 -*-
#
# @file 
# @brief  Grenwebで使用するデータベース
# @author ongaeshi
# @date   2010/10/17

require 'groonga'
require 'pathname'
require 'singleton'

module Grenweb
  class Database
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

    def record(shortpath)
      table = @documents.select { |record| record.shortpath == shortpath }
      table.records[0]
    end

    def search(patterns, page = 0, limit = -1)
      before = Time.now

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
      
      # マッチ数
      total_records = table.size
      
      # スコアとタイムスタンプでソート
      records = table.sort([{:key => "_score", :order => "descending"},
                            {:key => "timestamp", :order => "descending"}],
                           :offset => page * limit,
                           :limit => limit)
      
      # 検索にかかった時間
      elapsed = Time.now - before

      # 結果
      return records, total_records, elapsed
    end
  end
end
