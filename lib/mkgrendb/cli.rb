# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'mkgrendb2')

module Mkgrendb
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]

The most commonly used mkgrendb are:
  init        Init db.
  update      Update db.
  add         Add contents. (ex. ~/Documents/gren, git://github.com/ongaeshi/gren.git)
  list        List all contents. 
EOF

      subopt = Hash.new
      subopt['init'] = OptionParser.new("#{File.basename($0)} init")
      subopt['update'] = OptionParser.new("#{File.basename($0)} update")
      subopt['add'] = OptionParser.new("#{File.basename($0)} add content1 [content2 ...]")
      subopt['list'] = OptionParser.new("#{File.basename($0)} list")

      opt.order!(arguments)
      subcommand = arguments.shift

      if (subopt[subcommand])
        subopt[subcommand].parse!(arguments) unless arguments.empty?
        obj = Mkgrendb2.new

        case subcommand
        when "init"
          obj.init
        when "update"
          obj.update
        when "add"
          obj.add
        when "list"
          obj.list
        end
      else
        if subcommand
          $stderr.puts "mkgrendb: '#{subcommand}' is not a mkgrendb command. See 'mkgrendb --help'"
        else
          stdout.puts opt.help
        end
      end
    end
  end
end
