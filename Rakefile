# -*- coding: utf-8 -*-
# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/gren'
require 'rake_rdoc_custom'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'gren' do
  self.developer 'ongaeshi', 'ongaeshi0621@gmail.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value

  # 必要とするgem
  self.extra_deps         = [
                             ['termcolor','>= 1.2.0'],
                             ['rroonga','>= 1.0.0'],
                             ['rack','>=1.2.1'],
                             ['launchy', '>=0.3.7']
                            ]

  # 本来はnewgemの中で設定されるべき(後で報告した方がいいかも)
  self.extra_rdoc_files << "README.rdoc"
  
  # 本当はhoeの中でこう設定出来たら良い
  # self.spec_extras[:rdoc_options] = ['-c', 'utf8']
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# clear current task
module Rake
  class Task
    def clear_actions
      @actions.clear
    end
  end
end

# clear test task
t = Rake.application.lookup(:test).clear_actions

# new test
task :test do
  load "test/runner.rb"
end

