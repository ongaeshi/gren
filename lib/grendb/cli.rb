# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), '../findgrep/findgrep')

module Grendb
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      option = FindGrep::FindGrep::DEFAULT_OPTION
      option.dbFile = ENV['GRENDB_DEFAULT_DB']

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] keyword1 [keyword2 ...]")
      opt.on('--db [GREN_DB_FILE]', 'Search from the grendb database.') {|v| option.dbFile = v }
      opt.on('-f KEYWORD', '--file-regexp KEYWORD', 'Path keyword. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('--if KEYWORD', '--ignore-file KEYWORD', 'Ignore path keyword. (Enable multiple call)') {|v| option.ignoreFiles << v}
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}

      opt.parse!(arguments)

      # 検索オブジェクトの生成
      if (option.dbFile && (arguments.size > 0 || option.keywordsOr.size > 0))
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
        stdout.puts
        stdout.puts "please set GREN DATABSE FILE!! (--db option, or set ENV['GRENDB_DEFAULT_DB'].)" unless option.dbFile
      end

    end
  end
end
