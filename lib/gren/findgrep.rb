# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), 'result')

module Gren
  class FindGrep
    IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)/
    IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/
    
    Option = Struct.new(:ignoreCase, :fpathDisp, :filePattern, :ignoreFile, :ignoreDir)
    
    def initialize(pattern, dir, option)
      @pattern = pattern
      @dir = dir
      @option = option
      @fileRegexp = Regexp.new(option.filePattern)
      @patternRegexp = makePattenRegexp
      @ignoreFile = Regexp.new(option.ignoreFile) if option.ignoreFile
      @ignoreDir = Regexp.new(option.ignoreDir) if option.ignoreDir
      @result = Result.new(@dir)
    end

    def searchAndPrint(stdout)
      Find::find(@dir) { |fpath|
        fpath_disp = fpath.gsub(/^.\//, "")
        
        # 除外ディレクトリ
        if ignoreDir?(fpath)
          @result.prune_dirs << fpath_disp if (@option.fpathDisp)
          Find.prune
        end

        # ファイルでなければ探索しない
        next unless FileTest.file?(fpath)

        @result.count += 1
        
        # 読み込み不可ならば探索しない
        unless FileTest.readable?(fpath)
          @result.unreadable_files << fpath_disp if (@option.fpathDisp)
          next
        end
        
        @result.size += FileTest.size(fpath)

        # 除外ファイル
        if ignoreFile?(fpath)
          @result.ignore_files << fpath_disp if (@option.fpathDisp)
          next
        end
        
        @result.search_count += 1
        @result.search_size += FileTest.size(fpath)

        # 検索
        searchMain(stdout, fpath, fpath_disp)
      }
      
      @result.time_stop
      
      if (@option.fpathDisp)
        stdout.puts
        stdout.puts "--- search --------"
        print_fpaths stdout, @result.search_files
        stdout.puts "--- match --------"
        print_fpaths stdout, @result.match_files
        stdout.puts "--- ignore-file --------"
        print_fpaths stdout, @result.ignore_files
        stdout.puts "--- ignore-dir --------"
        print_fpaths stdout, @result.prune_dirs
        stdout.puts "--- unreadable --------"
        print_fpaths stdout, @result.unreadable_files
      end

      stdout.puts
      @result.print(stdout)
    end

    def print_fpaths(stdout, data)
      stdout.print data.join("\n")
      stdout.puts if data.count > 0
      stdout.puts "total: #{data.count}"
      stdout.puts
    end
    private :print_fpaths

    def makePattenRegexp
      option = 0
      option |= Regexp::IGNORECASE if (@option.ignoreCase)
      Regexp.new(@pattern, option)
    end
    private :makePattenRegexp

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      (IGNORE_DIR.match(File.basename(fpath)) ||
       (@ignoreDir && @ignoreDir.match(File.basename(fpath))))
    end
    private :ignoreDir?

    def ignoreFile?(fpath)
      !@fileRegexp.match(fpath) ||
      IGNORE_FILE.match(File.basename(fpath)) ||
      (@ignoreFile && @ignoreFile.match(File.basename(fpath))) ||
      binary?(fpath)
    end
    private :ignoreFile?

    def binary?(file)
      s = File.read(file, 1024) or return false
      return s.index("\x00")
    end

    def searchMain(stdout, fpath, fpath_disp)
      @result.search_files << fpath_disp if (@option.fpathDisp)

      open(fpath, "r") { |file|
        match_file = false
        file.each() { |line|
          line.chomp!
          if (@patternRegexp.match(line))
            stdout.puts "#{fpath_disp}:#{file.lineno}:#{line}"

            unless match_file
              @result.match_file_count += 1
              @result.match_files << fpath_disp if (@option.fpathDisp)
              match_file = true
            end

            @result.match_count += 1
          end
        }
      }
    end
    private :searchMain

  end
end