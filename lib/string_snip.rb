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
    p @ranges
    @ranges = @ranges.map {|i| index_conv(@str, i.begin)..index_conv(@str, i.end)}
    @ranges = @ranges.sort_by{|i| i.begin}
    p @ranges

    results = []
    @ranges.each {|r| results << @str[r] }
    return results.join(@delimiter)
  end

  def index_conv(str, value)
    if (value < 0)
      str.size + value
    else
      value
    end
  end
  private :index_conv

  def substr(index)
    @str[@ranges[index]]
  end
end


