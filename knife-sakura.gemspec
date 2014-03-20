# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'knife-sakura/version'

Gem::Specification.new do |s|
  s.name         = 'knife-sakura'
  s.version      = Knife::Sakura::VERSION
  s.authors      = ['HIGUCHI Daisuke']
  s.email        = ['d-higuchi@creationline.com']
  s.homepage     = 'https://github.com/cl-lab-k/knife-sakura'
  s.summary      = %q{Sakura Cloud Support for Chef's Knife Command}
  s.description  = s.summary
  s.license      = 'Apache 2.0'

  s.files        = `git ls-files`.split("\n")

  s.add_dependency 'fog', '>= 1.21.0'

  s.require_paths = ['lib']
end

