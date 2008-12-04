#
# There are two approaches to interacting with a GDSII file using this module:
#
# 1. At the record level (low-level)
# 2. At the record group level (high-level)
#
#
# = Approach #1
#
# (See Record class for details)
#
# Interaction at the record level is intended for streamlined file processing
# where the author has a good knowledge of the GDSII structure.  A typical
# usage might be to streamline changes to a GDSII file such as changing
# bus bit characters on a node name from <> to [] format (see the samples
# directory of this library installation for an example).  Here is a simple
# way to dump the all strings in a GDSII file using the Record class:
#
#  require 'gdsii'
#
#  # Note: 'rb' is required for DOS/Windows compatibility
#  File.open('mydesign.gds', 'rb') do |file|
#    Gds::Record.read_each(file) do |record|
#      puts record.data[0] if record.is_string?
#    end
#  end
#
#
# = Approach #2
#
# (See Group, Library, Structure, Element, Boundary, Path, Text, SRef, ARef,
# Node, and Box classes for details)
#
# The second approach offers a high-level interface to the GDSII format which
# might be ideal in cases where the author may not be familiar with the details
# of the GDSII format.  This example will write a small transistor cell:
#
#  require 'gdsii'
#  
#  Gdsii::Library.new('MYLIB.DB') do |lib|
#    
#    Gdsii::Structure.new('trans') do |struct|
#      
#      # Diffusion layer
#      struct.add Gdsii::Boundary.new(1, 0, [-2000,0, -2000,4000, 2000,4000, 2000,0, -2000,0])
#  
#      # Gate layer... add a property labling as "gate"
#      Gdsii::Path.new(2, 0, 0, 800, [0,-600, 0,4600]) do |path|
#        path.add Gdsii::Property.new(1, 'gate')
#        struct.add path
#      end
#  
#      # Add this structure to the library
#      lib.add struct
#
#    end
#  
#    # Write the library to a file
#    lib.write('trans.gds')
#    
#  end
# 
#
# = Important notes
#
# == Look at inherited and mixed-in methods
#
# The high-level classes in this GDSII library rely heavily upon inheritance
# and mixed-in modules to reduce code.  When reviewing documentation, be sure
# to be aware of methods defined implicitly through class inheritance and
# through Module#include and Module#extend.
#
# == Use 'b' during R/W of files
#
# Be sure to always use the 'b' read/write attribute when reading and writing
# GDSII files to ensure that read/write happens properly on DOS/Windows
# systems.  For example (see IO#open for more details):
#
#  inf = File.open('mydesign.gds', 'rb')
#  outf = File.open('mydesign.gds', 'wb')
#
# == Improving performance
#
# The low-level GDSII methods will offer significantly better GDSII read/write
# performance as compared to the high-level methods.  For most streamlined
# manipulations of GDSII files, the low-level methods are probably the best
# option.  For smaller GDSII files or when code re-use/readability is
# important, then the performance hit with the high-level methods may not be
# a concern.
#
# Here are some benchmarks using both low and high level methods to read and
# immediately write a GDSII file:
#
# * GDSII file size: 7 MB
# * WinXP machine: Intel(R) Pentium(R) M (Centrino) 1.6 Ghz @ 1 GB RAM
# * Linux machine (SuSE): 2x Intel(R) Pentium(R) 4 3.4 Ghz @ 1 GB RAM
#
#                           Linux      WinXP
#                          -------    -------
#  High-level methods:      8m 45s    11m 23s
#  Low-level methods:       0m 45s     1m 29s
#
module Gdsii
  # Empty module here as a placeholder for rdoc
end

# Require byte order, constants, and mixins
require 'gdsii/byte_order.rb'
require 'gdsii/record/consts.rb'
require 'gdsii/mixins.rb'

# Require low-level files (data types and records)
require 'gdsii/record/datatypes/bitarray.rb'
require 'gdsii/record/datatypes/int4.rb'
require 'gdsii/record/datatypes/nodata.rb'
require 'gdsii/record/datatypes/real4.rb'
require 'gdsii/record/datatypes/ascii.rb'
require 'gdsii/record/datatypes/data.rb'
require 'gdsii/record/datatypes/real8.rb'
require 'gdsii/record/datatypes/int2.rb'
require 'gdsii/record.rb'

# Require high-level files
require 'gdsii/bnf.rb'
require 'gdsii/group.rb'
require 'gdsii/element.rb'
require 'gdsii/property.rb'
require 'gdsii/strans.rb'
require 'gdsii/boundary.rb'
require 'gdsii/path.rb'
require 'gdsii/text.rb'
require 'gdsii/box.rb'
require 'gdsii/node.rb'
require 'gdsii/sref.rb'
require 'gdsii/aref.rb'
require 'gdsii/structure.rb'
require 'gdsii/library.rb'
