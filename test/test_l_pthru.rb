#! /usr/bin/env ruby
# == Synopsis
# Testing the LOW level GDS code.  This tests a pash-thru - reading and
# writing of a gds file - where input should equal output.
#
# == Usage
# % test/test_l_pthru.rb
#
# == Author
# David M. Inman (created shell around test only)
#

require 'test/helper.rb'
require_relative '../lib/gdsii'
require 'tempfile'

Test_l_pthru = Module.new do

  class TestLPThru < Test::Unit::TestCase
    include Gdsii

    def self.test_order
      :random
      #:sorted
    end

    # setup: things to do before every test - sometimes nothing.
    def setup
    end

    def test_l_pthru
      in_file  = File.join(File.dirname(__FILE__),'baseline','dcp1.gds')
      out_file = Tempfile.new('l_pthru')
      File.open(in_file, 'rb') do |inf|
        # read in the input file and write it out
        while (rec = Record.read(inf))
          rec.write(out_file.to_io)
        end

		out_file.flush

        # compare the input file to that read and written
        `/usr/bin/diff #{in_file} #{out_file.path}`

        assert_equal(0, $?.exitstatus,
          'read and write of file changed its contents')
        out_file.close
      end
    end

    # teardown: things to do after every test - sometimes nothing.
    def teardown
    end
  end
end
