# -*- coding: utf-8 -*-
#
# @file 
# @brief  Groongaデータベースラッパー(Singletonとして動作する)
# @author ongaeshi
# @date   2010/10/17

require File.join(File.dirname(__FILE__), 'grn_record')
require 'singleton'

class GrnDB
  include Singleton

  def initialize
    open("~/grendb/grendb.db")  # @todo 環境変数やクラス変数に逃がそう
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
    records = @documents.select { |record| record.path == path }

    records.each do |record|
      return GrnRecord.new(record)
    end
  end

  def search(patterns)
  end
end
