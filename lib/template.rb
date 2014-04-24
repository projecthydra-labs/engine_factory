# http://guides.rubyonrails.org/rails_application_templates.html
require 'rake'
require 'byebug'
namespace = ENV['NAMESPACE']

def original_wd
  return @original_wd if @original_wd
  raise RuntimeError.new("Doh! Rails changed an instance variable. We really need this for determining where we installed the gem.")
end

# Commit changes up to this point

plugin_path = File.join(original_wd,name)
inside plugin_path do

  dirnames = Rake::FileList.new("app/**/#{name}", "lib/**/#{name}")
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

  # Move lib/namspaced_plugin.rb to lib/namspaced-plugin.rb

  # For all files (Rake::FileList will be helpful) replace the text:
  # `namespaced_plugin` with `namespaced-plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs

  # Create lib/namespaced_plugin.rb
  # with `require "namespaced-plugin.rb"`

  # For all files (Rake::FileList will be helpful) replace:
  # `module NamespacedPlugin` with `module Namespaced\n  module Plugin`
  # and add the corresponding closing `end` at EOF
  # Hints from:
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs

  # For all files (Rake::FileList will be helpful) replace:
  # `NamespacedPlugin` with `Namespaced::Plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs

end
