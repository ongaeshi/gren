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
    
    def self.create
      raise YAMLAlreadyExist.new if FileTest.exist? 'grendb.yaml'
      data = {'directory' => [], 'version' => 0.1}
      YAML.dump(data, open("grendb.yaml", "w"))
    end
  end
end
