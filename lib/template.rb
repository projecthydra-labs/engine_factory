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
	remove_file 'MIT-LICENSE'

  # Add LICENSE file for Apache2
	create_file "LICENSE" do
		copyright_statement = ask("What copyright statement should be included in the license? (e.g., Copyright 2014 University of Example)"
		<<EOF
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

  # Remove README.rdoc

  # Add README.md

  # Add `s.license = "APACHE"` to gemspec

  # Add bundler style s.files and s.bin

end
