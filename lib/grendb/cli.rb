# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'grendb')

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

      option_db = nil
      
      subparsers['new'] = OptionParser.new("#{File.basename($0)} new [DATABASE_FILE]")
      
      subparsers['add'] = OptionParser.new("#{File.basename($0)} add DIR1 DIR2 ...")
      subparsers['add'].on('--db [DATABASE]', 'Database file path. (default is "~/.gren/default.db")') { |v| option_db = v }

      subparsers['update'] = OptionParser.new("#{File.basename($0)} update [DATABASE_FILE]")

      opt.order!(arguments)
      subcommand = arguments.shift 
      subparsers[subcommand].parse!(arguments) unless arguments.empty?

      # 実行
      case subcommand
      when 'new'
        if (arguments.size <= 1)
          Grendb.command_new(arguments[0])
        else
          stdout.puts subparsers['new'].help
        end
      when 'add'
        if (arguments.size > 0)
          Grendb.command_add(option_db, arguments)
        else
          stdout.puts subparsers['add'].help
        end
      when 'update'
        if (arguments.size <= 1)
          Grendb.command_update(arguments[0])
        else
          stdout.puts subparsers['update'].help
        end
      else
        stdout.puts opt.help
      end
    end
  end
end
