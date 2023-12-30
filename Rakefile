# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

rule ".rb" => ".y" do |t|
  sh "racc -l -o #{t.name} #{t.source}"
end

task compile: ["lib/automata/regex/parser.rb"]

task test: :compile

task default: :test

task :clean do
  `rm lib/automata/regex/parser.rb`
  `rm -rf tmp/*`
end
