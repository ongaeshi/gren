# -*- coding: utf-8 -*-
require 'optparse'
require 'gren/findgrep/findgrep'

module Gren
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      option = FindGrep::FindGrep::create_default_option
      option.isSilent = true

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern")
      opt.on('--not PATTERN', 'Keyword is not included.') {|v| option.keywordsNot << v}
      opt.on('--or PATTERN', 'Either of keyword is contained.') {|v| option.keywordsOr << v}
      opt.on('-c', '--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--cs', '--case-sensitive', 'Case sensitivity.') {|v| option.caseSensitive = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| option.directory = v}
      opt.on('--debug', 'Debug display.') {|v| option.debugMode = true}
      opt.on('--depth DEPTH', 'Limit search depth. ') {|v| option.depth = v.to_i}
      opt.on('-e ENCODE', '--encode ENCODE', 'Specify encode(none, auto, jis, sjis, euc, ascii, utf8, utf16). Default is "auto"') {|v| setupEncodeOption(option, v) }
      opt.on('-f REGEXP', '--file-regexp REGEXP', 'Search file regexp. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('--id REGEXP', '--ignore-dir REGEXP', 'Ignore dir pattern. (Enable multiple call)') {|v| option.ignoreDirs << v}
      opt.on('--if REGEXP', '--ignore-file REGEXP', 'Ignore file pattern. (Enable multiple call)') {|v| option.ignoreFiles << v}
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('--silent', 'Silent. Display match line only.') {|v| option.isSilent = true}
      opt.on('--this', '"--depth 0"') {|v| option.depth = 0}
      opt.on('-v', '--verbose', 'Set the verbose level of output.') {|v| option.isSilent = false }
      opt.parse!(arguments)

      # 検索オブジェクトの生成
      if (arguments.size > 0 || option.keywordsOr.size > 0 || Util.pipe?($stdin))
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end

    end

    def self.setupEncodeOption(option, encode)
      case encode.downcase
      when 'none'
        option.kcode = Kconv::NOCONV
      when 'auto'
        option.kcode = Platform.get_shell_kcode
      when 'jis'
        option.kcode = Kconv::JIS
      when 'sjis'
        option.kcode = Kconv::SJIS
      when 'euc'
        option.kcode = Kconv::EUC
      when 'ascii'
        option.kcode = Kconv::ASCII
      when 'utf8'
        option.kcode = Kconv::UTF8
      when 'utf16'
        option.kcode = Kconv::UTF16
      else
        puts "Invalid encode."
        puts "  none, auto, jis, sjis, euc, ascii, utf8, utf16"
        exit(-1)
      end
    end
    
  end
end
