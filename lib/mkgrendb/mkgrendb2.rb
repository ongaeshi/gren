# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'grendbyaml')

module Mkgrendb
  class Mkgrendb2
    def initialize()
    end

    def init
      begin
        GrendbYAML.create
        puts "create     : grendb.yaml"
        db_create('db/grendb.db')
      rescue GrendbYAML::YAMLAlreadyExist
        puts "Already existing Grendb Database in #{Dir.pwd}"
      end
    end

    def update
      yaml = GrendbYAML.load
      p yaml
      puts "update"
    end

    def add
      yaml = GrendbYAML.load
      yaml.add("hoge")
      yaml.save
    end

    def list
#       GrendbYAML.load
#       puts GrendbYAML.list
    end

    def rebuild
      db_delete('db/grendb.db')
      db_create('db/grendb.db')
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
