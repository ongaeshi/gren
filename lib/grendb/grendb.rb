# -*- coding: utf-8 -*-

require 'yaml'

require 'pathname'

base_directory = Pathname(__FILE__).dirname + ".."
$LOAD_PATH.unshift((base_directory + "ext").to_s)
$LOAD_PATH.unshift((base_directory + "lib").to_s)

require 'rubygems'
require 'groonga'

module Grendb
  class Grendb
    def initialize(input_yaml)
      @output_db = input_yaml.sub(/\.yaml$/, ".db")
      @src = YAML.load(open(input_yaml).read())
      db_create(@output_db)
    end

    def update
      db_open(@output_db)
      
      @src["directory"].each do |dir|
        db_add_dir(dir)
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
          end

          schema.create_table("terms",
                              :type => :patricia_trie,
                              :key_normalize => true,
                              :default_tokenizer => "TokenBigram") do |table|
            table.index("documents.path")
            table.index("documents.content")
          end
        end
        puts "create  : #{dbfile.to_s} created."
      else
        puts "message : #{dbfile.to_s} already exist."
      end
    end
    private :db_create
      
    def db_open(filename)
      dbfile = Pathname(File.expand_path(filename))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        puts "open    : #{dbfile} open."
      else
        raise "error    : #{dbfile.to_s} not found!!"
      end
    end
    private :db_open

    def db_add_dir(dirname)
      puts dirname
    end
    private :db_add_dir

  end
end
