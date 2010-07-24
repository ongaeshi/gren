# -*- coding: utf-8 -*-
require 'find'

module Gren
  class Result
    attr_accessor :count
    attr_accessor :search_count
    attr_accessor :match_file
    attr_accessor :match_count
    attr_accessor :size

    def initialize(start_dir)
      @start_dir = File.expand_path(start_dir)
      @count, @search_count, @match_file, @match_count, @size = 0, 0, 0, 0, 0
      @start_time = Time.now
    end

    def time_stop
      @end_time = Time.now
    end

    def time
      @end_time - @start_time 
    end

    def time_s
      t = time.truncate
      h = t / 3600
      t = t % 3600
      m = t / 60
      t = t % 60
      t += round(time - time.prec_i, 2)
      
      if (h > 0 && m > 0)
        "#{h}h #{m}m #{t}s"
      elsif (m > 0)
        "#{m}m #{t}s"
      else
        "#{t}sec"
      end
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end

    def size_s
      if (@size > 1024 * 1024)
        round(@size / (1024 * 1024.0), 2).to_s + "MB"
      elsif (@size > 1024)
        round(@size / 1024.0, 2).to_s + "KB"
      else
        @size.to_s + "Byte"
      end
    end

    def print(stdout)
      stdout.puts "RESULT == #{@start_dir} (#{time_s}, #{size_s})"
      stdout.puts "files : #{@search_count} search in #{@count} files"
      stdout.puts "match : #{@match_file} files, #{match_count} match"
    end

  end
end
