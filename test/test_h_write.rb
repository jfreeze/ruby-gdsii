#! /usr/bin/env ruby
# == Synopsis
# Uses high-level GDSII methods to write out a number of GDSII records using
# many of the available method calls.  This can be useful to verify that the
# GDSII library is working and the output file can be compared against the
# file found in ./test/baseline/h_write.gds to ensure that the platform is
# reading and writing GDSII properly.
#
# == Usage
# % test/test_h_write.rb
#
# == Author
# David M. Inman (created shell around test only)
#

require 'test/helper.rb'
require_relative '../lib/gdsii'
require 'tempfile'

Test_h_write = Module.new do

  class TestHWrite < Test::Unit::TestCase
    include Gdsii

    def self.test_order
      :random
      #:sorted
    end

    # setup: things to do before every test - sometimes nothing.
    def setup
    end

    def test_h_write
      ref_file = File.join(File.dirname(__FILE__),'baseline','h_write.gds')
      out_file = Tempfile.new('h_write')

      ##########################
      # CREATE THE OUTPUT FILE
      # Get a standard time (epoch; 12/31/1969) so we have the same time
      # stamp for comparing GDSII output
      time = Time.utc(2000, 1, 1, 0, 0, 0)
      
      # Create a new GDSII library
      lib = Library.new('MYLIB.DB')
      lib.modify_time = time
      lib.access_time = time
      
      # Create a top level structure
      top = Structure.new('top')
      top.create_time = time
      top.modify_time = time
      
      # Create a box 5u square on layer 1:0 with the center at the origin
      Boundary.new(1, 0,
        [-2500,-2500, -2500,2500, 2500,2500, 2500,-2500, -2500,-2500]) do |bnd|
        bnd.add Property.new(1, 'testprop1')
        bnd.add Property.new(1, 'testprop2')
        bnd.add Property.new(2, 'testprop3')
        top.add bnd
      end
      
      # Create text labels around the 5u box using different text label origins
      top.add Text.new(1, 0, [0,0],         'c',  0, :c )
      top.add Text.new(1, 0, [0,2500],      'n',  0, :n )
      top.add Text.new(1, 0, [2500,2500],   'ne', 0, :ne)
      top.add Text.new(1, 0, [2500,0],      'e',  0, :e )
      top.add Text.new(1, 0, [2500,-2500],  'se', 0, :se)
      top.add Text.new(1, 0, [0,-2500],     's',  0, :s )
      top.add Text.new(1, 0, [-2500,-2500], 'sw', 0, :sw)
      top.add Text.new(1, 0, [-2500,0],     'w',  0, :w )
      top.add Text.new(1, 0, [-2500,2500],  'nw', 0, :nw)
      
      # Test different fonts
      0.upto(3) do |font|
        top.add Text.new(1, 0, [0, -500*font-3000], "font#{font}", font)
      end
      
      # Create a via/contact structure
      via = Structure.new('via')
      via.create_time = time
      via.modify_time = time
      
      lib.add via
      via.add Boundary.new(1, 0,
        [-500,-500, -500,500, 500,500, 500,-500, -500,-500])
      via.add Boundary.new(2, 0,
        [-800,-800, -800,800, 800,800, 800,-800, -800,-800])
      via.add Boundary.new(3, 0,
        [-600,-600, -600,600, 600,600, 600,-600, -600,-600])
      
      # Create a transistor structure - use our via cell for gate and
      # source/drain terminals
      lib.add trans = Structure.new('trans')
      trans.create_time = time
      trans.modify_time = time
      
      trans.add Boundary.new(1, 0,
        [-2500,-5000, -2500,5000, 2500,5000, 2500,-5000, -2500,-5000])
      trans.add Path.new(4, 0, 0, 800, [0,-7000, 0,7000])
      trans.add SRef.new('via', [-1700,0])
      trans.add SRef.new('via', [1700,0])
      trans.add SRef.new('via', [0,7000])
      
      # Drop transistor cell down every 1.5u using different rotations
      # and flip/x
      x_offset = 0
      [false, true].each do |reflect_x|
        0.step(270, 90) do |angle|
          # Create an sref with the reflection and angle
          SRef.new('trans', [x_offset, 12000]) do |sref|
            sref.strans.reflect_x = reflect_x
            sref.strans.angle = angle.to_f
            top.add sref
          end
      
          # Add annotation text indicating reflection and angle
          top.add Text.new(1, 0, [x_offset, 20000],
            "reflect_x=#{reflect_x}", 0, :c)
          top.add Text.new(1, 0, [x_offset, 20500],
            "angle=#{angle.to_f.to_s}", 0, :c)
                   
          x_offset += 15000
        end
      end

      # Write the library to file
      lib.add top
      lib.write(out_file.to_io)

      # END OF DATA CREATION
      ##########################

      out_file.close

      # compare the input file to that read and written
      `/usr/bin/diff #{ref_file} #{out_file.path}`

      assert_equal(0, $?.exitstatus,
        "GDSII written does not match reference file: #{ref_file}")
    end

    # teardown: things to do after every test - sometimes nothing.
    def teardown
    end
  end
end
