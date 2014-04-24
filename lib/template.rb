# http://guides.rubyonrails.org/rails_application_templates.html
require 'rake'
require 'byebug'
namespace = ENV['NAMESPACE']

# Commit changes up to this point

plugin_path = File.join(@original_wd,app_path)
inside plugin_path do

  dirnames = Rake::FileList.new("app/**/#{app_path}", "lib/**/#{app_path}")
  dirnames.each do |dirname|
    target_dirname = dirname.sub(/\/#{namespace}_/, "/#{namespace}/")
    run "mkdir -p #{File.dirname(target_dirname)}"
    run "mv #{dirname} #{target_dirname}"
  end

  # Remove MIT-LICENSE file

  # Add LICENSE file for Apache2

  # Rename gemspec

  # Remove README.rdoc

  # Add README.md

  # Add `s.license = "APACHE"` to gemspec

  # Add bundler style s.files and s.bin

end
