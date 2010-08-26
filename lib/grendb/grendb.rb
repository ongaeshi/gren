# -*- coding: utf-8 -*-

module Grendb
  DEFAULT_DB = '~/.gren/default.db'
  
  class Grendb
    def self.command_new(dbfile)
      dbfile ||= DEFAULT_DB
      puts "create db --->  #{dbfile}"
    end

    def self.command_add(dbfile, dirs)
      dbfile ||= DEFAULT_DB
      puts "dbfile : #{dbfile}"
      puts "dirs --->  [#{dirs.join(", ")}]"
    end

    def self.command_update(dbfile)
      dbfile ||= DEFAULT_DB
      puts "update db --->  #{dbfile}"
    end
  end
end
