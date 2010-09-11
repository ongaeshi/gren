# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'grendb')

module Mkgrendb
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new "#{File.basename($0)} INPUT_YAML1 [INPUT_YAML2 ...]"

      if (arguments.size >= 1)
        # @todo 複数個引数に対応
        obj = Grendb.new(arguments[0])
        obj.update
      else
        stdout.puts opt.help
      end
    end
  end
end
