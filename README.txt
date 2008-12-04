
=== Overview =================================================================

The GDSII Ruby Library provides an easy-to-use interface using Ruby to reading
and writing GDSII files.  Details may be found in the "doc" directory or by
running "rdoc" on the "lib" directory.

Contributors:

 - Jim Freeze
 - Ben Hoefer
 - James Masters
 - Matt Welland
 - Dan White

Project webspace:

  http://rubyforge.org/projects/gdsii/

This library is released under the MIT License (see LICENSE.txt)

=== Installation =============================================================

The "installation" is easy - simply add the contents in the "lib" directory
in this package to a directory where Ruby is installed or set the $RUBYLIB
environment variable to include the "lib" directory.


=== Testing ==================================================================

The GDSII library has been tested on Windows XP, SuSE Linux, SunOS, and HP-UX.
To test the library on your own platform and configuration, a number of test
suites are located in the "test" directory of this installation package:



* test_gds_group.rb

A unit test of the high-level GDSII methods.

* test_gds_record.rb

A unit test of the low-level GDSII methods.

* h_pthru.rb

Uses the GDSII high-level methods to read in a GDSII file and then write out
the same GDSII file.  The file should be identical - or at least just have
just EOF null-padding differences.

* l_pthru.rb

Uses the GDSII low-level methods to read in a GDSII file and then write out
the same GDSII file.  The file should be identical - or at least just have
just EOF null-padding differences.

* h_write.rb

Uses high-level GDSII methods to write out a number of GDSII records using
many of the available method calls.  This can be useful to verify that the
GDSII library is working and the output file can be compared against the
file found in ./test/baseline/h_write.gds to ensure that the platform is
reading and writing GDSII properly.


=== Utility Scripts ==========================================================

A few utility scripts have been included in the "bin" directory for general
purpose use and/or for reference in using the Ruby GDSII library:

* gds2rb

Translates a GDSII file into a Ruby script containing commands to recreate the
GDSII file. This might make custom edits to a GDSII file easy by post-
processing the script through automation or by hand before running the script
to produce an output GDSII file.

* gdsdebug

A detailed GDSII "dump" program that can be used to debug issues with a GDSII
file that may be somehow corrupt or may be causing the GDSII Ruby file read
methods to fail.

* gdsdump

A conversion of GDSII data to the "L" file format (ASCII). This can make
quickly reviewing GDSII file contents through text very easy.

* gdslayers

Lists all layer and data types in the GDSII file.

* gdssremove

Removes the specified structure(s) from the GDSII file.

* gdsssplit

Extracts the specified structure(s) from the GDSII file and creates separate
files for each of the extracted structures.

* gdsstats

Reads a GDSII file and produces a statistical summary of the contents of each
structure in the file.

* gdsstructs

Lists all structure names found in the GDSII file.

* gdstree

Prints a hierarchical tree of structures in a GDSII file. 
