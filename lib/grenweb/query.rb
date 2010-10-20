# -*- coding: utf-8 -*-
#
# @file 
# @brief  クエリーの解析
# @author ongaeshi
# @date   2010/10/21

require 'uri'

module Grenweb
  class Query
    OPTIONS = [
               ['package',  'p'],
               ['filepath', 'f'],
               ['suffix',   's'],
              ]

    def initialize(request)
      @query_string = URI.unescape(request.path_info.gsub(/\A\/|\/\z/, ''))
      parse
    end

    def keywords
      ['test', 'fire', 'beam']
    end

    def package
      []
    end

    def filepath
      []
    end

    def suffix
      []
    end

    private

    def parse
      kp = ['p', 'f', 's'].join("|")
      parts = @query_string.scan(/((?:#{kp}):)?(?:"(.+)"|(\S+))/)
      p parts
    end
  end
end

