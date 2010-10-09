# -*- coding: utf-8 -*-
require 'optparse'

module Grenweb
  class CLI
    def self.execute(stdout, arguments=[])
      # オプション解析
      opt = OptionParser.new("#{File.basename($0)}")
      opt.parse!(arguments)

      # webサーバー起動
      stdout.puts "Start up grenweb server ... (http://localhost:9292/)"
    end
  end
end
