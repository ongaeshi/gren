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

      if (record)
        @response.write HTMLRendeler.header("gren : #{record.shortpath}", "gren", req2path('..'))
        @response.write HTMLRendeler.search_box(req2path(".."), "")
        @response.write HTMLRendeler.view_summary(record.shortpath, elapsed)
        @response.write HTMLRendeler.record_content(record)
      else
        @response.write HTMLRendeler.header("gren : not found.", "gren", req2path('..'))
        @response.write HTMLRendeler.search_box(req2path(".."), "")
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
      path = []
      path << ((@request.script_name == "") ? '/' : @request.script_name)
      path << component if (component)
      path.join('/')
    end
  end
end
