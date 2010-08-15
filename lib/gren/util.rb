# -*- coding: utf-8 -*-

module Gren
  class Util
    MAX_LINE_SIZE = 256
    MARGIN_SIZE = 8
    DELIMITER = '<<snip>>'

    def self.snip(str)
      return str if (str.size < MAX_LINE_SIZE)

      return str[0..7] + DELIMITER + str[64..128] + DELIMITER + str[-8..-1]
    end
  end
end
