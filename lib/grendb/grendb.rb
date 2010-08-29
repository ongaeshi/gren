# -*- coding: utf-8 -*-

require 'pathname'

base_directory = Pathname(__FILE__).dirname + ".."
$LOAD_PATH.unshift((base_directory + "ext").to_s)
$LOAD_PATH.unshift((base_directory + "lib").to_s)

require 'rubygems'
require 'groonga'

module Grendb
  DEFAULT_DB = '~/.gren/default.db'
  
  class Grendb
    def self.command_new(dbfile)
      dbfile ||= DEFAULT_DB
      puts "[new] #{dbfile}"
      create(dbfile)
      update(dbfile)
    end

    def self.command_add(dbfile, dirs)
      dbfile ||= DEFAULT_DB
      puts "[add] #{dbfile}, [#{dirs.join(", ")}]"
    end

    def self.command_update(dbfile)
      dbfile ||= DEFAULT_DB
      puts "[update] #{dbfile}"
      open(dbfile)
    end

    def self.create(dbfile)
      dbfile = Pathname(File.expand_path(dbfile))
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
        puts "  create : #{dbfile.to_s} created."
      else
        puts "  warning : #{dbfile.to_s} already exist!!"
      end
    end

    def self.open(dbfile)
      dbfile = Pathname(File.expand_path(dbfile))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        puts "  open : #{dbfile}"
      else
        raise "  error : #{dbfile.to_s} not found!!"
      end
    end

    def self.openif(dbfile)
    end

    def self.update(dbfile)
    end
    
  end
end
