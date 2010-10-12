# -*- coding: utf-8 -*-
#
# @file 
# @brief  groongaラッパー
# @author ongaeshi
# @date   2010/10/13

require 'singleton'

class GroongaWrapper
  include Singleton

  def initialize
    @documents = Groonga::Context.default["documents"]
  end
  
  def search(query, page, limit = 20)
    before = Time.now
    
    records = @documents.select do |record|
      record["content"].match(query)
    end
    
    total_records = records.size
    records = records.sort([["_score", "descending"],
                            ["timestamp", "descending"]],
                           :offset => page * limit,
                           :limit => limit)
    elapsed = Time.now - before

    return records, elapsed
  end
end

