# -*- coding: utf-8 -*-

module Gren
  class Util
    MAX_LINE_SIZE = 256
    MARGIN_SIZE = 8
    DELIMITER = '<<snip>>'

    def self.snip(str, match_datas)
      return str if (str.size <= MAX_LINE_SIZE)

#      p match_datas[0]
#      p str.split(match_datas[0][0])
#      p match_datas[0].pre_match, match_datas[0].post_match
#      p match_datas[0].begin(0), match_datas[0].end(0)
      return str[0..7] + DELIMITER + str[64..128] + DELIMITER + str[-8..-1]

#      match_datas.each do |m|
#        line = line.split(m[0]).join("<42>#{m[0]}</42>"))
#      end

#      return str[0, MAX_LINE_SIZE]
    end
  end
end


