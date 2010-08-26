# -*- coding: utf-8 -*-
require 'optparse'

module Grendb
  class CLI
    def self.execute(stdout, arguments=[])

      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]
--- subcommand ---
        new                          Create new database.
        add                          Add files.
        update                       Update database.

--- option -------
EOF
      opt.on('--db [DATABASE]', 'Database file path. (default is ".gren/default.db")') { |v| puts "--db : " + v.inspect }

      subparsers = Hash.new {|h,k|
        $stderr.puts "no such subcommand: #{k}"
        exit 1
      }
      
      subparsers['new'] = OptionParser.new
      subparsers['new'].on('-i V') {|v| puts "-i :" + v.inspect}
      
      subparsers['add'] = OptionParser.new
      subparsers['add'].on('--abc') {|v| puts "-i :" + v.inspect}

      subparsers['update'] = OptionParser.new

      opt.order!(arguments)
      subcommand = arguments.shift 
      subparsers[subcommand].parse!(arguments) unless arguments.empty?
      
    end
  end
end
