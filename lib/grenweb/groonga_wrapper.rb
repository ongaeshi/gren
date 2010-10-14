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
  end
  
  def searchAndPrint(query, io)
    option = FindGrep::FindGrep::DEFAULT_OPTION
    
    # @todo 引数や環境変数で渡せるようにする
    option.dbFile = ENV['GRENDB_DEFAULT_DB']
    
    # デフォルトのマッチモードは'File'
    option.isMatchFile = true

    # ファイルは探索しない
    option.groongaOnly = true

    # HTMLで出力
    option.dispHtml = true
    
    # 省略しない
    option.noSnip = true
    
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
end

