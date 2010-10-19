# -*- coding: utf-8 -*-
#
# @file 
# @brief  ソースコードを表示する
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')

module Grenweb
  class Viewer
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      record, elapsed = Database.instance.record(req2query)

      @response.write HTMLRendeler.header("gren web検索")
      @response.write HTMLRendeler.search_box(req2path(".."), req2path('../images/mini-gren.png'), "grenweb", "")
      if (record)
        @response.write HTMLRendeler.view_summary(record.shortpath, elapsed)
        @response.write HTMLRendeler.record_content(record)
      else
        @response.write HTMLRendeler.empty_summary
      end
      @response.write HTMLRendeler.footer
      
      @response.to_a
    end

    private

    def req2query
      unescape(@request.path_info.gsub(/\A\/|\/z/, ''))
    end

    def req2path(component='')
      escape_html("#{@request.script_name}/#{component}")
    end
  end
end
