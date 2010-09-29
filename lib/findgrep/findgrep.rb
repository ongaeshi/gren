# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), 'result')
require 'rubygems'
require 'termcolor'
require 'kconv'
require File.join(File.dirname(__FILE__), '../common/platform')
require File.join(File.dirname(__FILE__), '../common/grenfiletest')
require File.join(File.dirname(__FILE__), '../common/grensnip')
require 'groonga'
require File.join(File.dirname(__FILE__), '../common/util')
include Gren

module FindGrep
  class FindGrep
    Option = Struct.new(:keywordsNot,
                        :keywordsOr,
                        :directory,
                        :depth,
                        :ignoreCase,
                        :colorHighlight,
                        :isSilent,
                        :debugMode,
                        :filePatterns,
                        :ignoreFiles,
                        :ignoreDirs,
                        :kcode,
                        :noSnip,
                        :dbFile)

    DEFAULT_OPTION = Option.new([],
                                [],
                                ".",
                                -1,
                                false,
                                false,
                                false,
                                false,
                                [],
                                [],
                                [],
                                Platform.get_shell_kcode,
                                false,
                                nil)
    
    def initialize(patterns, option)
      @patterns = patterns
      @option = option
      @patternRegexps = strs2regs(patterns, @option.ignoreCase)
      @subRegexps = strs2regs(option.keywordsNot, @option.ignoreCase)
      @orRegexps = strs2regs(option.keywordsOr, @option.ignoreCase)
      @filePatterns = (!@option.dbFile) ? strs2regs(option.filePatterns) : []
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
      unless (@option.dbFile)
        searchFromDir(stdout, @option.directory, 0)
      else
        searchFromDB(stdout, @option.directory)
      end

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
          stdout.puts HighLine::REVERSE + "------------------------------------------------------------" + HighLine::CLEAR
        end

        @result.print(stdout)
      end
    end

    def searchFromDB(stdout, dir)
      # データベース開く
      dbfile = Pathname(File.expand_path(@option.dbFile))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        puts "open    : #{dbfile} open."
      else
        raise "error    : #{dbfile.to_s} not found!!"
      end
      
      # ドキュメントを検索
      documents = Groonga::Context.default["documents"]

      # 全てのパターンを検索
      table = documents.select do |record|
        expression = nil

        # キーワード
        @patterns.each do |word|
          sub_expression = record.content =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end
        
        # パス
        @option.filePatterns.each do |word|
          sub_expression = record.path =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end

        # 検索方法
        expression
      end
      
      # 更新日時の新しい順に表示
      # 本当はGroonga::Table::sortを使いたい所だが、上手くうごかなかったので配列に変換、Array::sort_byを使う
      #
      # [前提条件]
      #  1. tableの型はGroonga::Hash
      #  2. レコードの中に timestampというtime型で作られたカラムがある
      #  3. timestampをキーにソートしたい
      #
      # [本当はこうしたい]
      # records = table.sort([{:key => "timestamp", :order => "descending"}])

      records = table.records.sort_by{|v| v.timestamp}.reverse
      

      # データベースにヒット
      stdout.puts "Found   : #{records.size} records."

      # 検索にヒットしたファイルを実際に検索
      records.each do |record|
        if FileTest.exist? record.path
          searchFile(stdout, record.path, record.path)
        end
      end
    end

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

      # 検索本体
      @result.search_files << fpath_disp if (@option.debugMode)

      open(fpath, "r") { |file|
        match_file = false

        file2data(file).each_with_index { |line, index|
          result, match_datas = match?(line)

          if ( result )
            header = "#{fpath_disp}:#{index + 1}:"
            line = GrenSnip::snip(line, match_datas) unless (@option.noSnip)

            unless (@option.colorHighlight)
              stdout.puts header + line
            else
              stdout.puts HighLine::BLUE + header + HighLine::CLEAR + GrenSnip::coloring(line, match_datas)
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
    private :searchFile

    def file2data(file)
        data = file.read

        if (@option.kcode != Kconv::NOCONV)
          file_kcode = Kconv::guess(data)

          if (file_kcode != @option.kcode)
#            puts "encode!! #{fpath} : #{@option.kcode} <- #{file_kcode}"
            data = data.kconv(@option.kcode, file_kcode)
          end
        end

        data = data.split("\n");
    end
    private :file2data

    def match?(line)
      match_datas = []
      @patternRegexps.each {|v| match_datas << v.match(line)}

      sub_matchs = []
      @subRegexps.each {|v| sub_matchs << v.match(line)}

      or_matchs = []
      @orRegexps.each {|v| or_matchs << v.match(line)}

      result = match_datas.all? && !sub_matchs.any? && (or_matchs.empty? || or_matchs.any?)
      result_match = match_datas + or_matchs
      result_match.delete(nil)

      return result, result_match
    end
    private :match?
  end
end
