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
    @ranges = StringSnip::ranges_conv(@ranges, @str)
    @ranges = StringSnip::ranges_sort(@ranges)
    @ranges = StringSnip::ranges_compound(@ranges)
    p @ranges

    results = []
    @ranges.each {|r| results << @str[r] }
    return results.join(@delimiter)
  end

  def self.ranges_conv(ranges, str)
    ranges.map {|i| index_conv(str, i.begin)..index_conv(str, i.end)}
  end

  def self.index_conv(str, value)
    if (value < 0)
      str.size + value
    else
      value
    end
  end

  def self.ranges_sort(ranges)
    ranges.sort_by{|i| i.begin}
  end

  def self.ranges_compound(ranges)
  end

end


