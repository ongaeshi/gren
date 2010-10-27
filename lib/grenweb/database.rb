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

    def self.setup(dbFile)
      @@dbFile = dbFile
    end

    def initialize
      open(@@dbFile)
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
      before = Time.now
      table = @documents.select { |record| record.shortpath == shortpath }
      elapsed = Time.now - before
      return table.records[0], elapsed
    end

    def fileNum
      @documents.select.size
    end

    def search(patterns, packages, fpaths, suffixs, page = 0, limit = -1)
      before = Time.now

      # 全てのパターンを検索
      if (fpaths.include?("*"))
        records, total_records = selectAll(page, limit)
      else
        records, total_records = searchMain(patterns, packages, fpaths, suffixs, page, limit)
      end
      
      # 検索にかかった時間
      elapsed = Time.now - before

      # 結果
      return records, total_records, elapsed
    end

    def selectAll(page, limit)
      table = @documents.select

      # マッチ数
      total_records = table.size
      
      # スコアとタイムスタンプでソート
      records = table.sort([{:key => "shortpath", :order => "descending"}],
                           :offset => page * limit,
                           :limit => limit)

      return records, total_records
    end

    def searchMain(patterns, packages, fpaths, suffixs, page, limit)
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
        
        # パッケージ(OR)
        pe = package_expression(record, packages) 
        if (pe)
          if expression.nil?
            expression = pe
          else
            expression &= pe
          end
        end
        
        # ファイルパス
        fpaths.each do |word|
          sub_expression = record.path =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end

        # 拡張子(OR)
        se = suffix_expression(record, suffixs) 
        if (se)
          if expression.nil?
            expression = se
          else
            expression &= se
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

      return records, total_records
    end
    private :searchMain

    def package_expression(record, packages)
      sub = nil
      
      # @todo 専用カラム package が欲しいところ
      #       でも今でもpackageはORとして機能してるからいいっちゃいい
      packages.each do |word|
        e = record.path =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    private :package_expression

    def suffix_expression(record, suffixs)
      sub = nil
      
      suffixs.each do |word|
        e = record.suffix =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    private :suffix_expression
    
  end
end
