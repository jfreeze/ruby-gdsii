# Tests must be invoked with the user's working directory
# being the directory above "test" and "lib".
require 'ruby_1_9_compat.rb'

# Put things in here that are needed for all tests_*.rb files.
if Gdsii::is_1_9_or_later?
  require 'simplecov'

  # Setup code coverage for tests
  if ENV['COVERAGE']
    if ! defined?($SimpleCovStarted)
      $SimpleCovStarted = 1
      SimpleCov.start do
        add_filter 'test/'
      end
    end
  end
end

require 'test/unit'
