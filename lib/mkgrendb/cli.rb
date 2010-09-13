# -*- coding: utf-8 -*-
require 'optparse'
require File.join(File.dirname(__FILE__), 'mkgrendb')

module Mkgrendb
  class CLI
    def self.execute(stdout, arguments=[])
      input_yamls = []

      opt = OptionParser.new "#{File.basename($0)} INPUT_YAML1 [INPUT_YAML2 ...]"
      opt.on('--ddb', "--default-db", "Create or Update default DB. (set ENV['GRENDB_DEFAULT_DB'])") {|v| input_yamls << ENV['GRENDB_DEFAULT_DB']}
      opt.parse!(arguments)

      input_yamls.concat arguments

      if (input_yamls.size >= 1)
        input_yamls.each do |input_yaml|
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
