require 'rubygems'
begin
  require 'rake'
rescue LoadError
  puts 'This script should only be accessed via the "rake" command.'
  puts 'Installation: gem install rake -y'
  exit
end

require 'rake/testtask'
require 'spec/rake/spectask'
require 'fileutils'

task :default => 'test'

desc 'Run all tests'
Rake::TestTask.new('test') do |t|
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

desc "RCov"
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_opts = ["--format", "specdoc", "--colour"]
  t.spec_files = Dir['test/test_*.rb'].sort
  t.libs = ['lib' ]
  t.rcov = true
end

