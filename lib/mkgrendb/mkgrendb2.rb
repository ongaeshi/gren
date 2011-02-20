# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'grendbyaml')

module Mkgrendb
  class Mkgrendb2
    GREN_DB_FILE = 'db/grendb.db'
    
    def initialize(io = $stdout)
      @out = io
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
      p yaml

      db_open(GREN_DB_FILE)
    end

    def add(*content)
      # YAML更新
      yaml = GrendbYAML.load
      yaml.add(*content)
      yaml.save

      # @todo 部分アップデート
      update
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
        puts  "open       : #{dbfile} open."
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
      
  end
end
