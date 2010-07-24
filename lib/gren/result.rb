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
      @start_dir = start_dir
      @count, @search_count, @match_file, @match_count, @size = 0, 0, 0, 0, 0
      @start_time = Process.times
    end

    def time_stop
      @end_time = Process.times
    end

    def time
      s = @start_time
      e = @end_time
      e.utime - s.utime + e.stime - s.stime
    end

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end

    def size_s
      if (@size > 1024 * 1024)
       (round(@size / (1024 * 1024.0), 2)).to_s + "MB"
      elsif (@size > 1024)
        (round(@size / 1024.0, 2)).to_s + "KB"
      else
        @size.to_s + "Byte"
      end
    end

    def print(stdout)
      puts @count, @search_count, @match_file, @match_count, size_s, time
    end

  end
end
