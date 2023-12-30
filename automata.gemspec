# frozen_string_literal: true

require_relative "lib/automata/version"

Gem::Specification.new do |spec|
  spec.name = "automata"
  spec.version = Automata::VERSION
  spec.authors = ["JW"]
  spec.email = ["jimtron9000@gmail.com"]

  spec.summary = "automata"
  spec.description = "automata"
  spec.homepage = "automata"
  spec.required_ruby_version = ">= 2.6.0"
  spec.homepage = "http://none"

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "racc"
  spec.add_dependency "pry"
end
