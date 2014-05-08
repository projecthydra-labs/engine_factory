# EngineFactory

```console
$ NAMESPACE="name_of_my" rails plugin new name_of_my_plugin -m https://raw.githubusercontent.com/projecthydra-labs/engine_factory/master/lib/template.rb
```

Explanation:

This Rails plugin template applies some of the new gem conventions for
  ProjectHydra, though may be useful for others as well:
  * Remove the MIT-LICENSE and replace with APACHE2
  * Replace the README.rdoc with README.md
  * Apply bundler's gemspec syntax for :files, :test_files, and :executables
  * For a Rails plugin engine, some opinionated defaults are applied.
  * Add rspec as a development dependency

If you run the template with a NAMESPACE environment variable set then this
  template will also do its best to allow for a namespaced gem.

  Example: If you specify the NAMESPACE as "hydra" and the plugin is
    "hydra_my_plugin" then this template will create a Hydra::MyPlugin gem
    instead of the usual HydraMyPlugin.

[More on Rails Application Templates](http://guides.rubyonrails.org/rails_application_templates.html)
