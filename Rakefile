# vim: syntax=ruby
load 'tasks/this.rb'

This.name     = "amalgalite"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.add_dependency( 'arrayfields', '~> 4.7.4' )
  spec.add_dependency( 'fastercsv'  , '~> 1.5.5' )

  spec.add_development_dependency( 'rspec'        , '~> 2.13.0')
  spec.add_development_dependency( 'rake'         , '~> 10.0.3')
  spec.add_development_dependency( 'rake-compiler', '~> 0.8.1' )
  spec.add_development_dependency( 'rdoc'         , '~> 4.0'   )
  spec.add_development_dependency( 'zip'          , '~> 2.0.2' )

  spec.extensions.concat This.extension_conf_files
  spec.license = "BSD"
end

load 'tasks/default.rake'
load 'tasks/extension.rake'
load 'tasks/custom.rake'
