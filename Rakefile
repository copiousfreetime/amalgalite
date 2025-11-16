# vim: syntax=ruby
load 'tasks/this.rb'
require 'date'

This.name     = "amalgalite"
This.author   = "Jeremy Hinegardner"
This.email    = "jeremy@copiousfreetime.org"
This.homepage = "http://github.com/copiousfreetime/#{ This.name }"

This.ruby_gemspec do |spec|
  spec.date = Date.today.to_s
  spec.add_dependency( 'csv', '~> 3.3' )

  spec.add_development_dependency( 'rspec',              '~> 3.13' )
  spec.add_development_dependency( 'rspec_junit_formatter','~> 0.6' )
  spec.add_development_dependency( 'rake',               '~> 13.3' )
  spec.add_development_dependency( 'rake-compiler',      '~> 1.3'  )
  spec.add_development_dependency( 'rake-compiler-dock', '~> 1.10'  )
  spec.add_development_dependency( 'rdoc',               '~> 6.15'  )
  spec.add_development_dependency( 'simplecov',          '~> 0.22' )
  spec.add_development_dependency( 'archive-zip',        '~> 0.13' )

  spec.extensions.concat This.extension_conf_files
  spec.license = "BSD-3-Clause"
end

This.cross_platforms = %w[
  x86-mingw32
  x64-mingw-ucrt
]

load 'tasks/default.rake'
load 'tasks/extension.rake'
load 'tasks/custom.rake'
load 'tasks/semaphore.rake'
