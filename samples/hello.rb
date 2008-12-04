#!/usr/bin/env ruby
##############################################################################
#
# == hello.rb
#
# A simple "Hello World" example of the high-level GDSII classes and method
# calls.  This example will display the words "Hello" in a subcell of four
# different rotations about the (0,0) origin.
#
# === Author
#
# James D. Masters (james.d.masters@gmail.com)
#
# === History
#
# * 03/27/2007 (jdm): Initial version
#
#
##############################################################################


require 'gdsii/record.rb'
include Gdsii



require 'gdsii'

include Gdsii

lib = Library.new('HELLO.DB')


########################################
# Write "HELLO" in a structure on layer 1,0
########################################

# create hello structure and add to GDSII library
hello = lib.add Structure.new('hello')

# "H"
hello.add(Boundary.new(1, 0, [    0,   0,        0,  700,
                                100,  700,     100,  400,
                                300,  400,     300,  700,
                                400,  700,     400,    0,
                                300,    0,     300,  300,
                                100,  300,     100,    0,
                                  0,    0               ]))

# "E"
hello.add(Boundary.new(1, 0, [ 600,    0,     600,  700,
                               900,  700,     900,  600,
                               700,  600,     700,  400,
                               900,  400,     900,  300,
                               700,  300,     700,  100,
                               900,  100,     900,    0,
                               600,    0               ]))

# "L"
hello.add(Boundary.new(1, 0, [1100,    0,    1100,  700,
                              1200,  700,    1200,  100,
                              1400,  100,    1400,    0,
                              1100,    0               ]))

# "L"
hello.add(Boundary.new(1, 0, [1600,    0,    1600,  700,
                              1700,  700,    1700,  100,
                              1900,  100,    1900,    0,
                              1600,    0               ]))

# "O"
hello.add(Boundary.new(1, 0, [2100,  200,    2100,  600,
                              2200,  700,    2500,  700,
                              2600,  600,    2600,  100,
                              2500,    0,    2200,    0,
                              2100,  100,    2100,  200,
                              2200,  200,    2300,  100,
                              2400,  100,    2500,  200,
                              2500,  500,    2400,  600,
                              2300,  600,    2200,  500,
                              2200,  200,    2100,  200]))

# Create a top structure and add 4 instantiations of rotation for structure
# "hello"
top = lib.add Structure.new('top')

0.step(270, 90) do |angle|
  top.add SRef.new('hello', [0,0]).configure {|sref|
    sref.strans.angle = angle.to_f
  }
end

lib.write('hello.gds')

