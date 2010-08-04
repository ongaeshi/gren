# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'findgrep')

module Gren
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      option = FindGrep::Option.new(".", 0, false, false, false, false, [], [], [])

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern")
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| option.directory = v}
      opt.on('--depth DEPTH', 'Limit search depth. ') {|v| option.depth = v.to_i}
      opt.on('--this', '"--depth 1"') {|v| option.depth = 1}
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('-s', '--silent', 'Silent. Display match line only.') {|v| option.isSilent = true}
      opt.on('--debug', 'Debug display.') {|v| option.debugMode = true}
      opt.on('-c', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('-f REGEXP', '--file-regexp REGEXP', 'Search file regexp. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('--if REGEXP', '--ignore-file REGEXP', 'Ignore file pattern. (Enable multiple call)') {|v| option.ignoreFiles << v}
      opt.on('--id REGEXP', '--ignore-dir REGEXP', 'Ignore dir pattern. (Enable multiple call)') {|v| option.ignoreDirs << v}
      opt.parse!(arguments)

      # 検索オブジェクトの生成
      findGrep = nil

      case ARGV.length
      when 1:
          findGrep = FindGrep.new(arguments[0], option)
      end
      
      if (findGrep)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end

    end
  end
end
