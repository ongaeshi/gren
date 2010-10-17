# -*- coding: utf-8 -*-
#
# @file 
# @brief  Grenwebで使用するデータベース
# @author ongaeshi
# @date   2010/10/17

require File.join(File.dirname(__FILE__), 'grn_record')
require File.join(File.dirname(__FILE__), '../common/util')
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

    def record(path)
      table = @documents.select { |record| record.path == path }
      table.records[0]
    end

    def search(patterns)
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

      # 結果
      records
    end
  end
end
