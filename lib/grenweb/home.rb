# -*- coding: utf-8 -*-
#
# @file 
# @brief  ホーム画面
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')
require File.join(File.dirname(__FILE__), 'html_renderer')
require File.join(File.dirname(__FILE__), 'query')

module Grenweb
  class Home
    include Rack::Utils

    def call(env)
      @request = Rack::Request.new(env)
      @query = Query.new(@request)

      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      render
    end

    private

    def render
      @response.write HTMLRendeler.header("gren", "gren")
      @response.write HTMLRendeler.search_box
      @response.write HTMLRendeler.footer
      @response.to_a
    end
  end
end

