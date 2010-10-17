# -*- coding: utf-8 -*-
#
# @file 
# @brief  Groongaデータベース、レコード
# @author ongaeshi
# @date   2010/10/17

class GrnRecord
  def initialize(r)
    @r = r
  end
  
  def content
    @r.content
  end

  def path
    @r.path
  end

  def timestamp
    @r.timestamp
  end

  def suffix
    @r.suffix
  end

  def line(lineNo)
    @r.content.to_a
  end
end
