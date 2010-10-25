# -*- coding: utf-8 -*-
require 'optparse'
require 'rubygems'
require 'rack'
require 'fileutils'

module Grenweb
  class CLI
    def self.execute(stdout, arguments=[])
      option = {
        :Port => 9292,
        :DbFile => ENV['GRENDB_DEFAULT_DB'],
      }
      
      opt = OptionParser.new("#{File.basename($0)}")
      opt.on('--db [GREN_DB_FILE]', 'Search from the grendb database.') {|v| option[:DbFile] = v }
      opt.on('-p', '--port PORT', 'use PORT (default: 9292)') {|v| option[:Port] = v }
      opt.parse!(arguments)

      # webサーバー起動
      stdout.puts <<EOF
Start up grenweb !!
URL : http://localhost:#{option[:Port]}
DB  : #{option[:DbFile]}
----------------------------------------
EOF
      
      # サーバースクリプトのある場所へ移動
      FileUtils.cd(File.dirname(__FILE__))
      
      # サーバー起動
      Rack::Server.start(
                         :environment => "development",
                         :pid         => nil,
                         :Port        => option[:Port],
                         :Host        => "0.0.0.0",
                         :AccessLog   => [],
                         :config      => "grenweb.ru"
                         )

      # ブラウザ起動
      
    end
  end
end
