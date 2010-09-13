# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'mkgrendb')

module Mkgrendb
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new "#{File.basename($0)} INPUT_YAML1 [INPUT_YAML2 ...]"
      opt.parse!(arguments)

      if (arguments.size >= 1)
        arguments.each do |input_yaml|
          obj = Mkgrendb.new(input_yaml)
          obj.update
          stdout.puts
        end
      else
        stdout.puts opt.help
      end
    end
  end
end
