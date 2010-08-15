# -*- coding: utf-8 -*-

module Gren
  class Util
    MAX_LINE_SIZE = 256

    def self.snip(str)
      if (str.size > MAX_LINE_SIZE)
        return str[0, MAX_LINE_SIZE]
      else
        return str
      end
    end
  end
end
