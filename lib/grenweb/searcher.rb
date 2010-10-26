# -*- coding: utf-8 -*-
#
# @file 
# @brief  検索処理本体
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')
require File.join(File.dirname(__FILE__), 'html_renderer')
require File.join(File.dirname(__FILE__), 'query')

module Grenweb
  class Searcher
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @query = Query.new(@request)

      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      @nth = 3                  # マッチした行の前後何行を表示するか

      if @request.post? or @request['query']
        post_request
      else
        search
      end
    end

    private

    def post_request
      query = @request['query'] || ''
      if query.empty?
        @request.path_info = "/"
      else
        @request.path_info = "/#{escape(query)}/"
      end
      @response.redirect(@request.url.split(/\?/, 2)[0])
      @response.to_a
    end

    def search
      render_header
      render_search_box
      render_search_result
      render_footer
      @response.to_a
    end

    def render_header
      @response.write HTMLRendeler.header("gren : #{@query.escape_html}", "gren")
    end

    def render_search_box
      @response.write HTMLRendeler.search_box(@query.escape_html)
    end

    def render_search_result
      if @query.empty?
        @response.write HTMLRendeler.empty_summary
      else
        records, total_records, elapsed = Database.instance.search(@query.keywords, @query.packages, @query.fpaths, @query.suffixs, calcPage, calcLimit)
        render_search_summary(records, total_records, elapsed)
        records.each { |record| @response.write(HTMLRendeler.result_record(record, @query.keywords, @nth)) }
        render_pagination(calcPage, total_records)
      end
    end

    def render_search_summary(records, total_records, elapsed)
      pageStart = calcPage * calcLimit
      @response.write HTMLRendeler.search_summary(@query.query_string,
                                                  total_records,
                                                  (total_records.zero? ? 0 : pageStart + 1)..(pageStart + records.size),
                                                  elapsed)
    end

    def render_pagination(page, total_records)
      return if @query.empty?
      return if total_records < calcLimit

      last_page = (total_records / calcLimit.to_f).ceil
      @response.write("<div class='pagination'>\n")
      if page > 0
        @response.write(HTMLRendeler.pagination_link(page - 1, "<<"))
      end
      last_page.times do |i|
        if i == page
          @response.write(HTMLRendeler.pagination_span(i))
        else
          @response.write(HTMLRendeler.pagination_link(i, i))
        end
      end
      if page < (last_page - 1)
        @response.write(HTMLRendeler.pagination_link(page + 1, ">>"))
      end
      @response.write("</div>\n")
    end

    def render_footer
      @response.write HTMLRendeler.footer
    end

    private

    # 1ページに表示する最大レコードを計算
    def calcLimit
      if @query.keywords.size == 0
        100
      else
        20
      end
    end
    
    # 現在ページを計算
    def calcPage
      (@request['page'] || 0).to_i
    end
    
    # リクエストからパスを計算
    def req2path(component=nil)
      path = []
      path << ((@request.script_name == "") ? '/' : @request.script_name)
      path << component if (component)
      path.join('/')
    end

  end
end

