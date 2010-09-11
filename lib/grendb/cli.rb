# -*- coding: utf-8 -*-
require 'optparse'

module Grendb
  class CLI
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new "#{File.basename($0)} INPUT_YAML1 [INPUT_YAML2 ...]"
      stdout.puts opt.help
    end
  end
end
