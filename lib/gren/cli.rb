# -*- coding: utf-8 -*-
require "find"
require 'optparse'

module Gren
  class FindGrep
    DEFAULT_FPATH_PATTERN = '(\.svn)|(\.git)|(CVS)|(\.o$)|(\.lo$)|(\.la$)|(^#.*#$)|(~$)|(^.#)|(^\.DS_Store$)|(\.bak$)|(\.BAK$)'
    IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)/
    IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/
    
    attr_writer :ignoreCase
    attr_writer :fpathDisp
    
    def initialize(pattern, dir = '.', filePattern = '.')
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
        if (FileTest.directory?(fpath))
          Find.prune if IGNORE_DIR.match File.basename(fpath)
        end

        if (FileTest.file?(fpath) &&
            FileTest.readable?(fpath) &&
            !binary?(fpath) &&
            fileRegexp.match(fpath) &&
            !IGNORE_FILE.match(File.basename(fpath)))

          # 行頭の./は削除
          fpath.gsub!(/^.\//, "");

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

    def binary?(file)
      s = File.read(file, 1024) or return false
      return s.index("\x00")
    end
  end

  class CLI
    def self.execute(stdout, arguments=[])
      # オプション
      ignoreCase = false
      fpathDisp = false

      # オプション解析
      opt = OptionParser.new("#{File.basename($0)} [option] pattern [dir] [file_pattern] [fpath]")
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
