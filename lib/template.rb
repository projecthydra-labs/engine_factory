# http://guides.rubyonrails.org/rails_application_templates.html
require 'rake'
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

  # Initialize git repo
  run "git init"

  # Remove MIT-LICENSE file
  remove_file 'MIT-LICENSE'

  # Add LICENSE file for Apache2
  create_file "LICENSE" do
    copyright_statement = ask("What copyright statement should be included in the license? (e.g., Copyright 2014 University of Example)")
    <<-EOF
##########################################################################
# #{copyright_statement}
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

    EOF
  end

  # Rename gemspec
  original_gemfile_name = "#{name}.gemspec"
  new_gemfile_name = original_gemfile_name.sub(/#{namespace}_/, "#{namespace}-")
  run "mv #{original_gemfile_name} #{new_gemfile_name}"

  # Remove README.rdoc
  run "rm README.rdoc"

  # Add README.md
  create_file "README.md" do
    app_name = "# #{name.camelize}\n"
    app_desc = "This project rocks and uses APACHE-LICENSE.\n"
    "#{app_name}\n#{app_desc}"
  end

  # Add `s.license = "APACHE"` to gemspec

  # Add bundler style s.files and s.bin
  gsub_file new_gemfile_name, / +s\.files.*$/ do <<-RUBY
  s.license = 'APACHE2'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  RUBY
  end


  # Move lib/namspaced_plugin.rb to lib/namspaced-plugin.rb
  plugin = name.gsub(/#{namespace}_/, "")
  original_name = "#{namespace}_#{plugin}"
  new_name = "#{namespace}-#{plugin}"
  run "mv lib/#{original_name}.rb lib/#{new_name}.rb"
  create_file "lib/#{original_name}.rb", "require '#{new_name}'\n"

  # For all files (Rake::FileList will be helpful) replace the text:
  # `namespaced_plugin` with `namespaced-plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  new_require_name = name.sub("#{namespace}_", "#{namespace}/")
  Rake::FileList.new("**/*.*").each do |filename|
    content = File.read(filename)
    new_content = content.gsub(/require ['"](#{name})([^('")]*)['"]/, 'require \'' << new_require_name << '\2\'')
    if new_content != content
      File.open(filename, 'w+') {|f| f.puts new_content }
    end
  end

  # For all files (Rake::FileList will be helpful) replace:
  # `module NamespacedPlugin` with `module Namespaced\n  module Plugin`
  # and add the corresponding closing `end` at EOF
  # Hints from:
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  class_name = name.classify
  namespace_module = namespace.classify
  submodule = class_name.sub(/^#{namespace_module}/, '')
  Rake::FileList.new("**/*.*").each do |filename|
    content = File.read(filename)
    new_content = content.gsub("module #{class_name}", "module #{namespace_module}\nmodule #{submodule}" )
    if new_content != content
      new_content << "\nend\n"
      File.open(filename, 'w+') {|f| f.puts new_content }
    end
  end

  # For all files (Rake::FileList will be helpful) replace:
  # `NamespacedPlugin` with `Namespaced::Plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  Rake::FileList.new("**/*.*").each do |filename|
    gsub_file filename, "#{class_name}", "#{namespace_module}::#{submodule}"
  end

  # Commit template changes to git
  run "git add .; git commit -m 'Run plugin generator and apply EngineFactory template'"
end
