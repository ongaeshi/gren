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
      init_hash
      parse
    end

    def keywords
      @hash['keywords']
    end

    def package
      @hash['package'] + @hash['p']
    end

    def filepath
      @hash['filepath'] + @hash['f']
    end

    def suffix
      @hash['suffix'] + @hash['s']
    end

    private

    def init_hash
      @hash = {}
      @hash['keywords'] = []

      OPTIONS.flatten.each do |key|
        @hash[key] = []
      end
    end

    def parse
      kp = OPTIONS.flatten.join('|')
      parts = @query_string.scan(/(?:(#{kp}):)?(?:"(.+)"|(\S+))/)

      parts.each do |key, quoted_value, value|
        unless (key)
          @hash['keywords'] << value
        else
          @hash[key] << value
        end
      end
    end
  end
end

