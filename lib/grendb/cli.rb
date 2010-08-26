# -*- coding: utf-8 -*-
require 'optparse'

module Grendb
  class CLI
    def self.execute(stdout, arguments=[])

      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]
        new                          Create new database.
        add                          Add files.
        update                       Update database.
EOF

      subparsers = Hash.new {|h,k|
        $stderr.puts "no such subcommand: #{k}"

        exit 1
      }
      
      subparsers['new'] = OptionParser.new("#{File.basename($0)} new [DATABASE_FILE]")
      
      subparsers['add'] = OptionParser.new("#{File.basename($0)} add DIR1 DIR2 ...")
      subparsers['add'].on('--db [DATABASE]', 'Database file path. (default is ".gren/default.db")') { |v| puts "--db : " + v.inspect }

      subparsers['update'] = OptionParser.new("#{File.basename($0)} update [DATABASE_FILE]")

      opt.order!(arguments)
      subcommand = arguments.shift 
      subparsers[subcommand].parse!(arguments) unless arguments.empty?
      
    end
  end
end
