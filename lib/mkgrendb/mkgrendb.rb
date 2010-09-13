# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'

require File.join(File.dirname(__FILE__), '../common/grenfiletest')

module Mkgrendb
  class Mkgrendb
    def initialize(input)
      @input_yaml = input.sub(/\.db$/, ".yaml")
      @output_db = input.sub(/\.yaml$/, ".db")
      puts "input_yaml : #{@input_yaml} found."
      @src = YAML.load(open(@input_yaml).read())
      db_create(@output_db)
    end

    def update
      db_open(@output_db)
      
      @src["directory"].each do |dir|
        db_add_dir(File.expand_path(dir))
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
          end

          schema.create_table("terms",
                              :type => :patricia_trie,
                              :key_normalize => true,
                              :default_tokenizer => "TokenBigram") do |table|
            table.index("documents.path")
            table.index("documents.content")
          end
        end
        puts "create     : #{dbfile.to_s} created."
      else
        puts "message    : #{dbfile.to_s} already exist."
      end
    end
    private :db_create
      
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
        :content => open(filename).read,
        :timestamp => File.mtime(filename),
      }
      
      # 既に登録されているファイルならばそれを上書き、そうでなければ新規レコードを作成
      documents = Groonga::Context.default["documents"]
      _documents = documents.select do |record|
        record["path"] == values[:path]
      end
      
      if _documents.size.zero?
        document = documents.add
      else
        document = _documents.to_a[0].key
      end
      
      # データベースに格納
      values.each do |key, value|
        puts value if (key == :path)
        document[key] = value
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
