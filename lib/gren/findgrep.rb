# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), 'result')

module Gren
  class FindGrep
#    DEFAULT_FPATH_PATTERN = '(\.svn)|(\.git)|(CVS)|(\.o$)|(\.lo$)|(\.la$)|(^#.*#$)|(~$)|(^.#)|(^\.DS_Store$)|(\.bak$)|(\.BAK$)'
    IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)/
    IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/    
    
    attr_writer :ignoreCase
    attr_writer :fpathDisp
    
    def initialize(pattern, dir = '.', filePattern = '.')
      @pattern = pattern
      @dir = dir
      @fileRegexp = Regexp.new(filePattern)
      @ignoreCase = false
      @fpathDisp = false
      @patternRegexp = makePattenRegexp
      @result = Result.new(@dir)
    end

    def searchAndPrint(stdout)
      Find::find(@dir) { |fpath|
        # 除外ディレクトリ
        Find.prune if ignoreDir?(fpath)

        # ファイルでなければ探索しない
        next unless FileTest.file?(fpath)

        @result.count += 1
        
        # 読み込み不可ならば探索しない
        next unless FileTest.readable?(fpath)
        
        @result.size += FileTest.size(fpath)

        # 除外ファイル
        next if ignoreFile?(fpath)
        
        @result.search_count += 1
        @result.search_size += FileTest.size(fpath)

        # 行頭の./は削除
        fpath.gsub!(/^.\//, "");

        # 検索
        searchMain(stdout, fpath)
      }
      
      @result.time_stop
      stdout.puts
      @result.print(stdout)
    end

    def makePattenRegexp
      option = 0
      option |= Regexp::IGNORECASE if (@ignoreCase)
      Regexp.new(@pattern, option)
    end
    private :makePattenRegexp

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      IGNORE_DIR.match(File.basename(fpath))
    end
    private :ignoreDir?

    def readFile?(fpath)
      @fileRegexp.match(fpath) &&        
      !IGNORE_FILE.match(File.basename(fpath)) &&
      !binary?(fpath)
    end
    private :readFile?

    def ignoreFile?(fpath)
      !readFile?(fpath)
    end
    private :ignoreFile?

    def binary?(file)
      s = File.read(file, 1024) or return false
      return s.index("\x00")
    end

    def searchMain(stdout, fpath)
      # ファイルパスを表示
      stdout.print "#{fpath}" if (@fpathDisp)

      open(fpath, "r") { |file|
        match_file = false
        file.each() { |line|
          line.chomp!
          if (@patternRegexp.match(line))
            if (!@fpathDisp)
              stdout.print "#{fpath}:#{file.lineno}:#{line}\n"
            else
              # 隠しコマンド
              #   patternに"."を渡した時はFound patternを表示しない
              #   ファイル名一覧を取得する時等に便利
              stdout.print " ........ Found pattern." unless (@pattern == ".")
            end

            unless match_file
              @result.match_file += 1
              match_file = true
            end

            @result.match_count += 1
          end
        }
      }

      # 改行
      stdout.puts if (@fpathDisp)
    end
    private :searchMain

  end
end