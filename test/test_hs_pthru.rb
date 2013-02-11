#! /usr/bin/env ruby
# == Synopsis
# Testing the HIGH level *streamlined* GDS code.  This tests a
# pash-thru - reading and writing of a gds file - where input should
# equal output.
#
# == Usage
# % test/test_hs_pthru.rb
#
# == Author
# David M. Inman (created shell around test only)
#

require 'test/helper.rb'
require_relative '../lib/gdsii'
require 'tempfile'

Test_hs_pthru = Module.new do

  class TestHSPThru < Test::Unit::TestCase
    include Gdsii

    def self.test_order
      :random
      #:sorted
    end

    # setup: things to do before every test - sometimes nothing.
    def setup
    end

    def test_hs_pthru
      in_file  = File.join(File.dirname(__FILE__),'baseline','dcp1.gds')
      out_file = Tempfile.new('hs_pthru')
      File.open(in_file, 'rb') do |inf|
        Library.read_header(inf) do |lib|
          lib.write_header(out_file.to_io) do
            Structure.read_each_header(inf) do |struct|
              struct.write_header(out_file.to_io) do
                Element.read_each(inf) {|element| element.write(out_file.to_io)}
              end
            end
          end
        end

        out_file.close

        # compare the input file to that read and written
        `/usr/bin/diff #{in_file} #{out_file.path}`

        assert_equal(0, $?.exitstatus,
          'read and write of file changed its contents')
      end
    end

    # teardown: things to do after every test - sometimes nothing.
    def teardown
    end
  end
end
