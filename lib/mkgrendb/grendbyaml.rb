# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'yaml'

module Mkgrendb
  class GrendbYAML
    class YAMLAlreadyExist < RuntimeError
    end
    
    class YAMLNotExist < RuntimeError
    end

    def self.create
      raise YAMLAlreadyExist.new if FileTest.exist? 'grendb.yaml'
      obj = GrendbYAML.new({'directory' => [], 'version' => 0.1})
      obj.save
      return obj
    end

    def self.load
      raise YAMLNotExist.new unless FileTest.exist? 'grendb.yaml'
      open('grendb.yaml') do |f|
        return GrendbYAML.new(YAML.load(f.read()))
      end
    end

    def add(*content)
      directory.push(*content)
    end

    def remove(*content)
      content.each {|f| directory.delete f }
    end

    def save
      open('grendb.yaml', "w") { |f| YAML.dump(@data, f) }
    end

    def directory
      @data['directory']
    end

    def version
      @data['version']
    end

    private

    def initialize(data)
      @data = data
    end

  end
end
