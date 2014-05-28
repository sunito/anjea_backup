# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anjea_backup/version'

Gem::Specification.new do |spec|
  spec.name          = "anjea_backup"
  spec.version       = AnjeaBackup::VERSION
  spec.authors       = ["Felix Wolfsteller"]
  spec.email         = ["felix.wolfsteller@gmail.com"]
  spec.summary       = %q{Backup with ruby, rsync, hardlinks, hacks, without style but with aboriginal mystery.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/fwolfst/anjea_backup/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
