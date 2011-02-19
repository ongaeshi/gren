# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'

module Mkgrendb
  class Mkgrendb2
    def initialize()
    end

    def init
      # 空じゃ無かったら警告を出して終了
      # yamlファイルの追加
      db_create('db/grendb.db')
    end

    def update
      puts "update"
    end

    def add
      puts "add"
    end

    def list
      puts "list"
    end

    def rebuild
      db_delete('db/grendb.db')
      db_create('db/grendb.db')
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
        puts "create     : #{filename} created."
      else
        puts "message    : #{filename} already exist."
      end
    end
    
    def db_delete(filename)
      raise "Illegal file name : #{filename}." unless filename =~ /\.db$/
      Dir.glob("#{filename}*").each do |f|
        puts "delete     : #{f}"
        FileUtils.rm_r(f)
      end
    end
    private :db_delete
      
  end
end
