# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), 'result')
require 'rubygems'
require 'termcolor'

module Gren
  class FindGrep
    IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)/
    IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/
    
    Option = Struct.new(:ignoreCase, :colorHighlight, :isSilent, :debugMode, :filePatterns, :ignoreFiles, :ignoreDirs)
    
    def initialize(pattern, dir, option)
      @pattern = pattern
      @dir = dir
      @option = option
      @filePatterns = strs2regs(option.filePatterns)
      @patternRegexp = makePattenRegexp
      @ignoreFiles = strs2regs(option.ignoreFiles)
      @ignoreDirs = strs2regs(option.ignoreDirs)
      @result = Result.new(@dir)
    end

    def strs2regs(strs)
      regs = []
      strs.each {|v| regs << Regexp.new(v) }
      regs
    end

    def searchAndPrint(stdout)
      Find::find(@dir) { |fpath|
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

    def makePattenRegexp
      option = 0
      option |= Regexp::IGNORECASE if (@option.ignoreCase)
      Regexp.new(@pattern, option)
    end
    private :makePattenRegexp

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
          
          if (match_data = @patternRegexp.match(line))
            unless (@option.colorHighlight)
              stdout.puts "#{fpath_disp}:#{file.lineno}:#{line}"
            else
              header = "#{fpath_disp}:#{file.lineno}"
                
              begin
                stdout.puts TermColor.parse("<34>#{header}</34>:") + coloring(line, match_data[0])
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

    def coloring(line, m)
      line.split(m).join(TermColor.parse("<42>#{m}</42>"))
    end

  end
end
