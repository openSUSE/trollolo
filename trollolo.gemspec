# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'trollolo'
  s.version     = Trollolo::VERSION
  s.license     = 'GPL-3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Cornelius Schumacher']
  s.email       = ['cschum@suse.de']
  s.homepage    = 'https://github.com/openSUSE/trollolo'
  s.summary     = 'Trello command line client'
  s.description = 'Trollolo is a command line tool to access Trello and support tasks like generation of burndown charts.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'trollolo'

  s.add_dependency 'thor', '~> 0.19'
  s.add_dependency 'ruby-trello', '~> 1.1'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

  s.files += Dir['man/*.?']              # UNIX man pages
  s.files += Dir['man/*.{html,css,js}']  # HTML man pages
end
