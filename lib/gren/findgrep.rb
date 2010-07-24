# -*- coding: utf-8 -*-
require 'find'
require 'benchmark'

module Gren
  class Result
    attr_accessor :count
    attr_accessor :search_count
    attr_accessor :match_file
    attr_accessor :match_count
    attr_accessor :size

    def initialize(start_dir)
      @start_dir = start_dir
      @count = 0
      @search_count = 0
      @match_file = 0
      @match_count = 0
      @size = 0
      @start_time = Process.times
      @end_time = nil
    end

    def time_stop
      @end_time = Process.times
    end

    def time
      s = @start_time
      e = @end_time
      e.utime - s.utime + e.stime - s.stime
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end

    def size_s
      if (@size > 1024 * 1024)
       (round(@size / (1024 * 1024.0), 2)).to_s + "MB"
      elsif (@size > 1024)
        (round(@size / 1024.0, 2)).to_s + "KB"
      else
        @size.to_s + "Byte"
      end
    end

    def print(stdout)
      puts @count, @search_count, @match_file, @match_count, size_s, time
    end

  end
  
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
        
        # 除外ファイル
        next if ignoreFile?(fpath)
        
        @result.search_count += 1
        @result.size += FileTest.size(fpath)

        # 行頭の./は削除
        fpath.gsub!(/^.\//, "");

        # 検索
        searchMain(stdout, fpath)
      }
      
      @result.time_stop
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
      FileTest.readable?(fpath) &&
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
