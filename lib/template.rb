################################################################################
################################################################################
###
### TL;DR
###
### $ NAMESPACE="name_of_my" rails plugin new name_of_my_plugin /
###   -m path/to/engine_factory/lib/template.rb
###
### Explanation:
###
### This Rails plugin template applies some of the new gem conventions for
###   ProjectHydra, though may be useful for others as well:
###   * Remove the MIT-LICENSE and replace with APACHE2
###   * Replace the README.rdoc with README.md
###   * Apply bundler's gemspec syntax for :files, :test_files, and :executables
###   * For a Rails plugin engine, some opinionated defaults are applied.
###   * Add rspec as a development dependency
###
### If you run the template with a NAMESPACE environment variable set then this
###   template will also do its best to allow for a namespaced gem.
###
###   Example: If you specify the NAMESPACE as "hydra" and the plugin is
###     "hydra_my_plugin" then this template will create a Hydra::MyPlugin gem
###     instead of the usual HydraMyPlugin.
###
### More on Rails Application Templates
### http://guides.rubyonrails.org/rails_application_templates.html
###
require 'rake'

################################################################################
################################################################################
###
### BEGIN FUNCTION DEFINITIONS
###
### These functions will be called at the bottom of the file. You should scroll
### to the bottom of this file and see what is happening.
###
################################################################################
################################################################################

def namespace
  ENV['NAMESPACE']
end

def new_project_directory
  @new_project_directory ||= begin
    if namespace
      name.sub(/^#{ENV["NAMESPACE"]}_/, "#{ENV['NAMESPACE']}/")
    else
      name
    end
  end
end
def new_project_class_name
  @new_project_class_name ||= new_project_directory.classify
end

def original_wd
  return @original_wd if @original_wd
  raise RuntimeError.new("Doh! Rails changed an instance variable. We really need this for determining where we installed the gem.")
end

def plugin_path
  File.join(original_wd,name)
end

def each_filename_in_repo
  Rake::FileList.new("**/*").each do |filename|
    next if File.directory?(filename)
    next if filename =~ /engine\.rb\Z/
    yield filename
  end
end

def prepare_project_for_git
  # prepare .gitignore
  append_file '.gitignore' do
    "\nGemfile.lock\nspec/internal\n"
  end

  # Commit changes up to this point
  run "git init"
  run "git add .gitignore; git commit -m 'add .gitignore'" 
  run "git add --all .; git commit -m 'Initial commit after generator, before template'"
end

def pre_namespace_changes
  remove_file 'MIT-LICENSE'

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

  remove_file "README.rdoc"

  create_file "README.md" do
    app_name = "# #{new_project_class_name}\n"
    app_desc = "This project rocks and uses APACHE-LICENSE.\n"
    "#{app_name}\n#{app_desc}"
  end

  # Add `s.license = "APACHE"` to gemspec
  # Add bundler style s.files and s.bin
  gsub_file "#{name}.gemspec", / +s\.files.*$/ do <<-RUBY
  s.license = 'APACHE2'

  s.files         = `git ls-files -z`.split(\"\\x0\")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'rspec'
  RUBY
  end

  # Rework the engine declaration.
  engine_filename = File.join("lib", name, "engine.rb")
  if File.exist?(engine_filename)
    create_file(engine_filename, force: true) do
      lines = []
      modules = new_project_class_name.split("::")
      lines += modules.collect {|m| "module #{m}"}
      lines << ""
      lines << "  module_function"
      lines << ""
      lines << "  # As per an isolated_namespace Rails engine."
      lines << "  # But the isolated namespace creates issues."
      lines << "  def table_name_prefix"
      lines << "    '#{name}'"
      lines << "  end"
      lines << ""
      lines << "  # Because we are not using isolate_namespace for #{new_project_class_name}"
      lines << "  # We need this for the application router to find the appropriate routes."
      lines << "  def use_relative_model_naming?"
      lines << "    true"
      lines << "  end"
      lines << ""
      lines << "  class Engine < ::Rails::Engine"
      lines << "    engine_name '#{name}'"
      lines << ""
      lines << "    # You may find it helpful to declare initializers"
      lines << "    # initializer '#{name}.initializers' do |app|"
      lines << "    #  app.config.paths.add 'app/services', eager_load: true"
      lines << "    #  app.config.autoload_paths += %W("
      lines << '    #    #{config.root}/app/services'
      lines << "    #  )"
      lines << "    # end"
      lines << ""
      lines << "  end"
      lines << ""
      lines += modules.collect{|m| "end" }
      lines << ""
      lines.join("\n")
    end
  end

end

def namespace_related_changes
  return true unless ENV['NAMESPACE']
  dirnames = Rake::FileList.new("app/**/#{name}", "lib/**/#{name}")
  dirnames.each do |dirname|
    target_dirname = dirname.sub(/\/#{namespace}_/, "/#{namespace}/")
    run "mkdir -p #{File.dirname(target_dirname)}"
    run "mv #{dirname} #{target_dirname}"
  end

  # Rename gemspec
  original_gemspec_filename = "#{name}.gemspec"
  new_gemspec_filename = original_gemspec_filename.sub(/#{namespace}_/, "#{namespace}-")
  run "mv #{original_gemspec_filename} #{new_gemspec_filename}"

  # Move lib/namspaced_plugin.rb to lib/namspaced-plugin.rb
  plugin = name.sub(/#{namespace}_/, "")
  new_name = "#{namespace}-#{plugin}"
  run "mv lib/#{name}.rb lib/#{new_name}.rb"

  # Rename gem name to namespaced version
  # NOTE: gemspec filename must match internally declared spec.name
  gsub_file new_gemspec_filename, /\.name *= *['"]#{name}['"]/ do
    ".name = '#{new_name}'"
  end

  # For all files (Rake::FileList will be helpful) replace the text:
  # require `namespaced_plugin` with require `namespaced-plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  new_require_name = name.sub("#{namespace}_", "#{namespace}/")
  each_filename_in_repo do |filename|
    content = File.read(filename)
    new_content = content.gsub(/require ['"](#{name})([^('")]*)['"]/, 'require \'' << new_require_name << '\2\'')
    if new_content != content
      File.open(filename, 'w+') {|f| f.puts new_content }
    end
  end

  # Create lib/namespaced_plugin.rb
  # with `require "namespaced-plugin.rb"`
  create_file "lib/#{name}.rb" do
   "# A convenience/courtesy file for adopters of this gem.\n" <<
   "require '#{new_name}'\n"
  end

  # For all files (Rake::FileList will be helpful) replace:
  # `module NamespacedPlugin` with `module Namespaced\n  module Plugin`
  # and add the corresponding closing `end` at EOF
  # Hints from:
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  class_name = name.classify
  namespace_module = namespace.classify
  submodule = class_name.sub(/^#{namespace_module}/, '')
  each_filename_in_repo do |filename|
    content = File.read(filename)
    new_content = content.gsub("module #{class_name}", "module #{namespace_module}\nmodule #{submodule}" )
    if content != new_content
      new_content << "\nend\n"
      File.open(filename, 'w+') { |f| f.puts new_content }
    end
  end

  # For all files (Rake::FileList will be helpful) replace:
  # `NamespacedPlugin` with `Namespaced::Plugin`
  # https://github.com/jeremyf/orcid/blob/master/script/fast_specs
  each_filename_in_repo do |filename|
    gsub_file filename, "#{class_name}", "#{namespace_module}::#{submodule}"
    gsub_file filename, "#{name}.gemspec", "#{new_name}.gemspec"
    gsub_file filename, "#{name}", "#{new_require_name}"
  end

end

################################################################################
################################################################################
###
### BEGIN THE PART THAT DOES THINGS
###
### Below this line, the things happen.
###
################################################################################
################################################################################

inside(plugin_path) do
  prepare_project_for_git
  pre_namespace_changes
  namespace_related_changes if namespace
  # Commit template changes to git
  run "git add --all .; git commit -m 'Apply EngineFactory template'"
end
