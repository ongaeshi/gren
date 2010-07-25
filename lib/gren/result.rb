# -*- coding: utf-8 -*-
require 'find'

module Gren
  class Result
    attr_accessor :count
    attr_accessor :search_count
    attr_accessor :match_file
    attr_accessor :match_count
    attr_accessor :size
    attr_accessor :search_size

    def initialize(start_dir)
      @start_dir = File.expand_path(start_dir)
      @count, @search_count, @match_file, @match_count, @size, @search_size = 0, 0, 0, 0, 0, 0
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

    def size_s(size)
      tb = 1024 ** 4
      gb = 1024 ** 3
      mb = 1024 ** 2
      kb = 1024

      if (size >= tb)
        round(size / tb.prec_f, 2).to_s + "TB"
      elsif (size >= gb)
        round(size / gb.prec_f, 2).to_s + "GB"
      elsif (size >= mb)
        round(size / mb.prec_f, 2).to_s + "MB"
      elsif (size >= kb)
        round(size / kb.prec_f, 2).to_s + "KB"
      else
        size.to_s + "Byte"
      end
    end

    def print(stdout)
      stdout.puts "dir   : #{@start_dir} (#{time_s})"
      stdout.puts "files : #{@search_count} in #{@count} (#{size_s(@search_size)} in #{size_s(@size)})"
      stdout.puts "match : #{@match_file} files, #{match_count} hit"
    end

  end
end
