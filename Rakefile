require 'rubygems'
require 'rdoc/task'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'
require File.join(File.dirname(__FILE__), 'lib', 'ruby_1_9_compat.rb')

begin
  require 'rake'
rescue LoadError
  puts "This script should only be accessed via the 'rake' command.\n" <<
       "Installation: gem install rake -y"
  exit
end

# Create 'gem' rake target from external spec file.
Gem::PackageTask.new(eval(File.read('ruby-gdsii.gemspec'))) do |spec|
	spec.need_tar = false
end

def load_launchy
  begin
    require 'launchy'
    true
  rescue LoadError
    puts "Suggestion: add the 'launchy' gem to launch coverage and\n" <<
         "rdoc pages in your internet browser."
    false
  end
end

unless Gdsii::is_1_9_or_later?
  # for rspec1: require 'spec/rake/spectask'
  require 'rspec/core/rake_task'
end

desc 'Runs "test" target'
task :default => 'test'

Rake::TestTask.new('test') do |t|
  t.libs << ENV['PWD'] # ruby 1.9.2+ removes '.' from loadpath
  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
  # Force the test helper (which loads simplecov) to load first
  # and that forces all subsequent loading to be seen by simplecov
  t.ruby_opts = ['-r "./test/helper"']
end

task(:test) do |t|
	t.full_comment.replace 'Run all unit tests' if t.full_comment
end

desc 'Create API documentation'
Rake::RDocTask.new do |rd|
    rd.main = 'README.txt'
    rd.rdoc_files.include('README.txt', 'CHANGELOG.txt', 'lib/**/*.rb')
end

task :rdoc_end do
  if load_launchy
    file = File.join(File.dirname(__FILE__), 'html', 'index.html')
    Launchy.open('file://' << file) if File.exist?(file)
  end
end

desc 'Create API documentation and view'
task :doc => [ :rdoc, :rdoc_end ]

if Gdsii::is_1_9_or_later?
  task :coverage_begin do
    ENV['COVERAGE'] = 1.to_s
    ENV['RUBYOPT']  = '-W0'
  end

  task :coverage_end do
    if load_launchy
      file = File.join(File.dirname(__FILE__), 'coverage', 'index.html')
      Launchy.open('file://' << file) if File.exist?(file)
    end
  end
  
  desc "Determines what code has been tested. Uses Simplcov: A\n" <<
       "Powerful, Straightforward Ruby 1.9 Code Coverage Tool\n"  <<
       "http://rubydoc.info/gems/simplecov/frames"
  task :coverage => [ :coverage_begin, :test, :coverage_end ]
else  
  # The rcov/rspec code below works under ruby 1.8 only
  # coverage is done with simplecov from 1.9 onward.
  desc 'RCov'
  # for rspec1: Spec::Rake::SpecTask.new('rcov') do |t|
  RSpec::Core::RakeTask.new('rcov') do |t|
    t.spec_opts = ['--format', 'specdoc', '--colour']
    t.spec_files = Dir['test/test_*.rb'].sort
    t.libs = ['lib', 'lib/gdsii' ]
    t.rcov = true
  end
end

