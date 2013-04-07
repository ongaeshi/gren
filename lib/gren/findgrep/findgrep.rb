# -*- coding: utf-8 -*-
require 'find'
require 'gren/findgrep/result'
require 'rubygems'
require 'termcolor'
require 'kconv'
require 'gren/common/platform'
require 'gren/common/grenfiletest'
require 'gren/common/grensnip'
require 'gren/common/util'
include Gren
require 'cgi'

module FindGrep
  class FindGrep
    Option = Struct.new(:keywordsNot,
                        :keywordsOr,
                        :directory,
                        :depth,
                        :ignoreCase,
                        :caseSensitive,
                        :colorHighlight,
                        :isSilent,
                        :debugMode,
                        :filePatterns,
                        :suffixs,
                        :ignoreFiles,
                        :ignoreDirs,
                        :kcode,
                        :noSnip,
                        :isMatchFile)

    def self.create_default_option
      Option.new([],
                 [],
                 ".",
                 -1,
                 false,
                 false,
                 false,
                 false,
                 false,
                 [],
                 [],
                 [],
                 [],
                 Kconv::UTF8, # Platform.get_shell_kcode,
                 false,
                 false)
    end
    
    attr_reader :documents
    
    def initialize(patterns, option)
      @patterns       = patterns
      @option         = option
      @patternRegexps = strs2regs(patterns)
      @subRegexps     = strs2regs(option.keywordsNot)
      @orRegexps      = strs2regs(option.keywordsOr)
      @filePatterns   = strs2regs(option.filePatterns)
      @ignoreFiles    = strs2regs(option.ignoreFiles)
      @ignoreDirs     = strs2regs(option.ignoreDirs)
      @result         = Result.new(option.directory)
    end

    def strs2regs(strs)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (@option.ignoreCase || (!@option.caseSensitive && Util::downcase?(v)))
        regs << Regexp.new(v, option)
      end

      regs
    end

    def searchAndPrint(stdout)
      unless Util.pipe?($stdin)
        searchFromDir(stdout, @option.directory, 0)
      else
        searchData(stdout, $stdin.read.split("\n"), nil)
      end

      @result.time_stop
      
      if !@option.isSilent
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
          stdout.puts HighLine::REVERSE + "------------------------------------------------------------" + HighLine::CLEAR
        end

        @result.print(stdout)
      end
    end

    def and_expression(key, list)
      sub = nil
      
      list.each do |word|
        e = key =~ word
        if sub.nil?
          sub = e
        else
          sub &= e
        end
      end

      sub
    end

    def suffix_expression(record)
      sub = nil
      
      @option.suffixs.each do |word|
        e = record.suffix =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    private :suffix_expression
      

    def searchFromDir(stdout, dir, depth)
      if (@option.depth != -1 && depth > @option.depth)
        return
      end
      
      Dir.foreach(dir) do |name|
        next if (name == '.' || name == '..')
          
        fpath = File.join(dir,name)
        fpath_disp = fpath.gsub(/^.\//, "")
        
        # 除外ディレクトリならばパス
        if ignoreDir?(fpath)
          @result.prune_dirs << fpath_disp if (@option.debugMode)
          next;
        end

        # 読み込み不可ならばパス
        unless FileTest.readable?(fpath)
          @result.unreadable_files << fpath_disp if (@option.debugMode)
          next
        end

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchFromDir(stdout, fpath, depth + 1)
        when "file"
          searchFile(stdout, fpath, fpath_disp)
        end          
      end
    end
    private :searchFromDir

    def print_fpaths(stdout, data)
      stdout.print data.join("\n")
      stdout.puts if data.count > 0
      stdout.puts "total: #{data.count}"
      stdout.puts
    end
    private :print_fpaths

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      (GrenFileTest::ignoreDir?(File.basename(fpath)) || ignoreDirUser?(fpath))
    end
    private :ignoreDir?

    def ignoreDirUser?(fpath)
      @ignoreDirs.any? {|v| v.match File.basename(fpath) }
    end
    private :ignoreDirUser?

    def ignoreFile?(fpath)
      !correctFileUser?(fpath) ||
      GrenFileTest::ignoreFile?(fpath) ||
      ignoreFileUser?(fpath) ||
      GrenFileTest::binary?(fpath)
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

    def searchFile(stdout, fpath, fpath_disp)
      @result.count += 1
      @result.size += FileTest.size(fpath)

      # 除外ファイル
      if ignoreFile?(fpath)
        @result.ignore_files << fpath_disp if (@option.debugMode)
        return
      end
      
      @result.search_count += 1
      @result.search_size += FileTest.size(fpath)

      @result.search_files << fpath_disp if (@option.debugMode)

      open(fpath, "r") do |file|
        searchData(stdout, file2data(file), fpath_disp)
      end
    end
    private :searchFile

    def searchData(stdout, data, path)
      match_file = false

      data.each_with_index { |line, index|
        result, match_datas = match?(line)

        if ( result )
          header = path ? "#{path}:#{index + 1}:" : ""
          line = GrenSnip::snip(line, match_datas) unless (@option.noSnip)

          unless (@option.colorHighlight)
            stdout.puts header + line
          else
            stdout.puts HighLine::BLUE + header + HighLine::CLEAR + GrenSnip::coloring(line, match_datas)
          end

          unless match_file
             @result.match_file_count += 1
            @result.match_files << path if (@option.debugMode)
            match_file = true
            break if (@option.isMatchFile)
          end

          @result.match_count += 1
        end
      }
    end
    private :searchData

    def file2data(file)
      FindGrep::file2lines(file, @option.kcode)
    end
    private :file2data
    
    def self.file2lines(file, kcode)
      data = file.read
      
      unless Util::ruby19?
        if (kcode != Kconv::NOCONV)
          file_kcode = Kconv::guess(data)

          if (file_kcode != kcode)
            # puts "encode!! #{fpath} : #{kcode} <- #{file_kcode}"
            data = data.kconv(kcode, file_kcode)
          end
        end
      else
        # @memo ファイルエンコーディングに相違が起きている可能性があるため対策
        #       本当はファイルを開く時にエンコーディングを指定するのが正しい

        # 方法1 : 強制的にバイナリ化
        # data.force_encoding("Binary")
        # data = data.kconv(kcode)
        
        # 方法2 : 入力エンコーディングを強制的に指定
        data = data.kconv(kcode, Kconv::guess(data))
      end

      data = data.split($/)
    end

    def match?(line)
      match_datas = []
      @patternRegexps.each {|v| match_datas << v.match(line)}

      sub_matchs = []
      @subRegexps.each {|v| sub_matchs << v.match(line)}

      or_matchs = []
      @orRegexps.each {|v| or_matchs << v.match(line)}
      
      unless (@option.isMatchFile)
        result = match_datas.all? && !sub_matchs.any? && (or_matchs.empty? || or_matchs.any?)
      else
        result = first_condition(match_datas, sub_matchs, or_matchs)
      end
      result_match = match_datas + or_matchs
      result_match.delete(nil)

      return result, result_match
    end
    private :match?

    def first_condition(match_datas, sub_matchs, or_matchs)
      unless match_datas.empty?
        match_datas[0]
      else
        or_matchs[0]
      end
    end
  end
end
