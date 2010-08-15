# -*- coding: utf-8 -*-

class StringSnip
  def initialize(size = 256, delimiter = '<<snip>>', pri = nil)
    @size = size
    @delimiter = delimiter
    @pri = pri
  end

  def snip(str, ranges)
    @str = str
    @ranges = ranges

    # no snip
    return @str if (@str.size <= @size)

    # snip
    results = []
    @ranges.each {|r| results << @str[r] }
    return results.join(@delimiter)
  end

  def substr(index)
    @str[@ranges[index]]
  end
end


