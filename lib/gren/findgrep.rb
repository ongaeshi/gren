# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), 'result')
require 'rubygems'
require 'termcolor'

module Gren
  class FindGrep
    IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)/
    IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/
    
    Option = Struct.new(:directory,
                        :depth,
                        :ignoreCase,
                        :colorHighlight,
                        :isSilent,
                        :debugMode,
                        :filePatterns,
                        :ignoreFiles,
                        :ignoreDirs)
    
    def initialize(patterns, option)
      @option = option
      @patternRegexps = strs2regs(patterns, @option.ignoreCase)
      @filePatterns = strs2regs(option.filePatterns)
      @ignoreFiles = strs2regs(option.ignoreFiles)
      @ignoreDirs = strs2regs(option.ignoreDirs)
      @result = Result.new(option.directory)
    end

    def strs2regs(strs, ignore = false)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (ignore)
        regs << Regexp.new(v, option)
      end

      regs
    end

    def searchAndPrint(stdout)
      Find::find(@option.directory) { |fpath|
        fpath_disp = fpath.gsub(/^.\//, "")
        
        # 除外ディレクトリ
        if ignoreDir?(fpath)
          @result.prune_dirs << fpath_disp if (@option.debugMode)
          Find.prune
        end

        # ファイルでなければ探索しない
        next unless FileTest.file?(fpath)

        @result.count += 1
        
        # 読み込み不可ならば探索しない
        unless FileTest.readable?(fpath)
          @result.unreadable_files << fpath_disp if (@option.debugMode)
          next
        end
        
        @result.size += FileTest.size(fpath)

        # 除外ファイル
        if ignoreFile?(fpath)
          @result.ignore_files << fpath_disp if (@option.debugMode)
          next
        end
        
        @result.search_count += 1
        @result.search_size += FileTest.size(fpath)

        # 検索
        searchMain(stdout, fpath, fpath_disp)
      }
      
      @result.time_stop
      
      unless (@option.isSilent)
        if (@option.debugMode)
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

        unless (@option.colorHighlight)
          stdout.puts
        else
          stdout.puts TermColor.parse("<7>------------------------------------------------------------</7>")
        end

        @result.print(stdout)
      end
    end

    def print_fpaths(stdout, data)
      stdout.print data.join("\n")
      stdout.puts if data.count > 0
      stdout.puts "total: #{data.count}"
      stdout.puts
    end
    private :print_fpaths

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      (IGNORE_DIR.match(File.basename(fpath)) || ignoreDirUser?(fpath))
    end
    private :ignoreDir?

    def ignoreDirUser?(fpath)
      @ignoreDirs.any? {|v| v.match File.basename(fpath) }
    end
    private :ignoreDirUser?

    def ignoreFile?(fpath)
      !correctFileUser?(fpath) ||
      IGNORE_FILE.match(File.basename(fpath)) ||
      ignoreFileUser?(fpath) ||
      binary?(fpath)
    end
    private :ignoreFile?

    def correctFileUser?(fpath)
      @filePatterns.empty? ||
      @filePatterns.any? {|v| v.match File.basename(fpath) }
    end
    private :correctFileUser?

    def ignoreFileUser?(fpath)
      @ignoreFiles.any? {|v| v.match File.basename(fpath) }
    end
    private :ignoreFileUser?

    def binary?(file)
      s = File.read(file, 1024) or return false
      return s.index("\x00")
    end

    def searchMain(stdout, fpath, fpath_disp)
      @result.search_files << fpath_disp if (@option.debugMode)

      open(fpath, "r") { |file|
        match_file = false
        file.each() { |line|
          line.chomp!

          result, match_datas = match?(line)

          if ( result )
            unless (@option.colorHighlight)
              stdout.puts "#{fpath_disp}:#{file.lineno}:#{line}"
            else
              header = "#{fpath_disp}:#{file.lineno}"
                
              begin
                stdout.puts TermColor.parse("<34>#{header}</34>:") + coloring(line, match_datas)
              rescue REXML::ParseException
                stdout.puts header + line
              end
            end

            unless match_file
              @result.match_file_count += 1
              @result.match_files << fpath_disp if (@option.debugMode)
              match_file = true
            end

            @result.match_count += 1
          end
        }
      }
    end
    private :searchMain

    def match?(line)
      match_datas = []
      @patternRegexps.each {|v| match_datas << v.match(line)}
      return match_datas.all?, match_datas
    end
    private :match?

    def coloring(line, match_datas)
      match_datas.each do |m|
        line = line.split(m[0]).join(TermColor.parse("<42>#{m[0]}</42>"))
      end
      line
    end
    private :coloring

  end
end
