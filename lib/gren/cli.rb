# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'findgrep')

module Gren
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      option = FindGrep::Option.new(false, false, false, ".", [], [])

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern [dir]")
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('-l', '--listing', 'The searched file name is displayed.') {|v| option.fpathDisp = true}
      opt.on('-c', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('-f REGEXP', '--file-regexp REGEXP', 'Search file regexp. (Enable multiple call)') {|v| option.filePattern = v}
      opt.on('--if REGEXP', '--ignore-file REGEXP', 'Ignore file pattern. (Enable multiple call)') {|v| option.ignoreFiles << v}
      opt.on('--id REGEXP', '--ignore-dir REGEXP', 'Ignore dir pattern. (Enable multiple call)') {|v| option.ignoreDirs << v}
      opt.parse!(arguments)

      # 検索オブジェクトの生成
      findGrep = nil

      case ARGV.length
      when 1:
          findGrep = FindGrep.new(arguments[0], '.', option)
      when 2:
          findGrep = FindGrep.new(arguments[0], arguments[1], option)
      end
      
      if (findGrep)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end

    end
  end
end
