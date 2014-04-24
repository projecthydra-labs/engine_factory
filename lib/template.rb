# http://guides.rubyonrails.org/rails_application_templates.html
require 'rake'
require 'byebug'
namespace = ENV['NAMESPACE']
plugin_path = File.join(@original_wd,app_path)
inside plugin_path do

  dirnames = Rake::FileList.new("app/**/#{app_path}", "lib/**/#{app_path}")
  dirnames.each do |dirname|
    target_dirname = dirname.sub(/\/#{namespace}_/, "/#{namespace}/")
    run "mkdir -p #{File.dirname(target_dirname)}"
    run "mv #{dirname} #{target_dirname}"
  end

end
