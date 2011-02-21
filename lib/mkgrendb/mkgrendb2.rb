# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'grendbyaml')
require File.join(File.dirname(__FILE__), '../common/grenfiletest')
require File.join(File.dirname(__FILE__), '../common/util')
include Gren

module Mkgrendb
  class Mkgrendb2
    GREN_DB_FILE = 'db/grendb.db'
    
    def initialize(io = $stdout)
      @out = io
      @file_count = 0
      @add_count = 0
      @update_count = 0
    end

    def init
      if Dir.entries('.') == [".", ".."]
        GrendbYAML.create
        @out.puts "create     : grendb.yaml"
        db_create(GREN_DB_FILE)
      else
        @out.puts "Can't create Grendb Database (Not empty) in #{Dir.pwd}"
      end
    end

    def update
      yaml = GrendbYAML.load
      db_open(GREN_DB_FILE)

      yaml.directory.each do |dir|
        update_dir(dir)
      end
    end

    def update_dir(dir)
      dir = File.expand_path(dir)

      if (!FileTest.exist?(dir))
        @out.puts "[WARNING]  : #{dir} (Not found, skip)"
      elsif (FileTest.directory? dir)
        db_add_dir(dir)
      else
        db_add_file(STDOUT, dir, File.basename(dir))
      end
    end

    def add(*content)
      # YAML更新
      yaml = GrendbYAML.load
      yaml.add(*content)
      yaml.save

      # 部分アップデート
      db_open(GREN_DB_FILE)
      content.each do |dir|
        update_dir(dir)
      end
    end

    def remove(*content)
      # YAML更新
      yaml = GrendbYAML.load
      yaml.remove(*content)
      yaml.save

      # @todo 削除したコンテンツをインデックスから削除
    end

    def list
#       GrendbYAML.load
#       @out.puts GrendbYAML.list
    end

    def rebuild
      db_delete(GREN_DB_FILE)
      db_create(GREN_DB_FILE)
      update
    end

    private

    def db_create(filename)
      dbfile = Pathname(File.expand_path(filename))
      dbdir = dbfile.dirname
      dbdir.mkpath unless dbdir.exist?
      
      unless dbfile.exist?
        Groonga::Database.create(:path => dbfile.to_s)
        Groonga::Schema.define do |schema|
          schema.create_table("documents") do |table|
            table.string("path")
            table.string("shortpath")
            table.text("content")
            table.time("timestamp")
            table.text("suffix")
          end

          schema.create_table("terms",
                              :type => :patricia_trie,
                              :key_normalize => true,
                              :default_tokenizer => "TokenBigram") do |table|
            table.index("documents.path", :with_position => true)
            table.index("documents.shortpath", :with_position => true)
            table.index("documents.content", :with_position => true)
            table.index("documents.suffix", :with_position => true)
          end
        end
        @out.puts "create     : #{filename} created."
      else
        @out.puts "message    : #{filename} already exist."
      end
    end
    
    def db_open(filename)
      dbfile = Pathname(File.expand_path(filename))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        @out.puts  "open       : #{dbfile} open."
      else
        raise "error      : #{dbfile.to_s} not found!!"
      end
    end

    def db_delete(filename)
      raise "Illegal file name : #{filename}." unless filename =~ /\.db$/
      Dir.glob("#{filename}*").each do |f|
        @out.puts "delete     : #{f}"
        FileUtils.rm_r(f)
      end
    end
    private :db_delete
      
    def db_add_dir(dirname)
      searchDirectory(STDOUT, dirname, File.basename(dirname), 0)
    end
    private :db_add_dir

    def db_add_file(stdout, filename, shortpath)
      # 格納するデータ
      values = {
        :path => filename,
        :shortpath => shortpath,
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
              @out.puts "add_file   : #{value}"
            else
              @update_count += 1
              @out.puts "update     : #{value}"
            end
          end
          document[key] = value
        end
      end

    end

    def searchDirectory(stdout, dir, shortdir, depth)
      Dir.foreach(dir) do |name|
        next if (name == '.' || name == '..')
          
        fpath = File.join(dir,name)
        shortpath = File.join(shortdir,name)
        
        # 除外ディレクトリならばパス
        next if ignoreDir?(fpath)

        # 読み込み不可ならばパス
        next unless FileTest.readable?(fpath)

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchDirectory(stdout, fpath, shortpath, depth + 1)
        when "file"
          unless ignoreFile?(fpath)
            db_add_file(stdout, fpath, shortpath)
            @file_count += 1
            @out.puts "file_count : #{@file_count}" if (@file_count % 100 == 0)
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
