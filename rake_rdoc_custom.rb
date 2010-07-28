# -*- coding: utf-8 -*-

require 'rake'
require 'rake/rdoctask'

# RDocの文字コードをutf8に
Rake::RDocTask.class_eval { 
  alias :_option_list :option_list
  def option_list
    _option_list + ['-c', 'utf8']
  end  
}

