# -*- coding: utf-8 -*-
#
# @file 
# @brief  検索処理本体
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')
require File.join(File.dirname(__FILE__), 'html_renderer')

module Grenweb
  class Searcher
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      response["Content-Type"] = "text/html; charset=UTF-8"

      if request.post? or request['query']
        post_request(request, response)
      else
        search(request, response)
      end
    end

    private

    def post_request(request, response)
      query = request['query'] || ''
      if query.empty?
        request.path_info = "/"
      else
        request.path_info = "/#{escape(query)}/"
      end
      response.redirect(request.url.split(/\?/, 2)[0])
      response.to_a
    end

    def search(request, response)
      render_header(request, response)
      render_search_box(request, response)
      render_search_result(request, response)
      render_footer(request, response)
      response.to_a
    end

    def render_header(request, response)
      response.write(HTMLRendeler.header("gren web検索"))
    end

    def render_search_box(request, response)
      response.write(<<-EOF)
<form method="post" action="#{path(request, '')}">
  <p>
    <a href="#{path(request, '')}">
      <img src="#{path(request, 'images/mini-gren.png')}" alt="gren"/>
    </a>
    <input name="query" type="text" value="#{escape_html(req2query(request))}" />
    <input type="submit" value="検索" />
  </p>
</form>
EOF
    end

    def render_search_result(request, response)
      query = req2query(request)
      page = req2page(request)
      limit = 20                # パラメータ化？

      if query.empty?
        response.write HTMLRendeler.empty_summary
      else
        patterns = query.split(/\s/)
        records, total_records, elapsed = Database.instance.search(patterns, page, limit)
        render_search_summary(request, response, records, total_records, elapsed, limit)
        records.each { |record| response.write(HTMLRendeler.result_record(record, patterns)) }
        render_pagination(request, response, page, limit, total_records)
      end
    end

    def render_search_summary(request, response, records, total_records, elapsed, limit)
      query = req2query(request)
      page = req2page(request)

      response.write HTMLRendeler.search_summary(query,
                                                 total_records,
                                                 (total_records.zero? ? 0 : (page * limit) + 1)..((page * limit) + records.size),
                                                 elapsed)
    end

    def render_pagination(request, response, page, limit, total_records)
      query = req2query(request)
      return if query.empty?
      return if total_records < limit

      last_page = (total_records / limit.to_f).ceil
      response.write("<div class='pagination'>\n")
      if page > 0
        response.write(HTMLRendeler.pagination_link(page - 1, "<<"))
      end
      last_page.times do |i|
        if i == page
          response.write(HTMLRendeler.pagination_span(i))
        else
          response.write(HTMLRendeler.pagination_link(i, i))
        end
      end
      if page < (last_page - 1)
        response.write(HTMLRendeler.pagination_link(page + 1, ">>"))
      end
      response.write("</div>\n")
    end

    def render_footer(request, response)
      response.write(HTMLRendeler.footer)
    end

    private
    
    def req2query(request)
      unescape(request.path_info.gsub(/\A\/|\/\z/, ''))
    end

    def req2page(request)
      (request['page'] || 0).to_i
    end
    
    def path(request, component='')
      escape_html("#{request.script_name}/#{component}")
    end
    
  end
end

