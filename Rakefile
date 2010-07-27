# -*- ruby -*-

require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/gren'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'gren' do
  self.developer 'ongaeshi', 'ongaeshi0621@gmail.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

  self.readme_file = "README.rdoc"
  self.extra_rdoc_files << "README.rdoc"

  spec_extras['rdoc_options'] = proc do |rdoc_options|
    rdoc_options << "--charset utf8"
  end

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

Rake::RDocTask.class_eval { 
  @@default_options = []
  
  class << self
    def default_options
      @@default_options
    end
    
    def default_options=(options)
      @@default_options = options
    end
  end
  
  alias :_option_list :option_list
  def option_list
    _option_list + @@default_options
  end  
}

Rake::RDocTask.default_options = ['-c', "utf8"]

