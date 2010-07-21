# -*- coding: utf-8 -*-
require "find"
require 'optparse'

module Gren
  class FindGrep
    attr_writer :ignoreCase
    attr_writer :fpathDisp
    
    def initialize(pattern, dir, filePattern)
      @pattern = pattern
      @dir = dir
      @filePattern = filePattern
      @ignoreCase = false
      @fpathDisp = false
    end

    def searchAndPrint(stdout)
      fileRegexp = Regexp.new(@filePattern)
      patternRegexp = makePattenRegexp
      
      Find::find(@dir) { |fpath|
        if (File.file?(fpath) &&
            fileRegexp.match(fpath) &&
            fpath !~ /(\.svn)|(\.git)|(CVS)/)       # .svn, .git ディレクトリは無視

          # ファイルパスを表示
          if (@fpathDisp)
            stdout.print "#{fpath}"
          end

          # 検索
          open(fpath, "r") { |file| 
            file.each() { |line|
              line.chomp!
              if (patternRegexp.match(line))
                if (!@fpathDisp)
                  stdout.print "#{fpath}:#{file.lineno}:#{line}\n"
                else
                  # 隠しコマンド
                  #   patternに"."を渡した時はFound patternを表示しない
                  #   ファイル名一覧を取得する時等に便利
                  stdout.print " ........ Found pattern." unless (@pattern == ".")
                  break
                end
              end
            }
          }

          # 改行
          stdout.puts if (@fpathDisp)

        end
      }
    end

    def makePattenRegexp
      option = 0
      option |= Regexp::IGNORECASE if (@ignoreCase)
      Regexp.new(@pattern, option)
    end
    private :makePattenRegexp
  end

  class CLI
    DEFAULT_DIR = '.'
    DEFAULT_FILE_PATTERN = '(\.cpp$)|(\.c$)|(\.h$)|(\.hpp$)|(\.csv$)|(makefile$)|(makefile\.[0-9A-Za-z]+$)|(\.mk$)|(\.rb$)|(\.ags$)'

    def self.execute(stdout, arguments=[])
      # オプション
      ignoreCase = false
      fpathDisp = false

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern [dir] [file_pattern] [fpath]")
      opt.on('-i', '大文字と小文字を無視する') {|v| ignoreCase = true}
      opt.on('-f', '検索対象に含めたファイルを表示') {|v| fpathDisp = true}
      opt.parse!(arguments)

      # 検索オブジェクトの生成
      findGrep = nil

      case ARGV.length
      when 1:
          findGrep = FindGrep.new(arguments[0],
                                  DEFAULT_DIR,
                                  DEFAULT_FILE_PATTERN)
      when 2:
          findGrep = FindGrep.new(arguments[0],
                                  arguments[1],
                                  DEFAULT_FILE_PATTERN)
      when 3:
          findGrep = FindGrep.new(arguments[0],
                                  arguments[1],
                                  arguments[2])
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
