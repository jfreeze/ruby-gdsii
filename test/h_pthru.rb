require 'gdsii'
include Gdsii

in_file, out_file = ARGV
unless in_file and out_file
  abort "
Uses the GDSII high-level methods to read in a GDSII file and then write out
the same GDSII file.  The file should be identical - or at least just have
just EOF null-padding differences.

h_pthru.rb <in-file> <out-file>

"
end

File.open(in_file, 'rb') do |inf|
  puts "Reading #{in_file}..."
  lib = Library.read(inf)
  puts "Writing #{out_file}..."
  lib.write(out_file)
end

