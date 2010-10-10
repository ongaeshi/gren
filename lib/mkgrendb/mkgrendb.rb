# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require File.join(File.dirname(__FILE__), '../common/grenfiletest')
require File.join(File.dirname(__FILE__), '../common/util')
include Gren

module Mkgrendb
  class Mkgrendb
    def initialize(input)
      input = File.expand_path(input)
      @input_yaml = input.sub(/\.db$/, ".yaml")
      @output_db = input.sub(/\.yaml$/, ".db")
      puts "input_yaml : #{@input_yaml} found."
      @src = YAML.load(open(@input_yaml).read())
      @file_count = 0
      @add_count = 0
      @update_count = 0
      @start_time = Time.now
    end

    def update
      db_create(@output_db)
      db_open(@output_db)
      @src["directory"].each do |dir|
        dir = File.expand_path(dir)
        if (FileTest.directory? dir)
          db_add_dir(dir)
        else
          db_add_file(STDOUT, dir)
        end
      end
      @end_time = Time.now
      print_result
    end

    def delete
      db_delete(@output_db)
    end

    def full
      delete
      update
    end

    def time
      @end_time - @start_time 
    end

    def print_result
      puts
      puts "input_yaml : #{@input_yaml} (#{Util::time_s(time)})"
      puts "output_db  : #{@output_db}*"
      puts "files      : #{@file_count}"
      puts "add        : #{@add_count}"
      puts "update     : #{@update_count}"
    end

    def dump()
      db_open(@output_db)

      documents = Groonga::Context.default["documents"]
      records = documents.select
      records.each do |record|
        p record
        puts "path : #{record.path}"
        puts "suffix : #{record.suffix}"
        puts "timestamp : #{record.timestamp.strftime('%Y/%m/%d %H:%M:%S')}"
        puts "content :", record.content ? record.content[0..64] : nil
        puts
      end
    end

    def db_create(filename)
      dbfile = Pathname(File.expand_path(filename))
      dbdir = dbfile.dirname
      dbdir.mkpath unless dbdir.exist?
      
      unless dbfile.exist?
        Groonga::Database.create(:path => dbfile.to_s)
        Groonga::Schema.define do |schema|
          schema.create_table("documents") do |table|
            table.string("path")
            table.text("content")
            table.time("timestamp")
            table.text("suffix")
          end

          schema.create_table("terms",
                              :type => :patricia_trie,
                              :key_normalize => true,
                              :default_tokenizer => "TokenBigram") do |table|
            table.index("documents.path", :with_position => true)
            table.index("documents.content", :with_position => true)
            table.index("documents.suffix", :with_position => true)
          end
        end
        puts "create     : #{filename} created."
      else
        puts "message    : #{filename} already exist."
      end
    end
    private :db_create

    def db_delete(filename)
      raise "Illegal file name : #{filename}." unless filename =~ /\.db$/
      Dir.glob("#{filename}*").each do |f|
        puts "delete     : #{f}"
        File.unlink(f)
      end
    end
    private :db_delete
      
    def db_open(filename)
      dbfile = Pathname(File.expand_path(filename))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        puts  "open       : #{dbfile} open."
      else
        raise "error      : #{dbfile.to_s} not found!!"
      end
    end
    private :db_open

    def db_add_dir(dirname)
      searchDirectory(STDOUT, dirname, 0)
    end
    private :db_add_dir

    def db_add_file(stdout, filename)
      # 格納するデータ
      values = {
        :path => filename,
        :content => nil,
        :timestamp => File.mtime(filename),
        :suffix => File::extname(filename),
      }
      
      # 検索するデータベース
      documents = Groonga::Context.default["documents"]
      
      # 既に登録されているファイルならばそれを上書き、そうでなければ新規レコードを作成
      _documents = documents.select do |record|
        record["path"] == values[:path]
      end
      
      isNewFile = false

      if _documents.size.zero?
        document = documents.add
        isNewFile = true
      else
        document = _documents.to_a[0].key
      end
      
      # タイムスタンプが新しければデータベースに格納
      if (document[:timestamp] < values[:timestamp])
        # 実際に使うタイミングでファイルの内容を読み込み
        values[:content] = open(filename).read
        
        # データベースに格納
        values.each do |key, value|
          if (key == :path)
            if (isNewFile)
              @add_count += 1
              puts "add_file   : #{value}"
            else
              @update_count += 1
              puts "update     : #{value}"
            end
          end
          document[key] = value
        end
      end

    end

    def searchDirectory(stdout, dir, depth)
      Dir.foreach(dir) do |name|
        next if (name == '.' || name == '..')
          
        fpath = File.join(dir,name)
        fpath_disp = fpath.gsub(/^.\//, "")
        
        # 除外ディレクトリならばパス
        next if ignoreDir?(fpath)

        # 読み込み不可ならばパス
        next unless FileTest.readable?(fpath)

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchDirectory(stdout, fpath, depth + 1)
        when "file"
          unless ignoreFile?(fpath)
            db_add_file(stdout, fpath)
            @file_count += 1
            puts "file_count : #{@file_count}" if (@file_count % 100 == 0)
          end
        end          
      end
    end

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      GrenFileTest::ignoreDir?(fpath)
    end
    private :ignoreDir?

    def ignoreFile?(fpath)
      GrenFileTest::ignoreFile?(fpath) ||
      GrenFileTest::binary?(fpath)
    end
    private :ignoreFile?

  end
end
