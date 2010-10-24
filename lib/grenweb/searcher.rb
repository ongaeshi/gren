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
      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      @limit = 20               # 1ページに表示する最大レコード
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
      q = escape_html(req2query)
      title = (q == "") ? "gren" : "gren : #{q}"
      @response.write HTMLRendeler.header(title, "gren", req2path)
    end

    def render_search_box
      @response.write HTMLRendeler.search_box(req2path, escape_html(req2query))
    end

    def render_search_result
      query = req2query2
      page = req2page

      if query.empty?
        @response.write HTMLRendeler.empty_summary
      else
        patterns = query.keywords
        records, total_records, elapsed = Database.instance.search(patterns, page, @limit)
        render_search_summary(records, total_records, elapsed)
        records.each { |record| @response.write(HTMLRendeler.result_record(record, patterns, @nth)) }
        render_pagination(page, total_records)
      end
    end

    def render_search_summary(records, total_records, elapsed)
      query = req2query
      page = req2page

      @response.write HTMLRendeler.search_summary(query,
                                                  total_records,
                                                  (total_records.zero? ? 0 : (page * @limit) + 1)..((page * @limit) + records.size),
                                                  elapsed)
    end

    def render_pagination(page, total_records)
      query = req2query
      return if query.empty?
      return if total_records < @limit

      last_page = (total_records / @limit.to_f).ceil
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
    
    def req2query
      unescape(@request.path_info.gsub(/\A\/|\/\z/, ''))
    end

    def req2query2
      Query.new(@request)
    end

    def req2page
      (@request['page'] || 0).to_i
    end
    
    def req2path(component=nil)
      path = []
      path << ((@request.script_name == "") ? '/' : @request.script_name)
      path << component if (component)
      path.join('/')
    end

  end
end

