# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'findgrep')

module Gren
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      ignoreCase = false
      fpathDisp = false

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern [dir] [filename_regexp]")
      opt.on('-i', 'Ignore case.') {|v| ignoreCase = true}
      opt.on('-f', 'The searched file name is displayed.') {|v| fpathDisp = true}
      opt.parse!(arguments)

      # 検索オブジェクトの生成
      findGrep = nil

      case ARGV.length
      when 1:
          findGrep = FindGrep.new(arguments[0])
      when 2:
          findGrep = FindGrep.new(arguments[0], arguments[1])
      when 3:
          findGrep = FindGrep.new(arguments[0], arguments[1], arguments[2])
      end
      
      if (findGrep)
        # オプション設定
        findGrep.ignoreCase = ignoreCase
        findGrep.fpathDisp = fpathDisp
        
        # 検索
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end

    end
  end
end
