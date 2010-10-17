# -*- coding: utf-8 -*-
#
# @file 
# @brief  grenwebで使用する行指向の検索
# @author ongaeshi
# @date   2010/10/18

module Grenweb
  class Grep
    def initialize(content)
      @content = content
    end

    MatchLineResult = Struct.new(:index, :line)
    
    def match_lines_or(patterns)
      result = []
      patternRegexps = strs2regs(patterns, true) # @todo ignoreオプションを付ける
      
      @content.each_with_index do |line, index|
        match_datas = []
        patternRegexps.each {|v| match_datas << v.match(line)}

        if (match_datas.any?)
          result << MatchLineResult.new(index, line)
        end
      end
      
      result
    end

    private
    
    def strs2regs(strs, ignore = false)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (ignore)
        regs << Regexp.new(v, option)
      end

      regs
    end
  end
end

